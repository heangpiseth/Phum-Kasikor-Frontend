import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:phum_kasikors/controller/farmer/crop_controller.dart';
import 'package:phum_kasikors/controller/farmer/field_controller.dart';
import 'package:phum_kasikors/model/farmer/field_model.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';

class FarmerAddCropScreen extends StatefulWidget {
  const FarmerAddCropScreen({
    super.key,
    this.farmId,
  });

  final String? farmId;

  @override
  State<FarmerAddCropScreen> createState() =>
      _FarmerAddCropScreenState();
}

class _FarmerAddCropScreenState
    extends State<FarmerAddCropScreen> {
  late final CropController controller;
  late final FieldController fieldController;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final varietyController = TextEditingController();
  final quantityController = TextEditingController();
  final growthStageController = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();

  DateTime? plantingDate;
  DateTime? expectedHarvestDate;

  String? selectedFieldId;

  File? selectedImage;

  String get farmId =>
      widget.farmId?.trim() ?? '';

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<CropController>()
        ? Get.find<CropController>()
        : Get.put(CropController());

    fieldController =
        Get.isRegistered<FieldController>()
            ? Get.find<FieldController>()
            : Get.put(FieldController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFields();
    });
  }

  Future<void> _loadFields() async {
    if (farmId.isEmpty) return;

    await fieldController.loadFields(farmId);
  }

  @override
  void dispose() {
    nameController.dispose();
    varietyController.dispose();
    quantityController.dispose();
    growthStageController.dispose();
    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    final source =
        await Get.bottomSheet<ImageSource>(
      Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          30,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add crop photo',
                style: FarmerDesign.heading3,
              ),

              const SizedBox(height: 18),

              ListTile(
                leading: const CircleAvatar(
                  backgroundColor:
                      FarmerDesign.primaryLight,
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: FarmerDesign.primary,
                  ),
                ),
                title: const Text(
                  'Take a photo',
                ),
                onTap: () {
                  Get.back(
                    result: ImageSource.camera,
                  );
                },
              ),

              ListTile(
                leading: const CircleAvatar(
                  backgroundColor:
                      FarmerDesign.primaryLight,
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: FarmerDesign.primary,
                  ),
                ),
                title: const Text(
                  'Choose from gallery',
                ),
                onTap: () {
                  Get.back(
                    result: ImageSource.gallery,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picked =
        await imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (picked == null) return;

    setState(() {
      selectedImage = File(picked.path);
    });
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> pickDate({
    required bool planting,
  }) async {
    final initialDate = planting
        ? (plantingDate ?? DateTime.now())
        : (expectedHarvestDate ??
            plantingDate ??
            DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                Theme.of(context)
                    .colorScheme
                    .copyWith(
                      primary:
                          FarmerDesign.primary,
                    ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      if (planting) {
        plantingDate = picked;
      } else {
        expectedHarvestDate = picked;
      }
    });
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> save() async {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) {
      return;
    }

    if (farmId.isEmpty) {
      _showError(
        'Farm unavailable',
        'Your farm could not be identified.',
      );
      return;
    }

    if (plantingDate != null &&
        expectedHarvestDate != null &&
        expectedHarvestDate!
            .isBefore(plantingDate!)) {
      _showError(
        'Invalid dates',
        'Expected harvest date cannot be before planting date.',
      );
      return;
    }

    final quantityText =
        quantityController.text.trim();

    double? quantity;

    if (quantityText.isNotEmpty) {
      quantity =
          double.tryParse(quantityText);

      if (quantity == null || quantity < 0) {
        _showError(
          'Invalid quantity',
          'Please enter a valid quantity.',
        );
        return;
      }
    }

    final success =
        await controller.createCrop(
      farmId: farmId,
      name: nameController.text.trim(),
      fieldId: selectedFieldId,
      variety:
          varietyController.text.trim().isEmpty
              ? null
              : varietyController.text.trim(),
      plantingDate: plantingDate,
      expectedHarvestDate:
          expectedHarvestDate,
      quantityPlanted: quantity,
      growthStage:
          growthStageController.text
                  .trim()
                  .isEmpty
              ? null
              : growthStageController.text
                  .trim(),
      imageFile: selectedImage,
    );

    if (!mounted) return;

    if (success) {
      Get.back(result: true);

      Get.snackbar(
        'Crop added',
        'The crop has been added successfully.',
        snackPosition:
            SnackPosition.BOTTOM,
        backgroundColor:
            FarmerDesign.primaryDark,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
    } else {
      _showError(
        'Could not add crop',
        controller.errorMessage.value.isEmpty
            ? 'Something went wrong.'
            : controller.errorMessage.value,
      );
    }
  }

  void _showError(
    String title,
    String message,
  ) {
    Get.snackbar(
      title,
      message,
      snackPosition:
          SnackPosition.BOTTOM,
      backgroundColor:
          FarmerDesign.error,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          FarmerDesign.background,
      appBar: AppBar(
        backgroundColor:
            FarmerDesign.background,
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
        title: const Text(
          'Add Crop',
          style: FarmerDesign.heading2,
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            32,
          ),
          children: [
            const _Header(),

            const SizedBox(height: 22),

            _Input(
              controller: nameController,
              label: 'Crop name',
              hint: 'e.g. Rice',
              icon: Icons.grass_rounded,
              capitalization:
                  TextCapitalization.words,
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Crop name is required';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            _Input(
              controller: varietyController,
              label: 'Variety',
              hint: 'e.g. Jasmine Rice',
              icon: Icons.eco_outlined,
              capitalization:
                  TextCapitalization.words,
            ),

            const SizedBox(height: 14),

            _FieldSelector(
              fieldController:
                  fieldController,
              selectedFieldId:
                  selectedFieldId,
              onChanged: (value) {
                setState(() {
                  selectedFieldId = value;
                });
              },
            ),

            const SizedBox(height: 14),

            _Input(
              controller:
                  quantityController,
              label: 'Quantity planted',
              hint: 'e.g. 100',
              icon:
                  Icons.inventory_2_outlined,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            const SizedBox(height: 14),

            _Input(
              controller:
                  growthStageController,
              label: 'Growth stage',
              hint:
                  'e.g. Seedling, Growing',
              icon:
                  Icons.trending_up_rounded,
              capitalization:
                  TextCapitalization.words,
            ),

            const SizedBox(height: 18),

            _DateTile(
              title: 'Planting date',
              date: plantingDate,
              icon:
                  Icons.calendar_today_outlined,
              onTap: () =>
                  pickDate(planting: true),
            ),

            const SizedBox(height: 10),

            _DateTile(
              title:
                  'Expected harvest date',
              date:
                  expectedHarvestDate,
              icon:
                  Icons.event_available_outlined,
              onTap: () =>
                  pickDate(planting: false),
            ),

            const SizedBox(height: 18),

            _CropImagePicker(
              image: selectedImage,
              onTap: _pickImage,
            ),

            const SizedBox(height: 28),

            Obx(
              () => SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed:
                      controller.isSaving.value
                          ? null
                          : save,
                  style:
                      FilledButton.styleFrom(
                    backgroundColor:
                        FarmerDesign.primary,
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),
                  ),
                  child:
                      controller.isSaving.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Text(
                              'Add crop',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w700,
                                fontSize: 15,
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

// ================================================================
// HEADER
// ================================================================

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            FarmerDesign.primaryLight,
        borderRadius:
            BorderRadius.circular(
          FarmerDesign.radiusLarge,
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.grass_rounded,
            color: FarmerDesign.primary,
            size: 38,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Add a crop',
                  style:
                      FarmerDesign.heading3,
                ),
                SizedBox(height: 4),
                Text(
                  'Record the crop growing on your farm.',
                  style:
                      FarmerDesign.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// IMAGE PICKER
// ================================================================

class _CropImagePicker
    extends StatelessWidget {
  const _CropImagePicker({
    required this.image,
    required this.onTap,
  });

  final File? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Crop photo',
          style:
              FarmerDesign.bodyMedium,
        ),

        const SizedBox(height: 8),

        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 190,
            width: double.infinity,
            decoration: BoxDecoration(
              color:
                  FarmerDesign.primaryLight,
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color:
                    FarmerDesign.border,
              ),
            ),
            clipBehavior:
                Clip.antiAlias,
            child: image == null
                ? const Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons
                            .add_a_photo_rounded,
                        size: 42,
                        color:
                            FarmerDesign.primary,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Take photo or choose from gallery',
                        style: FarmerDesign
                            .bodyMedium,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Optional',
                        style:
                            FarmerDesign.caption,
                      ),
                    ],
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        image!,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors.black
                                .withValues(
                              alpha: 0.65,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                Icons
                                    .edit_rounded,
                                color:
                                    Colors.white,
                                size: 16,
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Text(
                                'Change photo',
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// FIELD SELECTOR
// ================================================================

class _FieldSelector
    extends StatelessWidget {
  const _FieldSelector({
    required this.fieldController,
    required this.selectedFieldId,
    required this.onChanged,
  });

  final FieldController fieldController;
  final String? selectedFieldId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fields =
          fieldController.fields;

      final validSelectedField =
          fields.any(
        (field) =>
            field.id ==
            selectedFieldId,
      )
              ? selectedFieldId
              : null;

      return Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Field',
            style:
                FarmerDesign.bodyMedium,
          ),

          const SizedBox(height: 7),

          Container(
            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color:
                    FarmerDesign.border,
              ),
            ),
            child:
                DropdownButtonFormField<
                    String>(
              initialValue:
                  validSelectedField,
              isExpanded: true,
              icon: const Icon(
                Icons
                    .keyboard_arrow_down_rounded,
              ),
              decoration:
                  const InputDecoration(
                prefixIcon: Icon(
                  Icons.grid_view_rounded,
                  color: FarmerDesign
                      .secondaryText,
                ),
                border:
                    InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 14,
                ),
              ),
              hint: fieldController
                      .isLoading.value
                  ? const Text(
                      'Loading fields...',
                    )
                  : fields.isEmpty
                      ? const Text(
                          'No fields available',
                        )
                      : const Text(
                          'Select a field (optional)',
                        ),
              items: fields.map(
                (FieldModel field) {
                  return DropdownMenuItem<
                      String>(
                    value: field.id,
                    child: Text(
                      field.name,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  );
                },
              ).toList(),
              onChanged:
                  fieldController
                              .isLoading.value ||
                          fields.isEmpty
                      ? null
                      : onChanged,
            ),
          ),

          if (fieldController
              .isLoading.value)
            const Padding(
              padding:
                  EdgeInsets.only(
                top: 6,
                left: 4,
              ),
              child: Text(
                'Loading your farm fields...',
                style:
                    FarmerDesign.caption,
              ),
            ),

          if (!fieldController
                  .isLoading.value &&
              fieldController
                  .errorMessage
                  .value
                  .isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.only(
                top: 6,
                left: 4,
              ),
              child: Text(
                fieldController
                    .errorMessage.value,
                style:
                    const TextStyle(
                  color:
                      FarmerDesign.error,
                  fontSize: 12,
                ),
              ),
            ),

          if (!fieldController
                  .isLoading.value &&
              fieldController
                  .errorMessage
                  .value
                  .isEmpty &&
              fields.isEmpty)
            const Padding(
              padding:
                  EdgeInsets.only(
                top: 6,
                left: 4,
              ),
              child: Text(
                'No fields have been created for this farm yet.',
                style:
                    FarmerDesign.caption,
              ),
            ),
        ],
      );
    });
  }
}

// ================================================================
// TEXT INPUT
// ================================================================

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.capitalization =
        TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)?
      validator;
  final TextInputType? keyboardType;
  final TextCapitalization capitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              FarmerDesign.bodyMedium,
        ),

        const SizedBox(height: 7),

        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textCapitalization:
              capitalization,
          style: FarmerDesign.body,
          decoration:
              InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color:
                  FarmerDesign.secondaryText,
            ),
            filled: true,
            fillColor: Colors.white,
            border: _border(),
            enabledBorder: _border(),
            focusedBorder: _border(
              color:
                  FarmerDesign.primary,
              width: 1.5,
            ),
            errorBorder: _border(
              color:
                  FarmerDesign.error,
            ),
            focusedErrorBorder:
                _border(
              color:
                  FarmerDesign.error,
              width: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border({
    Color color =
        FarmerDesign.border,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(14),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}

// ================================================================
// DATE TILE
// ================================================================

class _DateTile
    extends StatelessWidget {
  const _DateTile({
    required this.title,
    required this.date,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final DateTime? date;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(14),
        child: Container(
          padding:
              const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color:
                  FarmerDesign.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    FarmerDesign.primary,
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      title,
                      style:
                          FarmerDesign.caption,
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      date == null
                          ? 'Select date'
                          : '${date!.day.toString().padLeft(2, '0')}/'
                              '${date!.month.toString().padLeft(2, '0')}/'
                              '${date!.year}',
                      style:
                          FarmerDesign.bodyMedium,
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .chevron_right_rounded,
                color:
                    FarmerDesign.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}