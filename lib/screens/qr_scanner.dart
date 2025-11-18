import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For PlatformException
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/Model/loc.dart';
import 'package:inventory/Service/Repository.dart';
import 'package:inventory/screens/ReturnScreen.dart';
import 'package:inventory/screens/profile_page.dart';
import 'package:inventory/screens/scanner_page.dart';
import 'package:inventory/screens/transaction_page.dart';
import 'package:location/location.dart' as loci;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({super.key});

  @override
  _QRCodeScannerState createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  int _selectedIndex = 0;
  final _pageController = PageController();
  final loci.Location location = loci.Location();
  StreamSubscription<loci.LocationData>? _locationSubscription;

  final List<Widget> _children =  [
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
    // 1. Ensure location service is ON
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // User did not enable location service
        return;
      }
    }

    // 2. Check current permission
    loci.PermissionStatus permission = await location.hasPermission();

    if (permission == loci.PermissionStatus.denied) {
      permission = await location.requestPermission();
    }

    // 3. If still denied or deniedForever, show dialog and stop
    if (permission == loci.PermissionStatus.denied ||
        permission == loci.PermissionStatus.deniedForever) {
      _showLocationPermissionDialog();
      return;
    }

    // 4. Permission granted (foreground). Now try background.
    _startLocationUpdates();
  }

  Future<void> _startLocationUpdates() async {
    // Try enabling background mode – this is where your crash was happening
    try {
      final bool bgEnabled = await location.enableBackgroundMode(enable: true);

      if (!bgEnabled) {
        // Plugin says background not enabled (user did not choose "Allow all the time")
        _showBackgroundLocationDialog();
        return;
      }
    } on PlatformException catch (e) {
      debugPrint('enableBackgroundMode error: $e');
      _showBackgroundLocationDialog();
      return;
    }

    // Background mode is enabled successfully
    location.changeSettings(
      interval: 60000, // 60 seconds
      accuracy: loci.LocationAccuracy.high,
    );

    await _listenLocation();
  }

  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      debugPrint('Location error: $onError');
      _stopListening();
    }).listen((loci.LocationData currentLocation) async {
      try {
        // Make sure you have a class `loc` in Model/loc.dart
        final loc locationEntry = loc(
          longi: currentLocation.longitude.toString(),
          lat: currentLocation.latitude.toString(),
          // Proper ISO-ish formatting with literal 'T'
          time: DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS")
              .format(DateTime.now()),
        );

        repository.addloc(locationEntry.toMap());
      } catch (e) {
        debugPrint('Error saving location: $e');
      }
    });
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'Please grant location permission in app settings to continue.',
          ),
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

  void _showBackgroundLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Allow Background Location'),
          content: const Text(
            'To track your location in the background, open app settings and '
                'set Location permission to "Allow all the time".',
          ),
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
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _stopListening();
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
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}
