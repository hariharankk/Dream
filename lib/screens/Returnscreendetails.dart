import 'package:flutter/material.dart';
import 'package:inventory/screens/qr_scanner.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/Widget/reason.dart';
import 'dart:io';
import 'package:inventory/Model/return.dart';
import 'package:inventory/Service/File storage.dart';
import 'package:inventory/Service/Api Service.dart';
import 'package:inventory/Service/Bloc.dart';
import 'package:inventory/Widget/product detail.dart';
import 'package:inventory/Model/Product.dart';
import 'package:inventory/Getx/return.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:inventory/screens/return screen transaction.dart';

class returndetails extends StatelessWidget {
  returndetails({required this.product});

  Product? product;
  String? lat, longi, Reason, imgURL, transURL;
  Rx<XFile?> pickedImage = Rx<XFile?>(null);
  Rx<XFile?> transImage = Rx<XFile?>(null);
  final TextEditingController usedWeightController = TextEditingController();

  Future<void> _generateReturnDetailsPdf(
      var refund, var remainingWeight, var transid) async {
    final pw.Document pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: pw.EdgeInsets.all(32.0),
        ),
        build: (pw.Context context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('RETURN DETAILS',
                  style: pw.TextStyle(
                      fontSize: 40, fontWeight: pw.FontWeight.bold)),
              pw.Text(DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Product:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(product!.name),
              pw.Text('Price: ${product!.price} Rs'),
              pw.Text('Total Weight: ${product!.weight} kg'),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Detail',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Value',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text('Used:'),
                      pw.Text('${usedWeightController.text} kg'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text('Remaining:'),
                      pw.Text('${remainingWeight} kg'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text('Refund:'),
                      pw.Text('${refund} Rs'),
                    ],
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Paragraph(text: 'Location: Latitude - $lat, Longitude - $longi'),
          pw.SizedBox(height: 20),
          pw.Paragraph(text: 'Reason for Return: $Reason'),
          pw.Paragraph(text: 'Reason for Return: $transid'),
          pw.SizedBox(height: 20),
          pw.Image(
              pw.MemoryImage(File(transImage.value!.path).readAsBytesSync())),
          // Ensure you have the necessary permission to access files
          pw.Image(
              pw.MemoryImage(File(pickedImage.value!.path).readAsBytesSync())),
          // Ensure you have the necessary permission to access files
          pw.SizedBox(height: 20),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  _getLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    lat = position.latitude.toString();
    longi = position.longitude.toString();
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedImageValue = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear);
    pickedImage(pickedImageValue);
  }

  Future<void> _takePicture1() async {
    final picker = ImagePicker();
    final pickedImageValue = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear);
    transImage(pickedImageValue);
  }

  Future<void> _complete(
      var quanity, var remainingWeight, var price, var transid) async {
    Imagestorage imagestorage = Imagestorage();
    Apirepository apirepository = Apirepository();
    String img = await imagestorage.upload(File(pickedImage.value!.path));
    if (img != null || img != "") {
      imgURL = SERVERURL + '/image/' + img;
    }

    String img1 = await imagestorage.upload(File(transImage.value!.path));
    if (img1 != null || img1 != "") {
      transURL = SERVERURL + '/image/' + img1;
    }

    Returnprod returnobj = Returnprod(
      user_id: userBloc.getUserObject().user,
      name: product!.name,
      description: product!.description,
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
    Map<dynamic, dynamic> data = returnobj.toMap();
    print(data);
    await apirepository.addreturn(data);
  }

  @override
  Widget build(BuildContext context) {
    var productvalue = double.parse(product!.price.toStringAsFixed(0));
    final ProductController productController = Get.put(ProductController(
        productWeight: product!.weight!, productPrice: productvalue));
    return Scaffold(
      appBar: AppBar(
        title: Text('Return Details'),
        actions: [
          IconButton(
              onPressed: () {
                _generateReturnDetailsPdf(
                    productController.costOfUsed.value,
                    productController.remainingWeight.value,
                    productController.transactionId.value);
              },
              icon: Icon(Icons.print))
        ],
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
                    Reason = reason;
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
                          ProductDetailCard('Name', product!.name),
                          SizedBox(
                            width: 5,
                          ),
                          ProductDetailCard('Price', '${productController.productPrice} Rs'),
                          SizedBox(
                            width: 5,
                          ),
                          ProductDetailCard(
                              'Total Weight', '${product!.weight} kg'),
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
                          Obx(() => ProductDetailCard('used',
                              '${productController.usedWeight} kg')),
                          SizedBox(
                            width: 5,
                          ),
                          Obx(() => ProductDetailCard(
                              'Refund', '${productController.costOfUsed} Rs')),
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








