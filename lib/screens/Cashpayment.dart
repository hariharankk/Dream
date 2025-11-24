import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inventory/screens/qr_scanner.dart';
import 'package:inventory/Getx/cart screen.dart';
import 'package:inventory/Model/Transaction.dart';
import 'package:geolocator/geolocator.dart';
import 'package:inventory/Service/Bloc.dart';

class CashPaymentPage extends StatelessWidget {
  final CartController cartController = Get.find();
  var isProcessing = false.obs;

  Future<void> _onConfirmPressed() async {
    isProcessing.value = true;

    if (cartController.customerPhone.value.isEmpty) {
      Get.snackbar(
        'Customer details',
        'Customer phone number is required.',
        snackPosition: SnackPosition.BOTTOM,
      );
      isProcessing.value = false;
      return;
    }


    Position position = await _fetchCurrentLocation();
    List<Map<String, dynamic>> products = _getCartItems();

    Transaction transaction = Transaction(
      payment_method: 'cash',
      lat: '${position.latitude}',
      longi: '${position.longitude}',
      products: products,
      customerName: cartController.customerName.value,
      customerAddress: cartController.customerAddress.value,
      customerPhone: cartController.customerPhone.value,
    );

    var trans = transaction.toMap();
    transactionbloc.createTransaction(trans);
    isProcessing.value = false;
    cartController.clearCart();
    Get.offAll(() => QRCodeScanner());
  }

  Future<Position> _fetchCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  List<Map<String, dynamic>> _getCartItems() {
    List<Map<String, dynamic>> products = [];

    cartController.cartItems.forEach((item) {
      products.add({'product_id': item.id, 'quantity': item.quantity});
    });

    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cash Payment', style: TextStyle(fontFamily: 'YourFontFamily')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FaIcon(FontAwesomeIcons.indianRupeeSign, size: 100), // Using FontAwesome dollar sign icon
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Confirm after the customer has given the Cash and the cash has been put in the Box.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'YourFontFamily'),
              ),
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton.icon(
                    icon: FaIcon(FontAwesomeIcons.cancel, color: Colors.white),
                    label: Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: () {
                      Get.offAll(() => QRCodeScanner());
                    }
                ),
                Obx(
                      ()=>isProcessing.value
                      ? Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: CircularProgressIndicator(),
                  )
                      :                ElevatedButton.icon(
                  icon: FaIcon(FontAwesomeIcons.cashRegister, color: Colors.white),
                  label: Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () => _onConfirmPressed(),
                ),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
