import 'package:get/get.dart';

class TransactionController extends GetxController {
  var cartItems = [].obs;
  var subtotalValue = 0.0.obs;
  var CGSTValue = 0.0.obs;
  var SGSTValue = 0.0.obs;

  var totalValue = 0.0.obs;



  void updateValues() {
    // Calculate Subtotal
    double subtotal = 0;
    double sgstTotal = 0;
    double cgstTotal = 0;
    // Calculate GST (Combined CGST and SGST as they are usually equal)
    for (final dynamic item in cartItems) {
      final double quantity = _toDouble(item['quantity']);
      final double basePrice = _basePrice(item);
      final double sgstAmount = _sgstAmount(item, basePrice);
      final double cgstAmount = _cgstAmount(item, basePrice);
      subtotal += basePrice * quantity;
      sgstTotal += sgstAmount * quantity;
      cgstTotal += cgstAmount * quantity;
    }
    subtotalValue.value = double.parse(subtotal.toStringAsFixed(2));
    SGSTValue.value = double.parse(sgstTotal.toStringAsFixed(2));
    CGSTValue.value = double.parse(cgstTotal.toStringAsFixed(2));
    totalValue.value = double.parse((subtotalValue.value + CGSTValue.value + SGSTValue.value).toStringAsFixed(2));
// Calculate Total
    totalValue.value = double.parse((subtotalValue.value + CGSTValue.value + SGSTValue.value).toStringAsFixed(0));
  }


  void setCartItems(List items) {
    print(items);
    cartItems.assignAll(items);
    updateValues();
  }
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  double _totalGstPercent(dynamic item) => _toDouble(item['sgst']) + _toDouble(item['cgst']);

  double _basePrice(dynamic item) {
    final double gstPercent = _totalGstPercent(item);
    final double priceWithTax = _toDouble(item['price']);
    if (gstPercent > 0) {
      return priceWithTax / (1 + (gstPercent / 100));
    }
    return priceWithTax;
  }

  double _sgstAmount(dynamic item, double basePrice) => basePrice * (_toDouble(item['sgst']) / 100);

  double _cgstAmount(dynamic item, double basePrice) => basePrice * (_toDouble(item['cgst']) / 100);

  double priceWithTax(dynamic item) {
    final double basePrice = _basePrice(item);
    return basePrice + _sgstAmount(item, basePrice) + _cgstAmount(item, basePrice);
  }

  double sgstAmountFor(dynamic item) => _sgstAmount(item, _basePrice(item));

  double cgstAmountFor(dynamic item) => _cgstAmount(item, _basePrice(item));
}