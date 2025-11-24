import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:inventory/Getx/cart screen.dart';
import 'package:inventory/Model/Product.dart';
import 'package:inventory/screens/Payment screen.dart';

class CartScreen extends StatefulWidget {
  CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController cartController = Get.find();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _customerFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = cartController.customerName.value;
    _phoneController.text = cartController.customerPhone.value;
    _addressController.text = cartController.customerAddress.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool _saveCustomerDetails() {
    final FormState? formState = _customerFormKey.currentState;
    if (formState == null) {
      return false;
    }
    if (!formState.validate()) {
      return false;
    }
    formState.save();

    cartController.setCustomerDetails(
      name: _nameController.text.trim().isEmpty ? null : _nameController.text,
      phone: _phoneController.text.trim(),
      address:
      _addressController.text.trim().isEmpty ? null : _addressController.text,
    );
    return true;
  }

  void _showEmptyCartDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cart is empty'),
        content: const Text('Please enter cart items'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  // ---------------- UI BUILD HELPERS ----------------

  Widget _buildCustomerDetailsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _customerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer details',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer name (optional)',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number *',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _addressController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Address (optional)',
                    prefixIcon: Icon(Icons.home_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartTitle() {
    return const Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: Text(
        'Cart',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 35.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  List<TableRow> _buildTableRows() {
    final List<TableRow> rows = [];

    // Header row
    rows.add(
      TableRow(
        children: [
          _buildHeaderCell('Name'),
          _buildHeaderCell('Price'),
          _buildHeaderCell('Quantity'),
          _buildHeaderCell('Total'),
          _buildHeaderCell('Reduce'),
          _buildHeaderCell('Delete'),
        ],
      ),
    );

    // Data rows
    for (Product item in cartController.cartItems) {
      rows.add(
        TableRow(
          children: [
            _buildBodyCell(
              item.name ?? '',
              maxLines: 3,
            ),
            _buildBodyCell('${item.price}'),
            _buildBodyCell('${item.quantity}'),
            _buildBodyCell(
              '${(item.price * (item.quantity ?? 1)).toStringAsFixed(0)}',
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                child: Icon(
                  MdiIcons.minusCircle,
                  color: Colors.redAccent,
                  size: 15,
                ),
                onPressed: () => cartController.reduceProductQuantity(item),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                child: Icon(
                  MdiIcons.delete,
                  color: Colors.redAccent,
                  size: 15,
                ),
                onPressed: () => cartController.removeItem(item),
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBodyCell(String text, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        style: const TextStyle(
          fontSize: 10.0,
        ),
      ),
    );
  }

  Widget _buildCartTable(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Card(
        elevation: 4.0,
        color: Colors.grey[100],
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Column(
            children: [
              Obx(
                    () => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: IntrinsicWidth(
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(6),
                            1: FlexColumnWidth(5),
                            2: FlexColumnWidth(5),
                            3: FlexColumnWidth(5),
                            4: FlexColumnWidth(5),
                            5: FlexColumnWidth(5),
                          },
                          border: TableBorder.all(),
                          children: _buildTableRows(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotals() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Obx(() => Text(
            'Subtotal: Rs.${cartController.subtotalValue.value.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          )),
          const SizedBox(height: 8),
          Obx(() => Text(
            'SGST of 2.5%: Rs.${cartController.SGSTValue.value.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          )),
          const SizedBox(height: 8),
          Obx(() => Text(
            'CGST of 2.5%: Rs.${cartController.CGSTValue.value.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          )),
          const SizedBox(height: 16),
          Obx(() => Text(
            'Total: Rs.${cartController.totalValue.value.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 35.0,
              fontWeight: FontWeight.w700,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
              ),
              onPressed: () {
                cartController.clearCart();
                Get.back();
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      'Abandon',
                      style: TextStyle(fontSize: 10.0),
                    ),
                    Icon(MdiIcons.closeCircle, size: 10),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
            ),
            onPressed: () {
              if (cartController.cartItems.isEmpty) {
                _showEmptyCartDialog();
              } else if (_saveCustomerDetails()) {
                Get.to(PaymentHomePage());
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 26.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    'Checkout',
                    style: TextStyle(fontSize: 10.0),
                  ),
                  Icon(
                    MdiIcons.logoutVariant,
                    size: 10,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Checkout'),
        centerTitle: true,
        elevation: 5.0,
        leading: TextButton(
          child: Icon(
            MdiIcons.arrowLeft,
            size: 30.0,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        // No PDF / SMS actions anymore
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCustomerDetailsCard(),
                _buildCartTitle(),
                _buildCartTable(context),
                _buildTotals(),
                _buildBottomButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
