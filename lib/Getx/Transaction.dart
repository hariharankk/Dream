import 'package:get/get.dart';

class TransactionController extends GetxController {
  var cartItems = [].obs;
  var subtotalValue = 0.0.obs;
  var CGSTValue = 0.0.obs;
  var SGSTValue = 0.0.obs;
  var DiscountValue = 0.0.obs;
  var totalValue = 0.0.obs;
  var totalafterdiscount = 0.0.obs;


  void updateValues() {
    // Calculate Subtotal
    subtotalValue.value = double.parse((cartItems.fold(0.0, (sum, item) => sum + item['price']*item['quantity'])).toStringAsFixed(0));

    // Calculate GST (Combined CGST and SGST as they are usually equal)


    // Calculate Discount
    DiscountValue.value = double.parse((cartItems.fold(0.0, (sum, item) => sum + (item['flatdiscount'] ?? 0)*item['quantity'])).toStringAsFixed(0));
    totalafterdiscount.value = double.parse((subtotalValue.value-DiscountValue.value).toStringAsFixed(0));

    SGSTValue.value = double.parse(((subtotalValue.value - DiscountValue.value) * 0.025).toStringAsFixed(2)); // 5% of subtotal (2.5% CGST + 2.5% SGST)

    CGSTValue.value = double.parse(((subtotalValue.value - DiscountValue.value) * 0.025).toStringAsFixed(2)); // 5% of subtotal (2.5% CGST + 2.5% SGST)

// Calculate Total
    totalValue.value = double.parse((subtotalValue.value - DiscountValue.value + CGSTValue.value + SGSTValue.value).toStringAsFixed(0));
  }


  void setCartItems(List items) {
    print(items);
    cartItems.assignAll(items);
    updateValues();
  }
}