import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:inventory/Model/Product.dart';
import 'package:inventory/Model/Transaction.dart';
import 'package:inventory/utility.dart';
import 'package:inventory/Model/user.dart';
import 'dart:async';
import 'package:inventory/Model/loc.dart';
import 'package:inventory/Service/Bloc.dart';
import 'package:inventory/Model/return.dart';
import 'package:inventory/Model/polygon.dart';
import 'package:inventory/Model/Streets.dart';


String SERVERURL = 'http://1f5c-34-32-159-83.ngrok-free.app';

class Apirepository {

  late String Token;
  JWT jwt= JWT();


  Future<dynamic> signUp(Map<dynamic,dynamic> user) async{
    String URL = SERVERURL+'/register/';
    try {
      final response = await http.post(
        Uri.parse(URL),
        headers: <String, String>{
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(user),
      );
      var responseData = json.decode(response.body);
      if(responseData['status']){
        return User.fromMap(responseData["data"]);
      }
      else{
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  Future<dynamic> getCurrentUser() async {
    Token = await jwt.read_token();
    if(Token == null){
      return null;
    }
    String URL = SERVERURL+'/currentuser';
    final response = await http.get(Uri.parse(URL),
      headers: <String, String>{
        'x-access-token': Token
      },
    );
    try {
    var responseData = json.decode(response.body);
    User user = User.fromMap(responseData);//list, alternative empty string " "
    return user;
  } catch (e) {
  return null;
  }
  }

  Future<void> signOut() async {
    await jwt.delete_token();
  }


  Future<dynamic> signInWithEmail(String email, String password) async{
    String URL = SERVERURL+'/login';
    try {
      final response = await http.post(
        Uri.parse(URL),
        headers: <String, String>{
          "Access-Control-Allow-Origin": "*",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(<String,String>{'emailaddress':email,'password':password}),
      );
      var responseData = json.decode(response.body);
      if(responseData['status']){
        await jwt.store_token(responseData['token']);
        return User.fromMap(responseData["data"]);
      }
      else{
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> signInWithOTP(String phone, String verificationId) async{
    String URL = SERVERURL+'/verifyOTP';
    try {
      final response = await http.post(
        Uri.parse(URL),
        headers: <String, String>{
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(<String,String>{'phonenumber':phone,'verification-code':verificationId}),
      );
      var responseData = json.decode(response.body);
      if(responseData['status']){
        await jwt.store_token(responseData['token']);
        return User.fromMap(responseData["data"]);
      }
      else{
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> sendotp(String phone) async{
    String URL = SERVERURL+'/getOTP';
    try {
      final response = await http.post(
        Uri.parse(URL),
        headers: <String, String>{
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(<String,String>{'phonenumber':phone}),
      );
      var responseData = json.decode(response.body);
      if(responseData['status']){
        return responseData['code'];
      }
      else{
        return '';
      }
    } catch (e) {
      return '';
    }
  }


  Future<Product> getProduct(String productId) async {
    var userid = userBloc.getUserObject().user;
    String url = SERVERURL + '/user/products/getdata?user_id=$userid&product_id=$productId';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, then parse the JSON.
        Map<String, dynamic> productData = jsonDecode(response.body);

        // If status is true, return product data
        if (productData['status'] == true) {
          return Product.fromJson(productData['product']);
        } else {
          // If status is false, print an error message and throw an exception
          throw Exception(productData['message']);
        }
      } else {
        // If the server did not return a 200 OK response, print an error message and throw an exception
        throw Exception('Failed to load product, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load product, exception thrown: $e');
    }
  }


  Future<List<dynamic>> getTransactions() async {
    final queryParameters = {'user_id':userBloc.getUserObject().user.toString()};
    final String url = SERVERURL+'/transactions/all';
    try {
      final response = await http.get(Uri.parse(url).replace( queryParameters: queryParameters));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true) {
          List<dynamic> transactions = [];
          transactions = jsonResponse['transactions'].map((snapshot) {
            Transaction transaction = Transaction.fromJson(snapshot);
            return transaction;
          }).toList();

          return transactions;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<dynamic> getsingleTransactions(int productid) async {
    final queryParameters = {'user_id':userBloc.getUserObject().user.toString(),'transaction_id':productid.toString()};
    final String url = SERVERURL+'/transactions/single';
    //try {
      final response = await http.get(Uri.parse(url).replace( queryParameters: queryParameters));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true) {
          Transaction transaction = Transaction.fromJson(jsonResponse['transaction']);
          return transaction;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } //catch (e) {
      //return [];
    //}
  //}

  Future<dynamic> createTransaction(Map<dynamic, dynamic> transactionData) async {
    String url = SERVERURL + '/transactions/add';
    transactionData['user_id'] = userBloc.getUserObject().user;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(transactionData),
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          return Transaction.fromJson(responseData['transaction']);
        } else {
          // If status is false, print an error message and throw an exception
          throw Exception(responseData['message']);
        }
      } else {
        // If the server did not return a 201 Created response, print an error message and throw an exception
        throw Exception('Failed to create transaction, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create transaction, exception thrown: $e');
    }
  }

  Future<Map<dynamic, dynamic>> getTotalAmount() async {
    final queryParameters = {'user_id':userBloc.getUserObject().user.toString()};
    String url = SERVERURL+'/transactions/total_amount';
    //try {
      final response = await http.get(Uri.parse(url).replace( queryParameters: queryParameters));

      if (response.statusCode == 200) {

        // If the server returns a 200 OK response, then parse the JSON.
        Map<dynamic, dynamic> data = jsonDecode(response.body);


        // If status is true, return the parsed data
        //if (data['status'] == true) {
          List<Product> products = [];
          products = (data['products'] as List).map((i) {
            return Product.fromJson(i);
          }).toList();

          double totalStockValue = data['total_stock_value'].toDouble();
          double cashTotal = data['cash_total'].toDouble();
          double upiTotal = data['upi_total'].toDouble();
          double total_return_amount = data['total_return_amount'].toDouble();
          double Commision = data['Commision'].toDouble();
          double cash_on_hand = data['cash_on_hand'].toDouble();
          double fuel_value_today = data['fuel_value_today'].toDouble();

        return {
            'products': products,
            'total_stock_value': totalStockValue,
            'cash_total': cashTotal,
            'upi_total': upiTotal,
            'total_return_amount':total_return_amount,
            'Commision':Commision,
            'fuel_value_today':fuel_value_today,
            'cash_on_hand' : cash_on_hand
          };
        //} else {
          // If status is false, throw an exception with the provided message
          //throw Exception('Error: ${data['error']}');
        //}
      } else {
        // If the server did not return a 200 OK response, then throw an exception.
        throw Exception('Failed to load total amount');
      }
    } //catch (e) {
      //throw Exception('Failed to load total amount, exception thrown: $e');
    //}
  //}

  Future<List> getLocation(String userid) async {
    final queryParameters = {'userid':userid};
    String Locationget = SERVERURL+ '/api/location-get';
    List<loc> locs = [];
    final response = await http.get(
      Uri.parse(Locationget).replace( queryParameters: queryParameters),
      headers: {
        "Access-Control-Allow-Origin": "*", // Required for CORS support to work
        "Access-Control-Allow-Credentials": 'true', // Required for cookies, authorization headers with HTTPS
        "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
      },
    );
    final Map result = json.decode(response.body);

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      for (Map<String, dynamic> json_ in result["data"]) {
        print(json_);
        try {
          loc Loc = loc.fromJson(json_);
          locs.add(Loc);
        } catch (Exception) {
          print(Exception);
        }
      }
      return locs;
    } else {
      // If that call was not successful, throw an error.
      throw Exception(result["status"]);
    }

  }

  /// Add a Group
  Future addloc(Map<dynamic,dynamic> data) async {
    String Locposturl = SERVERURL + '/api/location-add';
    data['userid']=userBloc.getUserObject().user;

    final response = await http.post(
      Uri.parse(Locposturl),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      final Map result = json.decode(response.body);

      loc Loc = loc.fromJson(result["data"]);
      //print("Group: " + addedGroup.name + " added");
      return Loc;
    } else {
      // If that call was not successful, throw an error.
      final Map result = json.decode(response.body);
      print(result["status"]);
      throw Exception(result["status"]);
    }
  }

  Future<dynamic> addreturn(Map<dynamic,dynamic> data) async{
    String URL = SERVERURL+'/returns/add';
    try {
      print(data);
      final response = await http.post(
        Uri.parse(URL),
        headers: <String, String>{
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );
      var responseData = json.decode(response.body);
      if(responseData['status']){
        print(responseData['return_data']);
        return Returnprod.fromJson(responseData["return_data"]);
      }
      else{
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> createLogbookEntry(Map<dynamic, dynamic> logbookData) async {
    String url = SERVERURL + '/user/logbook/create';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(logbookData),
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          return responseData['id'];  // Return the created logbook entry's ID
        } else {
          throw Exception(responseData['message']);
        }
      } else {
        throw Exception('Failed to create logbook entry, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create logbook entry, exception thrown: $e');
    }
  }

  Future<dynamic> updateFuelDetails(Map<dynamic, dynamic> fuelData) async {
    String url = SERVERURL + '/user/logbook/update_fuel';
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(fuelData),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          return true;
        } else {
          throw Exception(responseData['message']);
        }
      } else {
        throw Exception('Failed to update fuel details, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update fuel details, exception thrown: $e');
    }
  }

  Future<dynamic> updateNightKm(Map<dynamic, dynamic> nightKmData) async {
    print(nightKmData);
    String url = SERVERURL + '/user/logbook/update_night_km';
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(nightKmData),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          return true;
        } else {
          throw Exception(responseData['message']);
        }
      } else {
        throw Exception('Failed to update night kilometer, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update night kilometer, exception thrown: $e');
    }
  }

  Future<List<PolygonModel>> fetchPolygons() async {
    //var userId = userBloc.getUserObject().user;
    var userId = 1;
    String url = '$SERVERURL/user/polygons?user_id=$userId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, parse the JSON
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['status'] == true) {
        // If status is true, parse the polygon data
        List<dynamic> polygonsJson = data['polygons'];

        return polygonsJson.map((json) => PolygonModel.fromJson(json)).toList();
      } else {
        // If status is false, throw an exception with the message from the server
        throw Exception(data['message']);
      }
    } else {
      // If the server did not return a 200 OK response, throw an exception
      throw Exception('Failed to load polygons, status code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchStreetsByPolygon(String polygonId) async {
    String url = '$SERVERURL/streets?polygon_id=$polygonId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, parse the JSON
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['status'] == true) {
        // If status is true, parse the streets data and Eulerian circuit
        List<dynamic> streetsJson = data['streets'];
        var eulerCircuit = data['euler_circuit']; // This needs to be serializable data
        List<dynamic> streets = streetsJson.map((json) => StreetModel.fromJson(json)).toList();

        // Return a map with both streets and eulerCircuit
        return {
          'streets': streets,
          'eulerCircuit': eulerCircuit,
        };
      } else {
        // If status is false, throw an exception with the message from the server
        throw Exception(data['message']);
      }
    } else {
      // If the server did not return a 200 OK response, throw an exception
      throw Exception('Failed to load streets, status code: ${response.statusCode}');
    }
  }

// Function to update street details
  Future<bool> updateStreet(int streetId, String delStatus, String delType, String delReason) async {
    String url = '$SERVERURL/update_street';

    // Prepare the data to be sent in the request
    Map<String, dynamic> updateData = {
      'street_id': streetId,
      'del_status': delStatus,
      'del_type': delType,
      'del_reason': delReason,
    };

    try {
      // Send the PATCH request
      final response = await http.patch(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        // Encoding the data to JSON
        body: jsonEncode(updateData),
      );

      // Handle the response from the server
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          return true;
        } else {
          throw Exception(responseData['message']);
        }
      } else {
        throw Exception('Failed to update street details, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update street details, exception thrown: $e');
    }
  }

}

