import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/Getx/Petrol.dart';
import 'package:inventory/Widget/actionbutton.dart';
import 'package:inventory/Widget/Camera.dart';
import 'package:inventory/Widget/Kilometer.dart';
import 'package:inventory/screens/qr_scanner.dart';
import 'package:inventory/Service/Api Service.dart';
import 'dart:io';
import 'package:inventory/Service/File storage.dart';
import 'package:inventory/Service/Bloc.dart';

class PetrolScreen extends StatelessWidget {
  final Controller controller = Get.put(Controller());
  Apirepository apirepository = Apirepository();
  Imagestorage imagestorage = Imagestorage();
  String? imgURL;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Petrol'),
      ),
      body:   Obx(() {
        return controller.isProcessing.value
            ? Center(child: CircularProgressIndicator()) // Loading spinner
            : SingleChildScrollView(
          child: Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: controller.setOpeningVehicle,
                child: Text("Opening Vehicle"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.setPetrol,
                child: Text("Petrol"),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: controller.setClosingVehicle,
                child: Text("Closing Vehicle"),
              ),
              SizedBox(height: 20),
              Obx(() {
                if (controller.message.value == 'Opening Vehicle!') {
                  return Column(
                    children: [
                      Center(
                          child: Text(
                            'Opening Kilometer',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      CustomTextField(
                        onChanged: (text) {
                          // You can use 'text' here to perform any operations or pass to other methods
                          controller.setTransactionId(text);
                        },
                        hintText: 'Enter the Opening Kilometer',
                        isInvalid: controller.isInvalid.value,
                      ),
                      CustomPhotoButton(
                          onPressed: () {
                            controller.takePicture();
                          },
                          buttonText: 'Take Picture of the Opening Kilometer'),
                      ActionButtonRow(onDiscardPressed: () {
                        Get.offAll(QRCodeScanner());
                      }, onReturnPressed: () async {
                        controller.isProcessing.value = true;
                        if (controller.pickedImage.value == null ||
                            controller.transactionId.value == null) {
                          // If any value is null or empty, show a dialog box.
                          Get.dialog(
                            AlertDialog(
                              title: Text("Error"),
                              content: Text(
                                  "Please ensure all fields are filled."),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Get.back(); // Close the dialog
                                  },
                                ),
                              ],
                            ),
                          );
                          return; // exit from the function so the rest of the code won't execute
                        }
                        String img = await imagestorage
                            .upload(File(controller.pickedImage.value!.path));
                        if (img != null || img != "") {
                          imgURL = SERVERURL + '/image/' + img;
                        }
                        Map map = {
                          'user_id': userBloc
                              .getUserObject()
                              .user
                              .toString(),
                          'morning_km': controller.transactionId.value,
                          'morningurl': imgURL,
                        };
                        apirepository.createLogbookEntry(map);
                        Get.offAll(QRCodeScanner());
                      })
                    ],
                  );
                } else if (controller.message.value == 'Closing Vehicle!') {
                  return Column(
                    children: [
                      Center(
                          child: Text(
                            'Closing Kilometer',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      CustomTextField(
                        onChanged: (text) {
                          // You can use 'text' here to perform any operations or pass to other methods
                          controller.setTransactionId(text);
                        },
                        hintText: 'Enter the Closing Kilometer',
                        isInvalid: controller.isInvalid.value,
                      ),
                      CustomPhotoButton(
                          onPressed: () {
                            controller.takePicture();
                          },
                          buttonText: 'Take Picture of the Closing Kilometer'),
                      ActionButtonRow(onDiscardPressed: () {
                        Get.offAll(QRCodeScanner());
                      }, onReturnPressed: () async {
                        controller.isProcessing.value = true;
                        if (controller.pickedImage.value == null ||
                            controller.transactionId.value == null) {
                          // If any value is null or empty, show a dialog box.
                          Get.dialog(
                            AlertDialog(
                              title: Text("Error"),
                              content: Text(
                                  "Please ensure all fields are filled."),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Get.back(); // Close the dialog
                                  },
                                ),
                              ],
                            ),
                          );
                          return; // exit from the function so the rest of the code won't execute
                        }
                        String img = await imagestorage
                            .upload(File(controller.pickedImage.value!.path));
                        if (img != null || img != "") {
                          imgURL = SERVERURL + '/image/' + img;
                        }
                        Map map = {
                          'user_id': userBloc
                              .getUserObject()
                              .user
                              .toString(),
                          'night_km': controller.transactionId.value,
                          'nighturl': imgURL,
                        };
                        apirepository.updateNightKm(map);
                        Get.offAll(QRCodeScanner());
                      })
                    ],
                  );
                } else if (controller.message.value == 'Petrol!') {
                  return Column(
                    children: [
                      Center(
                          child: Text(
                            'Petrol Kilometer',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: "Cost per Litre",
                                  hint: "Enter cost per litre",
                                  onChanged: (value) =>
                                  controller.costPerLitre
                                      .value = double.tryParse(value) ?? 0.0,
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: _buildTextField(
                                  label: "Fuel Filled Litres",
                                  hint: "Enter fuel filled in litres",
                                  onChanged: (value) =>
                                  controller
                                      .fuelFilledLitres
                                      .value = double.tryParse(value) ?? 0.0,
                                ),
                              ),
                              SizedBox(width: 30),
                              Expanded(
                                child: Obx(() {
                                  return Text(
                                    'Total: ${controller.totalAmount}',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  );
                                }),
                              ),
                            ],
                          )),
                      CustomTextField(
                        onChanged: (text) {
                          controller.setTransactionId(text);
                        },
                        hintText: 'Enter the Petrol Kilometer',
                        isInvalid: controller.isInvalid.value,
                      ),
                      CustomPhotoButton(
                          onPressed: () {
                            controller.takePicture();
                          },
                          buttonText: 'Take Picture of the Petrol Kilometer'),
                      ActionButtonRow(
                          onDiscardPressed: () {
                            Get.offAll(QRCodeScanner());
                          },
                          onReturnPressed: () async {
                            controller.isProcessing.value = true;
                            if (controller.pickedImage.value == null ||
                                controller.transactionId.value == null ||
                                controller.costPerLitre.value == null ||
                                controller.fuelFilledLitres.value == null) {
                              // If any value is null or empty, show a dialog box.
                              Get.dialog(
                                AlertDialog(
                                  title: Text("Error"),
                                  content: Text(
                                      "Please ensure all fields are filled."),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text("OK"),
                                      onPressed: () {
                                        Get.back(); // Close the dialog
                                      },
                                    ),
                                  ],
                                ),
                              );
                              return; // exit from the function so the rest of the code won't execute
                            }

                            String img = await imagestorage
                                .upload(
                                File(controller.pickedImage.value!.path));
                            if (img != null || img != "") {
                              imgURL = SERVERURL + '/image/' + img;
                            }
                            Map map = {
                              'user_id': userBloc
                                  .getUserObject()
                                  .user
                                  .toString(),
                              'fuelurl': imgURL,
                              'fuel_start_km': controller.transactionId.value,
                              'cost_per_litre': controller.costPerLitre.value,
                              'fuel_filled_litres': controller.fuelFilledLitres
                                  .value,
                            };
                            apirepository.updateFuelDetails(map);
                            Get.offAll(QRCodeScanner());
                          })
                    ],
                  );
                } else {
                  return SizedBox(); // Empty widget if none of the options are selected.
                }
              }),
            ],
          ),
          ),);
      }));
  }
}

Widget _buildTextField({
  required String label,
  required String hint,
  required Function(String) onChanged,
}) {
  return TextField(
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(),
    ),
    onChanged: onChanged,
  );
}
