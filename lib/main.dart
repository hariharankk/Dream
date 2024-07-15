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
import 'package:inventory/Getx/street review.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeControllers();

  runApp(MyApp());
}

Future<void> initializeControllers() async {
  Get.put(LocationController());
  Get.put(FlagController());
  Get.put(StartController());
  Get.put(NavigationController());
  Get.put(EulerCircuit());
  Get.put(StreetreviewController());
  Get.put(CountdownController());
  Get.put(ReasonController());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      home: InitialScreen(), // MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InitialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white70,
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white70,
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          return snapshot.data == true ? QRCodeScanner() : LoginPage();
        }
      },
    );
  }

  Future<bool> checkLoginStatus() async {
    JWT jwt = JWT();
    var token = await jwt.read_token();
    if (token == null) {
      return false;
    }
    await userBloc.currentuser();
    return userBloc.getUserObject() != null;
  }
}
