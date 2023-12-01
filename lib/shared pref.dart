// Import necessary packages
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Function to store data
Future<void> storeData(List<Map<String, dynamic>> data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Convert List of maps to String
  String dataString = json.encode(data);

  // Store the data
  prefs.setString('stored_data', dataString);

}

// Function to delete stored data
Future<void> deleteStoredData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Remove the stored data key
  prefs.remove('stored_data');
}

// Function to check if data is stored
Future<bool> isDataStored() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Check if the stored_data key exists
  return prefs.containsKey('stored_data');
}

// Function to retrieve stored data
Future<List<Map<String, dynamic>>> retrieveData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve the data as String
  String? dataString = prefs.getString('stored_data');

  // Parse the String back to List of maps
  try {
    List<Map<String, dynamic>> data = (json.decode(dataString!) as List)
        .cast<Map<String, dynamic>>();
    print('Decoded data: $data');
    return data;
  } catch (e) {
    print('Error decoding data: $e');
    return [];
  }
}

// Function to save flag value to SharedPreferences
