import 'dart:async';
import 'package:inventory/Service/Api Service.dart';
import 'package:inventory/Model/Product.dart';


class Repository {
  final apiProvider = Apirepository();
  Future<dynamic> registerUser(Map<dynamic,dynamic> user) =>
      apiProvider.signUp(user);

  Future signinUser(String email, String password) =>
      apiProvider.signInWithEmail(email, password);


  Future currentuser() =>
      apiProvider.getCurrentUser();
  Future<List<dynamic>> getTransactions() => apiProvider.getTransactions();
  Future<dynamic> createTransaction(Map<dynamic, dynamic> transactionData) => apiProvider.createTransaction(transactionData);
  Future<Map<dynamic, dynamic>> getTotalAmount() => apiProvider.getTotalAmount();
  Future<Product> getProduct(String productId) => apiProvider.getProduct(productId);
  Future<List> getLocation(String userid) => apiProvider.getLocation(userid);
  Future addloc(Map<dynamic,dynamic> data) => apiProvider.addloc(data);
  Future<Product> updateProduct({
    required int productId,
    required Map<String, dynamic> data,
  }) => apiProvider.updateProduct(productId: productId, data: data);
}

final repository = Repository();
