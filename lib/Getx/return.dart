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
  double productGstPrice;

  ProductController({
    required this.productWeight,
    required this.productPrice,
    required this.productGstPrice,

  });

  // Call this function whenever user enters or updates the used weight
  void updateUsedWeight(String value) {
    if (value.isNotEmpty) {
      double parsedValue = double.parse(value);
      if (parsedValue > productWeight) {
        parsedValue = 0.0; // Limit the value to 5
        // Show a Snackbar message to the user
        Get.snackbar(
          'Invalid Input',
          'The entered value cannot be more than product weight.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      remainingWeight.value = parsedValue;

      // Calculate remaining weight
      usedWeight.value = double.parse((productWeight - remainingWeight.value).toStringAsFixed(2));
        // Convert back to double

// Calculate cost of used weight to be returned
      costOfUsed.value = double.parse(
          ((productGstPrice / productWeight) * remainingWeight.value)
              .toStringAsFixed(2));
        // Convert back to double
    } else {
      usedWeight.value = 0.0;
      remainingWeight.value = 0.0;
      costOfUsed.value = 0.0;
    }

    update(); // to notify listeners to update UI
  }
}
