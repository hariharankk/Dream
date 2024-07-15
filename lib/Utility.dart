import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'dart:html' as html; // Import the html package
import 'package:latlong2/latlong.dart';

class JWT{
  final storage = const FlutterSecureStorage();

  Future<void> store_token(var data)async{
    await storage.write(key: 'token', value: data);
  }

  Future<dynamic> read_token()async{
    var value = await storage.read(key: 'token');
    return value;
  }

  Future<void> delete_token()async{
    await storage.deleteAll();
  }

}


Future<void> openMapWithDirections(double startLat, double startLng, double destLat, double destLng) async {
  final String googleMapsUrl = "google.navigation:q=$destLat,$destLng&mode=d";
  final String encodedUrl = Uri.encodeFull(googleMapsUrl);

  try {
    final bool launched = await launch(encodedUrl);
    if (!launched) {
      // Fall back to launching a URL if we can't launch the intent
      await launchUrl(Uri.parse("https://www.google.com/maps/search/?api=1&query=$destLat,$destLng"));
    }
  } on PlatformException catch (e) {
    // Handle the exception, could not launch Google Maps
    print('Could not launch Google Maps: $e');
  }
}

/*Future<void> webOpenMapWithDirections(double startLat, double startLng, double destLat, double destLng) async {
  final String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$destLat,$destLng";

  print('Opening URL: $googleMapsUrl');

  // Open the URL in a new tab
  html.window.open(googleMapsUrl, '_blank');
}
*/
LatLng COMPANY_LOCATION =LatLng(9.873120985915538, 78.13299116183676);