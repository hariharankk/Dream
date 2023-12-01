 import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/screens/Login screen.dart';
import 'package:inventory/Utility.dart';
import 'package:inventory/screens/qr_scanner.dart';
import 'package:inventory/Service/Bloc.dart';
import 'package:inventory/screens/maps.dart';
import 'package:inventory/Getx/maps.dart';
import 'package:inventory/Widget/jktdirection.dart';
import 'package:inventory/Widget/StartEnd.dart';
/*
  1. Login Completed(On error show alert dialog remaining)
  2. Cart Items Value to be updated on adding a new product
  3.  Cart Ready
  4. Payment Ready
  5. Profile Page Only need to get data
  6. All Transactions Only Need to Get Data
  7. Update total on deletion of items in cart page
  8. Empty Cart After Payment Completes
 */
void main() {
  Get.put(LocationController());
  Get.put(FlagController());
  Get.put(StartController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      home: MapScreen(),//MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();

  }

  checkLoginStatus() async {
      JWT jwt= JWT();
      var Token = await jwt.read_token();
      Token == null ? Get.to(LoginPage()) :  userBloc.currentuser().then((_){
        (userBloc.getUserObject() != null) ? Get.to(QRCodeScanner()) : Get.to(LoginPage());
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Center(child: Container()),
    );
  }
}

