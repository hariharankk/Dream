import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:inventory/Getx/return.dart';
import 'package:inventory/Model/Product.dart';
import 'package:inventory/Model/return.dart';
import 'package:inventory/Service/File storage.dart';
import 'package:inventory/Service/pdf_invoice_service.dart';
import 'package:inventory/Service/Api Service.dart';
import 'package:inventory/Service/Bloc.dart';
import 'package:inventory/Widget/product detail.dart';
import 'package:inventory/Widget/reason.dart';
import 'package:inventory/screens/Invoice.dart';
import 'package:inventory/screens/qr_scanner.dart';


class returndetails extends StatefulWidget {
  returndetails({required this.product});

  final Product? product;

  @override
  State<returndetails> createState() => _returndetailsState();
}

class _returndetailsState extends State<returndetails> {

String? lat, longi, Reason, imgURL, transURL;
final Rx<XFile?> pickedImage = Rx<XFile?>(null);
final Rx<XFile?> transImage = Rx<XFile?>(null);
final TextEditingController usedWeightController = TextEditingController();
final TextEditingController _phoneController = TextEditingController();
final PdfInvoiceService _pdfInvoiceService = PdfInvoiceService();

late final ProductController productController;
bool _isGenerating = false;

@override
void initState() {
  super.initState();
  final double productWeight = widget.product?.weight ?? 0;
  final double productPrice = widget.product?.price ?? 0;
  productController = Get.put(
    ProductController(
      productWeight: productWeight,
      productPrice: productPrice,
    ),
  );
}

@override
void dispose() {
  usedWeightController.dispose();
  _phoneController.dispose();
  super.dispose();
}

double _parseToDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}

Future<void> _getLocation() async {
  final Position position = await Geolocator.getCurrentPosition();
  setState(() {
    lat = position.latitude.toString();
    longi = position.longitude.toString();
  });
}

Future<void> _takePicture() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedImageValue = await picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 100,
    preferredCameraDevice: CameraDevice.rear,
  );
  pickedImage(pickedImageValue);
}

Future<void> _takePicture1() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedImageValue = await picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 100,
    preferredCameraDevice: CameraDevice.rear,
  );
  transImage(pickedImageValue);
}

Future<File?> _generateReturnPdf() async {
  final double refundValue = _parseToDouble(productController.costOfUsed.value);
  final double returnWeightValue =
  _parseToDouble(productController.remainingWeight.value);
  final double usedWeightValue =
      double.tryParse(usedWeightController.text) ?? 0;
  final double totalWeight = widget.product?.weight ?? 0;
  final double price = widget.product?.price ?? 0;
    final String locationText =
    (lat != null && longi != null) ? 'Lat: $lat, Long: $longi' : '';
  final String? transactionId =
  productController.transactionId.value == 0
      ? null
      : productController.transactionId.value.toString();
  final DateTime? createdAt = productController.transactionDetails.value
      ?.transaction_time !=
      null
      ? DateTime.tryParse(
      productController.transactionDetails.value!.transaction_time!)
      : null;
    try {
      setState(() {
        _isGenerating = true;
      });
      return await _pdfInvoiceService.generateReturnSummary(
        productName: widget.product?.name ?? 'Unknown product',
        productPrice: price,
        totalWeight: totalWeight,
        usedWeight: usedWeightValue,
        returnWeight: returnWeightValue,
        refundAmount: refundValue,
        reason: Reason ?? '',
        transactionId: transactionId,
        location: locationText.isEmpty ? null : locationText,
        createdAt: createdAt,      );
    } catch (error) {
      Get.snackbar(
        'Return',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

String _buildSummaryMessage() {
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  final DateTime timestamp = productController.transactionDetails.value
      ?.transaction_time !=
      null
      ? DateTime.parse(
      productController.transactionDetails.value!.transaction_time!)
      : DateTime.now();
  final StringBuffer buffer = StringBuffer();
  buffer.writeln(
      'Return details for ${widget.product?.name ?? 'product'} on ${formatter.format(timestamp)}');
  if (productController.transactionId.value != 0) {
    buffer.writeln('Transaction ID: ${productController.transactionId.value}');
  }
  final double totalWeight = widget.product?.weight ?? 0;
  buffer.writeln('Total weight: ${totalWeight.toStringAsFixed(2)} kg');
  buffer.writeln(
      'Used weight: ${productController.usedWeight.value.toStringAsFixed(2)} kg');
  buffer.writeln(
      'Return weight: ${productController.remainingWeight.value.toStringAsFixed(2)} kg');
  buffer.writeln(
      'Refund: Rs ${productController.costOfUsed.value.toStringAsFixed(2)}');
  if (Reason != null && Reason!.isNotEmpty) {
    buffer.writeln('Reason: $Reason');
  }
  if (lat != null && longi != null) {
    buffer.writeln('Location: Lat $lat, Long $longi');
}



final List<String> words = buffer
    .toString()
    .split(RegExp(r'\s+'))
    .where((word) => word.isNotEmpty)
    .toList();
if (words.length <= 160) {
return buffer.toString().trim();
}
return words.take(160).join(' ');
  }

Future<void> _shareReturnViaWhatsApp() async {
  final String phone = _phoneController.text.trim();
  if (phone.isEmpty) {
    Get.snackbar(
      'WhatsApp',
      'Enter the customer\'s phone number to continue.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  final File? pdfFile = await _generateReturnPdf();
  if (pdfFile == null) {
    return;
  }

  final String message = _buildSummaryMessage();

  try {
    final ShareResult result = await Share.shareXFiles(
      <XFile>[XFile(pdfFile.path, mimeType: 'application/pdf')],
      text: message,
      subject: 'Return details',
    );

    if (result.status == ShareResultStatus.success) {
      final Uri whatsappUri = Uri.parse(
        'https://wa.me/${phone.replaceAll(RegExp(r'[^0-9+]'), '')}?text=${Uri.encodeComponent(message)}',
      );
      if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
        Get.snackbar(
          'WhatsApp',
          'Return details shared. Unable to open WhatsApp automatically.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  } catch (error) {
    Get.snackbar(
      'WhatsApp',
      error.toString(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }
}

Future<void> _sendSms() async {
  final String phone = _phoneController.text.trim();
  if (phone.isEmpty) {
    Get.snackbar(
      'SMS',
      'Enter the customer\'s phone number to continue.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  final String message = _buildSummaryMessage();
  final Uri smsUri = Uri(
    scheme: 'sms',
    path: phone,
    queryParameters: <String, String>{'body': message},
  );

  if (!await launchUrl(smsUri)) {
    Get.snackbar(
      'SMS',
      'Unable to open the SMS application.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }
}

  Future<void> _complete(
      var quanity, var remainingWeight, var price, var transid) async {
    final Imagestorage imagestorage = Imagestorage();
    final Apirepository apirepository = Apirepository();
    final String img = await imagestorage.upload(File(pickedImage.value!.path));
    if (img != null || img != "") {
      imgURL = SERVERURL + '/image/' + img;
    }

    final String img1 = await imagestorage.upload(File(transImage.value!.path));
    if (img1 != null || img1 != "") {
      transURL = SERVERURL + '/image/' + img1;
    }

    final Returnprod returnobj = Returnprod(
      user_id: userBloc.getUserObject().user,
      name: widget.product!.name,
      description: widget.product!.description,
      price: price,
      returnquantity: remainingWeight,
      quantity: quanity,
      imgurl: imgURL!,
      lat: lat!,
      long: longi!,
      reason: Reason!,
      trans_id: transid!,
      idurl: transURL!,
    );
    final Map<dynamic, dynamic> data = returnobj.toMap();
    print(data);
    await apirepository.addreturn(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Return Details'),
        actions: [
          IconButton(
            onPressed: _isGenerating ? null : _shareReturnViaWhatsApp,
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Share return via WhatsApp',
          ),
          IconButton(
            onPressed: _sendSms,
            icon: const Icon(Icons.sms),
            tooltip: 'Send return via SMS',
          ),        ],
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 5.0,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 30.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text("Location: ", textScaleFactor: 1.1),
                  MaterialButton(
                    padding: EdgeInsets.all(10.0),
                    onPressed: _getLocation,
                    child: Text("Get Location", textScaleFactor: 1.2),
                    textColor: Colors.white,
                    color: Colors.purpleAccent,
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),           Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Customer phone number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              if (_isGenerating)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: LinearProgressIndicator(),
                ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                margin: EdgeInsets.all(8.0),
                // This adds an 8-pixel margin on all sides of the button.
                padding: EdgeInsets.all(8.0),
                // This adds an 8-pixel padding on all sides inside the button.
                child: TextButton(
                  onPressed: _takePicture,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white, // Text color
                    backgroundColor: Colors.blue, // Button color
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt),
                      SizedBox(width: 8.0),
                      Text(
                        'Take Photo of Product',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                // This will introduce a space of 10 pixels on all sides around the TextField.
                padding: EdgeInsets.all(5.0),
                // This will introduce a space of 5 pixels between the boundary of the container and the TextField.
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Enter Transaction ID",
                    border: OutlineInputBorder(),
                    hintText: 'Transaction ID',
                    errorText:
                        productController.isInvalid.value ? "Invalid ID" : null,
                  ),
                  onChanged: productController.setTransactionId,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                margin: EdgeInsets.all(15.0),
                // Introduce a space of 15 pixels around the Obx widget.
                padding: EdgeInsets.all(10.0),
                // Introduce a space of 10 pixels inside the Container.
                child: Obx(() {
                  if (productController.transactionDetails.value == null) {
                    return Center(
                      child: Text("No transaction details available."),
                    );
                  }
                  return GestureDetector(
                    onTap: () {
                      Get.to(InvoiceScreen(
                          transaction:
                              productController.transactionDetails.value!));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Transaction Id',
                                    style: TextStyle(
                                      fontSize: 11.0,
                                    ),
                                  ),
                                  Text(
                                    '${productController.transactionDetails.value!.id}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.yellow,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Payment',
                                    style: TextStyle(
                                      fontSize: 11.0,
                                    ),
                                  ),
                                  Text(
                                    '${productController.transactionDetails.value!.payment_method}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.pink,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Purchased On',
                                    style: TextStyle(
                                      fontSize: 11.0,
                                    ),
                                  ),
                                  Text(
                                    '${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(productController.transactionDetails.value!.transaction_time!))}',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.deepOrangeAccent,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Total Amount',
                                    style: TextStyle(
                                      fontSize: 11.0,
                                    ),
                                  ),
                                  Text(
                                    'Rs.${productController.transactionDetails.value!.total}',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Divider(
                              thickness: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              Container(
                margin: EdgeInsets.all(15.0),
                // Adding a margin around the TextButton.
                child: TextButton(
                  onPressed: _takePicture1,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white, // Text color
                    backgroundColor: Colors.blue, // Button color
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    // Adding padding inside the TextButton.
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt),
                        SizedBox(width: 8.0),
                        Text(
                          'Take Photo of Bill',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Center(
                child: ReasonInputWidget(
                  onReasonSubmitted: (reason) {
                    setState(() {
                      Reason = reason;
                    });
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ProductDetailCard('Name', widget.product!.name),
                          SizedBox(
                            width: 5,
                          ),
                          ProductDetailCard('Price', '${productController.productPrice} Rs'),
                          SizedBox(
                            width: 5,
                          ),
                          ProductDetailCard(
                              'Total Weight', '${widget.product!.weight} kg'),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              Text(
                                "Return weight",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: 60,
                                child: TextField(
                                  controller: usedWeightController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    productController.updateUsedWeight(value);
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Obx(() => ProductDetailCard(
                              'used',
                              '${productController.usedWeight.value.toStringAsFixed(2)} kg')),
                          SizedBox(
                            width: 5,
                          ),
                          Obx(() => ProductDetailCard(
                              'Refund', '${productController.costOfUsed.value.toStringAsFixed(2)} Rs')),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 26.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'discard',
                                  style: TextStyle(fontSize: 10.0),
                                ),
                                Icon(MdiIcons.closeCircle, size: 10)
                              ],
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // button color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                          ), // button shape,
                          onPressed: () {
                            Get.offAll(QRCodeScanner());
                          }),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ), // button shape
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 26.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'Return',
                                style: TextStyle(fontSize: 10.0),
                              ),
                              Icon(
                                MdiIcons.logoutVariant,
                                size: 10,
                              )
                            ],
                          ),
                        ),
                        onPressed: () {
                          if (lat == null ||
                              longi == null ||
                              Reason == null ||
                              pickedImage.value == null ||
                              transImage.value == null ||
                              productController.transactionId.value == null ||
                              usedWeightController.text.isEmpty) {
                            // Display dialog to nudge user
                            Get.dialog(
                              AlertDialog(
                                title: Text('Missing Information'),
                                content: Text(
                                    'Please ensure all details are filled before proceeding.'),
                                actions: [
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Get.back(); // Close the dialog
                                    },
                                  )
                                ],
                              ),
                            );
                          } else {
                            _complete(
                                productController.usedWeight.value,
                                productController.remainingWeight.value,
                                productController.costOfUsed.value,
                                productController.transactionId.value);
                            Get.offAll(QRCodeScanner());
                          }
                        },
                      ),
                    )
                  ],
                ),
              )
            ]),
      ),
    );
  }
}








