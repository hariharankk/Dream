import 'package:get/get.dart';
import 'package:inventory/Model/Transaction.dart';
import 'package:inventory/Service/Api Service.dart';

class ProductController extends GetxController {
  // Observable variables
  Apirepository apirepository =Apirepository();
  var usedWeight = 0.0.obs;
  var remainingWeight = 0.0.obs;
  var costOfUsed = 0.0.obs;
  var transactionId = 0.obs;
  var isInvalid = false.obs;
  var transactionDetails = (null as Transaction?).obs;

  void setTransactionId(String value) {
    int? id = int.tryParse(value);
    if (id != null) {
      transactionId.value = id;
      fetchTransactionDetails();
      isInvalid.value = false;
    } else {
      isInvalid.value = true;
    }
  }

  Future<void> fetchTransactionDetails() async {

    var data = await  apirepository.getsingleTransactions(transactionId.value);
    transactionDetails.value = data;
    update();

  }
  // Assume the product details are initialized here
  double productWeight;
  double productPrice;

  ProductController({
    required this.productWeight,
    required this.productPrice,
  });

  // Call this function whenever user enters or updates the used weight
  void updateUsedWeight(String value) {
    if(value.isNotEmpty) {
      usedWeight.value = double.parse(value);

      // Calculate remaining weight
      remainingWeight.value = productWeight - usedWeight.value;

      // Calculate cost of used weight to be returned
      costOfUsed.value = (productPrice / productWeight) * remainingWeight.value;
    } else {
      usedWeight.value = 0.0;
      remainingWeight.value = 0.0;
      costOfUsed.value = 0.0;
    }

    update(); // to notify listeners to update UI
  }
}
