import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/controller/farmer/famer_controller.dart';
import 'package:phum_kasikors/view/farmer/ui/farmer_ui.dart';

import '../../../model/farmer/product_model.dart';


class FarmerAddProductScreen extends StatefulWidget {
  const FarmerAddProductScreen({super.key});
  @override
  State<FarmerAddProductScreen> createState() => _FarmerAddProductScreenState();
}

class _FarmerAddProductScreenState extends State<FarmerAddProductScreen> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  final _description = TextEditingController();
  String _unit = 'kg';

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FarmerPage(
    title: 'Add New Product',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        FarmerTextField(
          label: 'Product name',
          hint: 'e.g. Premium Jasmine Rice',
          controller: _name,
        ),
        Row(
          children: [
            Expanded(
              child: FarmerTextField(
                label: 'Price',
                hint: '0.00',
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _unit,
                decoration: const InputDecoration(labelText: 'Unit'),
                items: const [
                  DropdownMenuItem(value: 'kg', child: Text('kg')),
                  DropdownMenuItem(value: 'bag', child: Text('bag')),
                  DropdownMenuItem(value: 'piece', child: Text('piece')),
                ],
                onChanged: (value) => setState(() => _unit = value ?? 'kg'),
              ),
            ),
          ],
        ),
        FarmerTextField(
          label: 'Available stock',
          hint: '0',
          controller: _stock,
          keyboardType: TextInputType.number,
        ),
        FarmerTextField(
          label: 'Description',
          hint: 'Tell customers about this product',
          controller: _description,
          maxLines: 4,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            final price = double.tryParse(_price.text.trim());
            final stock = int.tryParse(_stock.text.trim());
            if (_name.text.trim().isEmpty || price == null || stock == null) {
              Get.snackbar(
                'Check product details',
                'Add a product name, valid price, and stock amount.',
              );
              return;
            }
            Get.find<FarmerController>().addProduct(
              ProductModel(
                id: 'product-${DateTime.now().millisecondsSinceEpoch}',
                farmId: 'farm-1',
                name: _name.text.trim(),
                price: price,
                stock: stock,
                unit: _unit,
                description: _description.text.trim(),
              ),
            );
            Get.back();
            Get.snackbar(
              'Product published',
              '${_name.text.trim()} is now available in your catalog.',
            );
          },
          child: const Text('Publish product'),
        ),
      ],
    ),
  );
}
