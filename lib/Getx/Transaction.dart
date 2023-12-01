import 'package:get/get.dart';

class TransactionController extends GetxController {
  var cartItems = [].obs;
  var subtotalValue = 0.0.obs;
  var CGSTValue = 0.0.obs;
  var SGSTValue = 0.0.obs;
  var DiscountValue = 0.0.obs;
  var totalValue = 0.0.obs;


  void updateValues() {
    // Calculate Subtotal
    subtotalValue.value = cartItems.fold(0.0, (sum, item) => sum + item['price']*item['quantity']);

    // Calculate GST (Combined CGST and SGST as they are usually equal)


    // Calculate Discount
    DiscountValue.value = cartItems.fold(0.0, (sum, item) => sum + (item['flatdiscount'] ?? 0)*item['quantity']);

    SGSTValue.value = (subtotalValue.value- DiscountValue.value) * 0.025; // 5% of subtotal (2.5% CGST + 2.5% SGST)

    CGSTValue.value = (subtotalValue.value- DiscountValue.value) * 0.025; // 5% of subtotal (2.5% CGST + 2.5% SGST)

    // Calculate Total
    totalValue.value = subtotalValue.value - DiscountValue.value  + CGSTValue.value +SGSTValue.value ;
  }


  void setCartItems(List items) {
    print(items);
    cartItems.assignAll(items);
    updateValues();
  }
}