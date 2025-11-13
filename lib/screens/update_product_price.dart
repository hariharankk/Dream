import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/Getx/product_update_controller.dart';
import 'package:inventory/Model/Product.dart';

class UpdateProductPricePage extends StatelessWidget {
  const UpdateProductPricePage({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ProductUpdateController(initialPrice: product.price),
    );

    return WillPopScope(
      onWillPop: () async {
        if (Get.isRegistered<ProductUpdateController>()) {
          await Get.delete<ProductUpdateController>();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Update ${product.name}'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current price: ${product.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Obx(
                    () => TextFormField(
                  controller: controller.priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'New Price',
                    prefixIcon: const Icon(Icons.currency_rupee),
                    errorText: controller.errorMessage.value,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                    () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () async {
                      final updatedProduct =
                      await controller.updatePrice(product.id);
                      if (updatedProduct != null) {
                        if (Get.isRegistered<ProductUpdateController>()) {
                          await Get.delete<ProductUpdateController>();
                        }
                        Get.back(result: updatedProduct);
                      }
                    },
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Update Price'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}