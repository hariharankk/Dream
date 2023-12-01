import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventory/screens/Cashpayment.dart';
import 'package:inventory/screens/Upipayment.dart';
import 'package:get/get.dart';

class PaymentHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page', style: TextStyle(fontFamily: 'YourFontFamily')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FaIcon(FontAwesomeIcons.indianRupeeSign, size: 100), // Using FontAwesome dollar sign icon
            SizedBox(height: 20),
            Text(
              'Choose Your Payment Method',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'YourFontFamily'),
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton.icon(
                  icon: FaIcon(FontAwesomeIcons.moneyBill, color: Colors.white, ),
                  label: Text('Cash Payment', style: TextStyle(color: Colors.white, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () {
                    Get.to(CashPaymentPage());
                  }
                ),
                ElevatedButton.icon(
                  icon: FaIcon(FontAwesomeIcons.googlePay, color: Colors.white,),
                  label: Text('UPI Payment', style: TextStyle(color: Colors.white, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () {
                    Get.to(UpiPaymentPage());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
