import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Controller extends GetxController {
  var message = ''.obs;
  Rx<XFile?> pickedImage = Rx<XFile?>(null);
  var transactionId = 0.obs;
  var isInvalid = false.obs;
  var isProcessing = false.obs;


  RxDouble costPerLitre = 0.0.obs;
  RxDouble fuelFilledLitres = 0.0.obs;

  double get totalAmount => double.parse((costPerLitre.value * fuelFilledLitres.value).toStringAsFixed(0));

  void setTransactionId(String value) {
    int? id = int.tryParse(value);
    if (id != null) {
      transactionId.value = id;
      isInvalid.value = false;
    } else {
      isInvalid.value = true;
    }
  }

  void setOpeningVehicle() {
    message.value = "Opening Vehicle!";
  }

  void setClosingVehicle() {
    message.value = "Closing Vehicle!";
  }

  void setPetrol() {
    message.value = "Petrol!";
  }

  // Integrated code

  Future<void> takePicture() async {
    final picker = ImagePicker();
    final pickedImageValue = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear);
    pickedImage.value = pickedImageValue;
  }


}

