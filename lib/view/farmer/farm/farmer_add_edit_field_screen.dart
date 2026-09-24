import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/controller/farmer/field_controller.dart';
import 'package:phum_kasikors/model/farmer/field_model.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';

class FarmerAddEditFieldScreen extends StatefulWidget {
  const FarmerAddEditFieldScreen({
    super.key,
    this.farmId,
    this.fieldId,
  });

  final String? farmId;
  final String? fieldId;

  bool get isEditing =>
      fieldId != null && fieldId!.trim().isNotEmpty;

  @override
  State<FarmerAddEditFieldScreen> createState() =>
      _FarmerAddEditFieldScreenState();
}

class _FarmerAddEditFieldScreenState
    extends State<FarmerAddEditFieldScreen> {
  late final FieldController controller;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _soilTypeController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _initialized = false;

  String get farmId => widget.farmId?.trim() ?? '';

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<FieldController>()
        ? Get.find<FieldController>()
        : Get.put(FieldController());

    _loadExistingField();
  }

  void _loadExistingField() {
    if (!widget.isEditing) {
      _initialized = true;
      return;
    }

    final fieldId = widget.fieldId!;

    final field = controller.getFieldById(fieldId);

    if (field != null) {
      _fillForm(field);
      _initialized = true;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (farmId.isEmpty) {
        _initialized = true;
        return;
      }

      await controller.loadFields(farmId);

      if (!mounted) {
        return;
      }

      final loadedField = controller.getFieldById(fieldId);

      if (loadedField != null) {
        _fillForm(loadedField);
      }

      setState(() {
        _initialized = true;
      });
    });
  }

  void _fillForm(FieldModel field) {
    _nameController.text = field.name;
    _areaController.text =
        field.area == null ? '' : _formatNumber(field.area!);
    _soilTypeController.text = field.soilType ?? '';
    _descriptionController.text = field.description ?? '';
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _soilTypeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (farmId.isEmpty) {
      _showError('Farm information is missing.');
      return;
    }

    final name = _nameController.text.trim();
    final areaText = _areaController.text.trim();
    final soilType = _soilTypeController.text.trim();
    final description = _descriptionController.text.trim();

    double? area;

    if (areaText.isNotEmpty) {
      area = double.tryParse(areaText);

      if (area == null) {
        _showError('Please enter a valid area.');
        return;
      }

      if (area <= 0) {
        _showError('Area must be greater than 0.');
        return;
      }
    }

    bool success;

    if (widget.isEditing) {
      final data = <String, dynamic>{
        'name': name,
        if (area != null) 'area': area,
        if (soilType.isNotEmpty) 'soil_type': soilType,
        if (description.isNotEmpty) 'description': description,
      };

      success = await controller.updateField(
        farmId: farmId,
        fieldId: widget.fieldId!,
        data: data,
      );
    } else {
      success = await controller.createField(
        farmId: farmId,
        name: name,
        area: area,
        soilType: soilType.isEmpty ? null : soilType,
        description: description.isEmpty ? null : description,
      );
    }

    if (!mounted) {
      return;
    }

    if (success) {
      Get.back(result: true);

      Get.snackbar(
        widget.isEditing ? 'Field updated' : 'Field created',
        widget.isEditing
            ? 'Your field has been updated successfully.'
            : 'Your new field has been added successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: FarmerDesign.primaryDark,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
    } else {
      _showError(
        controller.errorMessage.value.isEmpty
            ? 'Something went wrong. Please try again.'
            : controller.errorMessage.value,
      );
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Unable to save',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: FarmerDesign.error,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Edit field' : 'Add field';

    return Scaffold(
      backgroundColor: FarmerDesign.background,
      appBar: AppBar(
        backgroundColor: FarmerDesign.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: FarmerDesign.heading2,
        ),
      ),
      body: !_initialized && widget.isEditing
          ? const Center(
              child: CircularProgressIndicator(
                color: FarmerDesign.primary,
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  32,
                ),
                children: [
                  _HeaderCard(
                    isEditing: widget.isEditing,
                  ),
                  const SizedBox(height: 22),

                  const Text(
                    'Field information',
                    style: FarmerDesign.heading3,
                  ),
                  const SizedBox(height: 12),

                  _FieldInput(
                    controller: _nameController,
                    label: 'Field name',
                    hint: 'e.g. North Field',
                    icon: Icons.grid_view_rounded,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Field name is required';
                      }

                      if (value.trim().length < 2) {
                        return 'Field name is too short';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  _FieldInput(
                    controller: _areaController,
                    label: 'Area',
                    hint: 'e.g. 2.5',
                    suffixText: 'hectares',
                    icon: Icons.square_foot_rounded,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';

                      if (text.isEmpty) {
                        return null;
                      }

                      final parsed = double.tryParse(text);

                      if (parsed == null) {
                        return 'Enter a valid number';
                      }

                      if (parsed <= 0) {
                        return 'Area must be greater than 0';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  _FieldInput(
                    controller: _soilTypeController,
                    label: 'Soil type',
                    hint: 'e.g. Clay, Sandy, Loamy',
                    icon: Icons.layers_outlined,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 14),

                  _FieldInput(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Add notes about this field',
                    icon: Icons.notes_rounded,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 26),

                  Obx(
                    () => SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed:
                            controller.isSaving.value ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: FarmerDesign.primary,
                          disabledBackgroundColor:
                              FarmerDesign.primary.withValues(
                            alpha: 0.45,
                          ),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: controller.isSaving.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                widget.isEditing
                                    ? 'Save changes'
                                    : 'Create field',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.isEditing,
  });

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FarmerDesign.primaryLight,
        borderRadius: BorderRadius.circular(
          FarmerDesign.radiusLarge,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              color: FarmerDesign.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing
                      ? 'Update your field'
                      : 'Create a new field',
                  style: FarmerDesign.heading3,
                ),
                const SizedBox(height: 5),
                Text(
                  isEditing
                      ? 'Keep your field information accurate.'
                      : 'Add the basic information about your '
                          'farming area.',
                  style: FarmerDesign.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldInput extends StatelessWidget {
  const _FieldInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.suffixText,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? suffixText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FarmerDesign.bodyMedium,
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLines: maxLines,
          validator: validator,
          style: FarmerDesign.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: FarmerDesign.mutedText,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: FarmerDesign.secondaryText,
              size: 21,
            ),
            suffixText: suffixText,
            suffixStyle: const TextStyle(
              color: FarmerDesign.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: FarmerDesign.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: FarmerDesign.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: FarmerDesign.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: FarmerDesign.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: FarmerDesign.error,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}