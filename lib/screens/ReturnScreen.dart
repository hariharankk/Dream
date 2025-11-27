import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:inventory/Service/Repository.dart';
import 'package:inventory/Model/Product.dart';
import 'package:get/get.dart';
import 'package:inventory/screens/Returnscreendetails.dart';

class ReturnPage extends StatefulWidget {
  @override
  _ReturnPageState createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  ScanResult? scanResult;
  String? errorName;
  Product? product;

  Future _scanQR() async {
    try {
      var qrResult = await BarcodeScanner.scan();
      setState(() {
        scanResult = qrResult;
      });
      retrieveInfo(scanResult!.rawContent).then((success) {
        print('dddd${scanResult!.rawContent}');
        if (success) {
          productDialog();
        } else {
          Get.dialog(
            AlertDialog(
              title: Text("Error"),
              content: Text("Failed to retrieve product details."),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Get.back(); // Close the dialog
                  },
                ),
              ],
            ),
          );
        }
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        errorName = "Camera Permission was denied";
      } else {
        setState(() {
          errorName = "Unknown error: $e";
        });
      }
    } on FormatException {
      setState(() {
        errorName = "You pressed the back button before scanning anything";
      });
    } catch (e) {
      setState(() {
        errorName = "Unknown error: $e";
      });
    }
  }

  Future<bool> retrieveInfo(String productId) async {
    try {
      product = await repository.getProduct(productId);
      print(product);
      return true; // Return true to indicate success
    } catch (e) {
      print('Error retrieving product: $e');
      return false; // Return false to indicate failure
    }
  }

  Future<void> productDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          title: Text(
            'Product Details',
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'id :   ${product!.id}',
                  style: TextStyle(),
                ),

                SizedBox(
                  height: 5.0,
                ),

                Text(
                  'Item   :   ${product!.name}',
                  style: TextStyle(),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  'Price  :   ${product!.gstPrice ?? product!.price}',
                  style: TextStyle(),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Return',
                          style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        // This sets the color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ), // This sets the shape
                      ),
                      onPressed: () {
                        Get.to(returndetails(product: product!,));
                        scanResult = null;

                      },
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    ElevatedButton(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        // Use 'primary' for button color
                        shape: RoundedRectangleBorder(
                          // Shape is defined here
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () {
                        scanResult = null;
                        Get.back();
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Return Screen'),
          automaticallyImplyLeading: false,
          centerTitle: true,
          elevation: 5.0,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Scan To Return',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Center(
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // color
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16.0),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 20.0,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          'Scan',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 10.0,
                            color: Colors.white,
                          ),
                        ),
                        Opacity(opacity: 0.0, child: Icon(Icons.camera_alt)),
                      ],
                    ),
                    onPressed: _scanQR,
                  )),
            ),
          ],
        ));
  }
}
