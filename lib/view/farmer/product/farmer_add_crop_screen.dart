import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/controller/farmer/famer_controller.dart';
import 'package:phum_kasikors/model/farmer/crop_model.dart';
import 'package:phum_kasikors/view/farmer/ui/farmer_ui.dart';

class FarmerAddCropScreen extends StatefulWidget {
  const FarmerAddCropScreen({super.key});
  @override
  State<FarmerAddCropScreen> createState() => _FarmerAddCropScreenState();
}

class _FarmerAddCropScreenState extends State<FarmerAddCropScreen> {
  final _name = TextEditingController();
  DateTime _plantedAt = DateTime.now();
  DateTime _harvestAt = DateTime.now().add(const Duration(days: 90));

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FarmerPage(
    title: 'Add New Crop',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        FarmerTextField(
          label: 'Crop name',
          hint: 'e.g. Jasmine Rice',
          controller: _name,
        ),
        _DateField(
          label: 'Planting date',
          value: _plantedAt,
          onPick: (value) => setState(() => _plantedAt = value),
        ),
        _DateField(
          label: 'Expected harvest',
          value: _harvestAt,
          onPick: (value) => setState(() => _harvestAt = value),
        ),
        const SizedBox(height: 14),
        ElevatedButton(
          onPressed: () {
            if (_name.text.trim().isEmpty) {
              Get.snackbar(
                'Crop name required',
                'Enter the name of the crop you are planting.',
              );
              return;
            }
            Get.find<FarmerController>().addCrop(
              CropModel(
                id: 'crop-${DateTime.now().millisecondsSinceEpoch}',
                farmId: 'farm-1',
                name: _name.text.trim(),
                plantedAt: _plantedAt,
                expectedHarvestAt: _harvestAt,
              ),
            );
            Get.back();
          },
          child: const Text('Save crop'),
        ),
      ],
    ),
  );
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
  });
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onPick;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text('${value.day}/${value.month}/${value.year}'),
    trailing: const Icon(Icons.calendar_month_outlined),
    onTap: () async {
      final chosen = await showDatePicker(
        context: context,
        initialDate: value,
        firstDate: DateTime(2020),
        lastDate: DateTime(2035),
      );
      if (chosen != null) onPick(chosen);
    },
  );
}
