import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/Getx/Transaction.dart';
import 'package:inventory/Model/Transaction.dart';

class InvoiceScreen extends StatelessWidget {
  final TransactionController cartController = Get.put(TransactionController());
  Transaction transaction;
  InvoiceScreen({required this.transaction});


  @override
  Widget build(BuildContext context) {
    cartController.setCartItems(transaction.products as List<dynamic>);
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
        centerTitle: true,
        elevation: 5.0,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Cart',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 35.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Card(
                  elevation: 4.0,
                  color: Colors.grey[100],
                  child: ClipPath(
                    clipper: ShapeBorderClipper(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6))),
                    child: Container(
                      height: 100,
                      child: Obx(() => Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20, right: 11.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Items',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Price',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: cartController.cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartController.cartItems[index];
                                return ListTile(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible( // Wrapping the first Text widget with Flexible
                                        child: Text(
                                          '${item['name']}',
                                          overflow: TextOverflow.ellipsis, // Using ellipsis in case text is too long
                                          style: TextStyle(
                                            fontSize: 10.0,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      Text(
                                        'Rs.${item['price']}',
                                        style: TextStyle(
                                          fontSize: 10.0,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      Text(
                                        '${item['quantity']}',
                                        style: TextStyle(
                                          fontSize: 10.0,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      Text(
                                        'Rs.${item['flatdiscount']}',
                                        style: TextStyle(
                                          fontSize: 10.0,
                                        ),
                                      ),
                                    ],
                                  ),

                                );
                              },
                            ),
                          ),
                        ],
                      )),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Obx(() => Text(
                    'Subtotal: Rs.${cartController.subtotalValue}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                  SizedBox(height: 8),
                  Text(
                    'Flat Discount: - Rs.${cartController.DiscountValue}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'SGST of 2.5%: Rs.${cartController.CGSTValue}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'CGST of 2.5%: Rs.${cartController.CGSTValue}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Obx(() => Text(
                    'Total: Rs.${cartController.totalValue}',
                    style: TextStyle(
                      fontSize: 35.0,
                      fontWeight: FontWeight.w700,
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}