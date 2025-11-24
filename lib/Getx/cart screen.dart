import 'package:get/get.dart';
import 'package:inventory/Model/Product.dart';

class CartController extends GetxController {
  var cartItems = [].obs;
  var subtotalValue = 0.0.obs;
  var CGSTValue = 0.0.obs;
  var SGSTValue = 0.0.obs;
  var totalValue = 0.0.obs;
  var customerName = ''.obs;
  var customerPhone = ''.obs;
  var customerAddress = ''.obs;



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

  void reduceProductQuantity(Product product) {
    var existingProduct = cartItems.firstWhere((element) => element.id == product.id);
    if (existingProduct.quantity > 1) {
      existingProduct.quantity--;
      cartItems.refresh();
    } else {
      cartItems.remove(product);
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
    subtotalValue.value = double.parse(
        cartItems
            .fold(0.0,
                (sum, item) => sum + item.price * (item.quantity ?? 1))
            .toStringAsFixed(0));

// Calculate GST (Combined CGST and SGST as they are usually equal)

// Calculate Discount
    SGSTValue.value = double.parse((subtotalValue.value * 0.025).toStringAsFixed(2));
    CGSTValue.value = double.parse((subtotalValue.value * 0.025).toStringAsFixed(2));
// Calculate Total
    totalValue.value = double.parse((subtotalValue.value + CGSTValue.value + SGSTValue.value).toStringAsFixed(0));
  }
  void setCustomerDetails({String? name, required String phone, String? address}) {
    customerName.value = name?.trim() ?? '';
    customerPhone.value = phone.trim();
    customerAddress.value = address?.trim() ?? '';
  }

  String? get customerNameOrNull => customerName.value.isEmpty ? null : customerName.value;

  String? get customerAddressOrNull => customerAddress.value.isEmpty ? null : customerAddress.value;

  void clearCart() {
    cartItems.clear();
    customerName.value = '';
    customerPhone.value = '';
    customerAddress.value = '';
    updateValues();
  }
}