import 'package:get/get.dart';

class ReasonController extends GetxController {
  var selectedOption = 'Option 1'.obs; // Observable variable
  var enteredReason = ''.obs; // Observable variable

  void setSelectedOption(String value) => selectedOption.value = value;
  void setEnteredReason(String value) => enteredReason.value = value;
}
