import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:inventory/screens/profile_page.dart';
import 'package:inventory/screens/scanner_page.dart';
import 'package:inventory/screens/transaction_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:location/location.dart' as loci;
import 'dart:async';
import 'package:inventory/Model/loc.dart';
import 'package:intl/intl.dart';
import 'package:inventory/Service/Repository.dart';
import 'package:get/get.dart';
import 'package:app_settings/app_settings.dart';
import 'package:inventory/screens/ReturnScreen.dart';


class QRCodeScanner extends StatefulWidget {
  @override
  _QRCodeScannerState createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  int _selectedIndex = 0;
  final _pageController = PageController();
  final loci.Location location = loci.Location();
  StreamSubscription<loci.LocationData>? _locationSubscription;

  final List<Widget> _children = [
    ScannerPage(),
    TransactionPage(),
    ProfilePage(),
    ReturnPage(),

  ];

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    loci.PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loci.PermissionStatus.deniedForever) {
      _showLocationPermissionDialog();
    } else if (_permissionGranted == loci.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loci.PermissionStatus.granted) {
        _showLocationPermissionDialog();
      } else {
        _startLocationUpdates();
      }
    } else {
      _startLocationUpdates();
    }
  }

  void _startLocationUpdates() {
    location.changeSettings(interval: 60000, accuracy: loci.LocationAccuracy.high); // 60 seconds
    location.enableBackgroundMode(enable: true);
    _listenLocation();
  }

  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      _stopListening(); // Stopping listening on error
    }).listen((loci.LocationData currentLocation) async {
      try {
        final loc Loc = loc(
          longi: currentLocation.longitude.toString(),
          lat: currentLocation.latitude.toString(),
          time: DateFormat('yyyy-MM-ddTHH:mm:ss.SSSSSS').format(DateTime.now()),
        );
        repository.addloc(Loc.toMap());
      } catch (e) {
        print(e);
      }
    });
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text('Please grant location permission in app settings.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                AppSettings.openAppSettings();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  void _stopListening() {
    _locationSubscription?.cancel(); // Canceling the subscription
    _locationSubscription = null;
  }

  @override
  void dispose() {
    _pageController.dispose(); // Disposing the PageController
    _stopListening(); // Stopping location listening
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        pageSnapping: true,
        controller: _pageController,
        children: _children,
        onPageChanged: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        items: [
          Icon(MdiIcons.qrcodeScan, size: 30, color: Colors.white),
          const Icon(Icons.library_books, color: Colors.white, size: 30),
          const Icon(Icons.account_circle, color: Colors.white, size: 30),
          Icon(MdiIcons.accountCancel, size: 30, color: Colors.white),
        ],
        color: Colors.black,
        buttonBackgroundColor: Colors.black,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          _pageController.jumpToPage(index); // Jumping to the selected page
        },
      ),
    );
  }
}
