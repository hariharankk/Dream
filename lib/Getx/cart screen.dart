import 'package:get/get.dart';
import 'package:inventory/Model/Product.dart';

class CartController extends GetxController {
  var cartItems = [].obs;
  var subtotalValue = 0.0.obs;
  var CGSTValue = 0.0.obs;
  var SGSTValue = 0.0.obs;
  var DiscountValue = 0.0.obs;
  var totalValue = 0.0.obs;

  void addProduct(Product product) {
    if (cartItems.any((element) => element.id == product.id)) {
      var existingProduct = cartItems.firstWhere((element) => element.id == product.id);
      existingProduct.quantity++;
    } else {
      product.quantity = 1;
      cartItems.add(product);
    }
    updateValues();
  }

  int get cartValue {
    return cartItems.length;
  }

  void removeItem(var item) {
    cartItems.remove(item);

    updateValues();
  }

  void updateValues() {
    // Calculate Subtotal
    subtotalValue.value = cartItems.fold(0.0, (sum, item) => sum + item.price* (item.quantity??1));

    // Calculate GST (Combined CGST and SGST as they are usually equal)


    // Calculate Discount
    DiscountValue.value = cartItems.fold(0.0, (sum, item) => sum + (item.flatdiscount ?? 0)*(item.quantity??1));
    SGSTValue.value = (subtotalValue.value- DiscountValue.value) * 0.025; // 5% of subtotal (2.5% CGST + 2.5% SGST)

    CGSTValue.value = (subtotalValue.value- DiscountValue.value) * 0.025; // 5% of subtotal (2.5% CGST + 2.5% SGST)

    // Calculate Total
    totalValue.value = subtotalValue.value - DiscountValue.value + CGSTValue.value +SGSTValue.value;
  }

  void clearCart() {
    cartItems.clear();
    updateValues();
  }
}