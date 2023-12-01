import 'dart:async';
import 'package:inventory/Service/Api Service.dart';
import 'package:inventory/Model/Product.dart';
import 'package:inventory/Model/polygon.dart';

class Repository {
  final apiProvider = Apirepository();
  Future<dynamic> registerUser(Map<dynamic,dynamic> user) =>
      apiProvider.signUp(user);

  Future signinUser(String email, String password) =>
      apiProvider.signInWithEmail(email, password);

  Future phonesigninUser(String phone, String verificationId) =>
      apiProvider.signInWithOTP(phone, verificationId);

  Future currentuser() =>
      apiProvider.getCurrentUser();
  Future<List<dynamic>> getTransactions() => apiProvider.getTransactions();
  Future<dynamic> createTransaction(Map<dynamic, dynamic> transactionData) => apiProvider.createTransaction(transactionData);
  Future<Map<dynamic, dynamic>> getTotalAmount() => apiProvider.getTotalAmount();
  Future<Product> getProduct(String productId) => apiProvider.getProduct(productId);
  Future<List> getLocation(String userid) => apiProvider.getLocation(userid);
  Future addloc(Map<dynamic,dynamic> data) => apiProvider.addloc(data);
  Future<List<PolygonModel>> fetchPolygons() => apiProvider.fetchPolygons();

  Future<Map<String, dynamic>> fetchStreetsByPolygon(String polygonId) => apiProvider.fetchStreetsByPolygon(polygonId);

  Future<bool> updateStreet(int streetId, String delStatus, String delType, String delReason) => apiProvider.updateStreet(streetId, delStatus, delType, delReason);

}

final repository = Repository();
