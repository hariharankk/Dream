import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:inventory/Getx/return.dart';
import 'package:inventory/Model/Product.dart';
import 'package:inventory/Model/return.dart';
import 'package:inventory/Service/File storage.dart';
import 'package:inventory/Service/Api Service.dart';
import 'package:inventory/Service/Bloc.dart';
import 'package:inventory/Widget/product detail.dart';
import 'package:inventory/Widget/reason.dart';
import 'package:inventory/screens/Invoice.dart';
import 'package:inventory/screens/qr_scanner.dart';

class returndetails extends StatefulWidget {
  const returndetails({Key? key, required this.product}) : super(key: key);

  final Product? product;

  @override
  State<returndetails> createState() => _returndetailsState();
}

class _returndetailsState extends State<returndetails> {
  String? lat, longi, Reason, imgURL, transURL;
  final Rx<XFile?> pickedImage = Rx<XFile?>(null);
  final Rx<XFile?> transImage = Rx<XFile?>(null);
  final TextEditingController usedWeightController = TextEditingController();

  late final ProductController productController;

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
    super.dispose();
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

  Future<void> _complete(
      double quantity,
      double remainingWeight,
      double price,
      int transId,
      ) async {
    if (pickedImage.value == null || transImage.value == null) {
      Get.snackbar(
        'Return',
        'Images are missing, please retake.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (lat == null || longi == null || Reason == null) {
      Get.snackbar(
        'Return',
        'Location or reason is missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final Imagestorage imagestorage = Imagestorage();
    final Apirepository apirepository = Apirepository();

    final String img = await imagestorage.upload(File(pickedImage.value!.path));
    if (img.isNotEmpty) {
      imgURL = '$SERVERURL/image/$img';
    }

    final String img1 =
    await imagestorage.upload(File(transImage.value!.path));
    if (img1.isNotEmpty) {
      transURL = '$SERVERURL/image/$img1';
    }

    final Returnprod returnobj = Returnprod(
      user_id: userBloc.getUserObject().user,
      name: widget.product!.name,
      description: widget.product!.description,
      price: price,
      returnquantity: remainingWeight,
      quantity: quantity,
      imgurl: imgURL!,
      lat: lat!,
      long: longi!,
      reason: Reason!,
      trans_id: transId,
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
        title: const Text('Return Details'),
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
            const SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                const Text("Location: ", textScaleFactor: 1.1),
                MaterialButton(
                  padding: const EdgeInsets.all(10.0),
                  onPressed: _getLocation,
                  textColor: Colors.white,
                  color: Colors.purpleAccent,
                  child: const Text("Get Location", textScaleFactor: 1.2),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Container(
              margin: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: _takePicture,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 20.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
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
            const SizedBox(height: 20.0),

            // Transaction ID – reactive error
            Container(
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.all(5.0),
              child: Obx(
                    () => TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Enter Transaction ID",
                    border: const OutlineInputBorder(),
                    hintText: 'Transaction ID',
                    errorText: productController.isInvalid.value
                        ? "Invalid ID"
                        : null,
                  ),
                  onChanged: productController.setTransactionId,
                ),
              ),
            ),

            const SizedBox(height: 20.0),

            // Transaction summary card
            Container(
              margin: const EdgeInsets.all(15.0),
              child: Obx(() {
                if (productController.transactionDetails.value == null) {
                  return const Center(
                    child: Text("No transaction details available."),
                  );
                }
                return GestureDetector(
                  onTap: () {
                    Get.to(
                      InvoiceScreen(
                        transaction:
                        productController.transactionDetails.value!,
                      ),
                    );
                  },
                  child: Padding(
                    padding:
                    const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Transaction Id',
                                  style: TextStyle(fontSize: 11.0),
                                ),
                                Text(
                                  '${productController.transactionDetails.value!.id}',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.yellow,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Payment',
                                  style: TextStyle(fontSize: 11.0),
                                ),
                                Text(
                                  '${productController.transactionDetails.value!.payment_method}',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.pink,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Purchased On',
                                  style: TextStyle(fontSize: 11.0),
                                ),
                                Text(
                                  DateFormat('yyyy-MM-dd HH:mm').format(
                                    DateTime.parse(
                                      productController.transactionDetails
                                          .value!.transaction_time!,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.deepOrangeAccent,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Total Amount',
                                  style: TextStyle(fontSize: 11.0),
                                ),
                                Text(
                                  'Rs.${productController.transactionDetails.value!.total}',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Divider(thickness: 2.0),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),

            // Photo of bill
            Container(
              margin: const EdgeInsets.all(15.0),
              child: TextButton(
                onPressed: _takePicture1,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 20.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
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

            const SizedBox(height: 20.0),

            // Reason
            Center(
              child: ReasonInputWidget(
                onReasonSubmitted: (reason) {
                  setState(() {
                    Reason = reason;
                  });
                },
              ),
            ),

            // Product + weights + refund
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
                      mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                      children: [
                        ProductDetailCard('Name', widget.product!.name),
                        const SizedBox(width: 5),
                        ProductDetailCard(
                          'Price',
                          '${productController.productPrice} Rs',
                        ),
                        const SizedBox(width: 5),
                        ProductDetailCard(
                          'Total Weight',
                          '${widget.product!.weight} kg',
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            const Text(
                              "Return weight",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 60,
                              child: TextField(
                                controller: usedWeightController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: '0',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  productController
                                      .updateUsedWeight(value);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 5),
                        Obx(
                              () => ProductDetailCard(
                            'used',
                            '${productController.usedWeight.value.toStringAsFixed(2)} kg',
                          ),
                        ),
                        const SizedBox(width: 5),
                        Obx(
                              () => ProductDetailCard(
                            'Refund',
                            '${productController.costOfUsed.value.toStringAsFixed(2)} Rs',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20.0),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Get.offAll(QRCodeScanner());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 26.0,
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                          children: const [
                            Text(
                              'discard',
                              style: TextStyle(fontSize: 10.0),
                            ),
                            Icon(Icons.restore_from_trash, size: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (lat == null ||
                            longi == null ||
                            Reason == null ||
                            pickedImage.value == null ||
                            transImage.value == null ||
                            productController.transactionId.value ==
                                0 ||
                            usedWeightController.text.isEmpty) {
                          Get.dialog(
                            AlertDialog(
                              title: const Text('Missing Information'),
                              content: const Text(
                                'Please ensure all details are filled before proceeding.',
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Get.back();
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
                            productController.transactionId.value,
                          );
                          Get.offAll(QRCodeScanner());
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 26.0,
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                          children: const [
                            Text(
                              'Return',
                              style: TextStyle(fontSize: 10.0),
                            ),
                            Icon(
                              Icons.restore_from_trash,
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
