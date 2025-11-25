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
    double subtotal = 0;
    double sgstTotal = 0;
    double cgstTotal = 0;

    for (final Product item in cartItems) {
      final double quantity = (item.quantity ?? 1).toDouble();
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
    totalValue.value = double.parse(
        (subtotalValue.value + CGSTValue.value + SGSTValue.value)
            .toStringAsFixed(2));
  }

  double _totalGstPercent(Product item) => (item.sgst + item.cgst);

  double _basePrice(Product item) {
    final double gstPercent = _totalGstPercent(item);
    if (gstPercent > 0) {
      return item.gstPrice / (1 + (gstPercent / 100));
    }
    return item.price;
  }
  double _sgstAmount(Product item, double basePrice) =>
      basePrice * (item.sgst / 100);

  double _cgstAmount(Product item, double basePrice) =>
      basePrice * (item.cgst / 100);

  double priceWithTax(Product item) {
    final double basePrice = _basePrice(item);
    return basePrice +
        _sgstAmount(item, basePrice) +
        _cgstAmount(item, basePrice);
  }

  double sgstAmountFor(Product item) => _sgstAmount(item, _basePrice(item));

  double cgstAmountFor(Product item) => _cgstAmount(item, _basePrice(item));

  double basePrice(Product item) => _basePrice(item);
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