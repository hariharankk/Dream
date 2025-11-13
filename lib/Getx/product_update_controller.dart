import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/Model/Product.dart';
import 'package:inventory/Service/Bloc.dart';
import 'package:inventory/Service/Repository.dart';

class ProductUpdateController extends GetxController {
  ProductUpdateController({required double initialPrice})
      : _initialPrice = initialPrice;

  final double _initialPrice;
  final Repository _repository = Repository();

  late final TextEditingController priceController;
  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    priceController =
        TextEditingController(text: _initialPrice.toStringAsFixed(2));
    super.onInit();
  }

  @override
  void onClose() {
    priceController.dispose();
    super.onClose();
  }

  Future<Product?> updatePrice(int productId) async {
    final enteredPrice = priceController.text.trim();
    final parsedPrice = double.tryParse(enteredPrice);

    if (parsedPrice == null) {
      errorMessage.value = 'Please enter a valid price';
      return null;
    }

    isSubmitting.value = true;
    errorMessage.value = null;

    try {
      final product = await _repository.updateProduct(
        productId: productId,
        data: {'price': parsedPrice},
      );
      await transactionbloc.fetchTotalAmount();
      return product;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      errorMessage.value = message.isEmpty
          ? 'Failed to update product price'
          : message;
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }
}