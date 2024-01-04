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
import 'package:inventory/Getx/navigation.dart';
import 'package:inventory/Getx/timer.dart';
import 'package:inventory/Getx/euler.dart';
import 'package:inventory/Widget/street review.dart';

void main() {

  Get.put(LocationController());
  Get.put(FlagController());
  Get.put(StartController());
  Get.put(NavigationController());
  Get.put(EulerCircuit());
  Get.put(StreetreviewController());
  Get.put(CountdownController());


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

