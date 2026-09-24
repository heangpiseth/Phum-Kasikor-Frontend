import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/controller/farmer/crop_controller.dart';
import 'package:phum_kasikors/controller/farmer/field_controller.dart';
import 'package:phum_kasikors/model/farmer/crop_model.dart';
import 'package:phum_kasikors/model/farmer/field_model.dart';
import 'package:phum_kasikors/view/farmer/farm/farmer_watering_screen.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';
class FarmerCropDetailScreen extends StatefulWidget {
  const FarmerCropDetailScreen({
    super.key,
    this.farmId,
    this.cropId,
  });

  final String? farmId;
  final String? cropId;

  @override
  State<FarmerCropDetailScreen> createState() =>
      _FarmerCropDetailScreenState();
}

class _FarmerCropDetailScreenState
    extends State<FarmerCropDetailScreen> {
  late final CropController controller;
  late final FieldController fieldController;

  String get farmId => widget.farmId?.trim() ?? '';
  String get cropId => widget.cropId?.trim() ?? '';

  CropModel? get currentCrop =>
      controller.getCropById(cropId);

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<CropController>()
        ? Get.find<CropController>()
        : Get.put(CropController());

    fieldController = Get.isRegistered<FieldController>()
        ? Get.find<FieldController>()
        : Get.put(FieldController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (farmId.isEmpty) return;

    await Future.wait([
      controller.loadCrops(farmId),
      fieldController.loadFields(farmId),
    ]);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _fieldName(String? fieldId) {
    if (fieldId == null || fieldId.trim().isEmpty) {
      return 'Not assigned';
    }

    final field = fieldController.getFieldById(fieldId);

    if (field != null && field.name.trim().isNotEmpty) {
      return field.name;
    }

    return 'Field #$fieldId';
  }

  Future<void> _deleteCrop() async {
    final crop = currentCrop;

    if (crop == null) {
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete crop?'),
        content: Text(
          'Are you sure you want to delete "${crop.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: FarmerDesign.error,
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final success = await controller.deleteCrop(
      farmId: farmId,
      cropId: crop.id,
    );

    if (!mounted) return;

    if (success) {
      Get.back(result: true);

      Get.snackbar(
        'Crop deleted',
        'The crop has been deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: FarmerDesign.primaryDark,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
    } else {
      Get.snackbar(
        'Could not delete crop',
        controller.errorMessage.value.isEmpty
            ? 'Something went wrong.'
            : controller.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: FarmerDesign.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
    }
  }

  Future<void> _editCrop() async {
    final crop = currentCrop;

    if (crop == null) {
      return;
    }

    final nameController = TextEditingController(
      text: crop.name,
    );

    final varietyController = TextEditingController(
      text: crop.variety ?? '',
    );

    final quantityController = TextEditingController(
      text: crop.quantityPlanted?.toString() ?? '',
    );

    final growthStageController = TextEditingController(
      text: crop.growthStage ?? '',
    );

    String? selectedFieldId = crop.fieldId;

    final result = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text(
              'Edit crop',
              style: FarmerDesign.heading3,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    textCapitalization:
                        TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Crop name',
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: varietyController,
                    textCapitalization:
                        TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Variety',
                    ),
                  ),

                  const SizedBox(height: 14),

                  Obx(() {
                    final fields = fieldController.fields;

                    final validSelectedField =
                        fields.any(
                      (field) =>
                          field.id == selectedFieldId,
                    )
                            ? selectedFieldId
                            : null;

                    return DropdownButtonFormField<String>(
                      initialValue: validSelectedField,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Field',
                        prefixIcon: Icon(
                          Icons.grid_view_rounded,
                        ),
                      ),
                      hint: fieldController.isLoading.value
                          ? const Text('Loading fields...')
                          : const Text(
                              'Select a field',
                            ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text(
                            'No field assigned',
                          ),
                        ),
                        ...fields.map(
                          (FieldModel field) {
                            return DropdownMenuItem<String>(
                              value: field.id,
                              child: Text(
                                field.name,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                      ],
                      onChanged:
                          fieldController.isLoading.value
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    selectedFieldId =
                                        value == null ||
                                                value.isEmpty
                                            ? null
                                            : value;
                                  });
                                },
                    );
                  }),

                  const SizedBox(height: 14),

                  TextField(
                    controller: quantityController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Quantity planted',
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: growthStageController,
                    textCapitalization:
                        TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Growth stage',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(
                  result: false,
                ),
                child: const Text('Cancel'),
              ),
              Obx(
                () => FilledButton(
                  onPressed:
                      controller.isSaving.value
                          ? null
                          : () async {
                              final name =
                                  nameController.text.trim();

                              if (name.isEmpty) {
                                Get.snackbar(
                                  'Missing name',
                                  'Crop name is required.',
                                  snackPosition:
                                      SnackPosition.BOTTOM,
                                );
                                return;
                              }

                              final quantityText =
                                  quantityController.text.trim();

                              double? quantity;

                              if (quantityText.isNotEmpty) {
                                quantity =
                                    double.tryParse(
                                  quantityText,
                                );

                                if (quantity == null ||
                                    quantity < 0) {
                                  Get.snackbar(
                                    'Invalid quantity',
                                    'Please enter a valid quantity.',
                                    snackPosition:
                                        SnackPosition.BOTTOM,
                                  );
                                  return;
                                }
                              }

                              final success =
                                  await controller.updateCrop(
                                farmId: farmId,
                                cropId: crop.id,
                                data: {
                                  'name': name,
                                  'field_id':
                                      selectedFieldId,
                                  'variety':
                                      varietyController
                                              .text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : varietyController
                                              .text
                                              .trim(),
                                  'quantity_planted':
                                      quantity,
                                  'growth_stage':
                                      growthStageController
                                              .text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : growthStageController
                                              .text
                                              .trim(),
                                },
                              );

                              if (success) {
                                Get.back(
                                  result: true,
                                );
                              } else {
                                Get.snackbar(
                                  'Could not update crop',
                                  controller
                                          .errorMessage
                                          .value
                                          .isEmpty
                                      ? 'Something went wrong.'
                                      : controller
                                          .errorMessage
                                          .value,
                                  snackPosition:
                                      SnackPosition.BOTTOM,
                                  backgroundColor:
                                      FarmerDesign.error,
                                  colorText:
                                      Colors.white,
                                );
                              }
                            },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        FarmerDesign.primary,
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          );
        },
      ),
    );

    nameController.dispose();
    varietyController.dispose();
    quantityController.dispose();
    growthStageController.dispose();

    if (!mounted) return;

    if (result == true) {
      await controller.loadCrops(farmId);

      if (!mounted) return;

      Get.snackbar(
        'Crop updated',
        'The crop has been updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: FarmerDesign.primaryDark,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerDesign.background,
      appBar: AppBar(
        backgroundColor: FarmerDesign.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Crop Details',
          style: FarmerDesign.heading2,
        ),
        actions: [
          IconButton(
            onPressed: _editCrop,
            icon: const Icon(
              Icons.edit_outlined,
            ),
            tooltip: 'Edit crop',
          ),
          IconButton(
            onPressed: _deleteCrop,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: FarmerDesign.error,
            ),
            tooltip: 'Delete crop',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Obx(() {
        final crop = currentCrop;

        if (controller.isLoading.value &&
            crop == null) {
          return const Center(
            child: CircularProgressIndicator(
              color: FarmerDesign.primary,
            ),
          );
        }

        if (crop == null) {
          return _EmptyState(
            message: controller.errorMessage.value.isEmpty
                ? 'Crop not found.'
                : controller.errorMessage.value,
            onRetry: _loadData,
          );
        }

        return RefreshIndicator(
          color: FarmerDesign.primary,
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              32,
            ),
            children: [
              _CropHero(
                crop: crop,
                fieldName: _fieldName(
                  crop.fieldId,
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Crop information',
                style: FarmerDesign.heading3,
              ),

              const SizedBox(height: 12),

              _InfoCard(
                children: [
                  _InfoRow(
                    icon: Icons.eco_outlined,
                    label: 'Variety',
                    value:
                        crop.variety?.trim().isNotEmpty == true
                            ? crop.variety!
                            : 'Not specified',
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.grid_view_rounded,
                    label: 'Field',
                    value: _fieldName(
                      crop.fieldId,
                    ),
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Planting date',
                    value: _formatDate(
                      crop.plantingDate,
                    ),
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.event_available_outlined,
                    label: 'Expected harvest',
                    value: _formatDate(
                      crop.expectedHarvestDate,
                    ),
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.inventory_2_outlined,
                    label: 'Quantity planted',
                    value: crop.quantityPlanted != null
                        ? _formatQuantity(
                            crop.quantityPlanted!,
                          )
                        : 'Not specified',
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'Growth',
                style: FarmerDesign.heading3,
              ),

              const SizedBox(height: 12),

              _GrowthCard(
                growthStage:
                    crop.growthStage ?? 'Growing',
              ),

              const SizedBox(height: 20),

              _ActionCard(
                onEdit: _editCrop,
                onDelete: _deleteCrop,
                onRecommendation: () {
                  Get.to(
                    () =>
                        FarmerWateringScreen(
                      cropId: crop.id,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  String _formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toInt().toString();
    }

    return quantity.toString();
  }
}

// ================================================================
// CROP HERO
// ================================================================

class _CropHero extends StatelessWidget {
  const _CropHero({
    required this.crop,
    required this.fieldName,
  });

  final CropModel crop;
  final String fieldName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          FarmerDesign.radiusLarge,
        ),
        border: Border.all(
          color: FarmerDesign.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (crop.imageUrl != null &&
              crop.imageUrl!.trim().isNotEmpty)
            SizedBox(
              height: 210,
              width: double.infinity,
              child: Image.network(
                crop.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => _ImagePlaceholder(),
              ),
            )
          else
            const _ImagePlaceholder(),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.name,
                        style: FarmerDesign.heading2,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        fieldName,
                        style: FarmerDesign.bodyMedium
                            .copyWith(
                          color:
                              FarmerDesign.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _StatusBadge(
                  status: crop.status,
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
// IMAGE PLACEHOLDER
// ================================================================

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      color: FarmerDesign.primaryLight,
      child: const Center(
        child: Icon(
          Icons.grass_rounded,
          size: 64,
          color: FarmerDesign.primary,
        ),
      ),
    );
  }
}

// ================================================================
// STATUS BADGE
// ================================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: FarmerDesign.primaryLight,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: FarmerDesign.primaryDark,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ================================================================
// INFO CARD
// ================================================================

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FarmerDesign.border,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// ================================================================
// INFO ROW
// ================================================================

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: FarmerDesign.primaryLight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 19,
              color: FarmerDesign.primary,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: FarmerDesign.caption,
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: FarmerDesign.bodyMedium,
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
// DIVIDER
// ================================================================

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      color: FarmerDesign.border,
    );
  }
}

// ================================================================
// GROWTH CARD
// ================================================================

class _GrowthCard extends StatelessWidget {
  const _GrowthCard({
    required this.growthStage,
  });

  final String growthStage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FarmerDesign.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: FarmerDesign.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current growth stage',
                  style: FarmerDesign.caption,
                ),
                const SizedBox(height: 4),
                Text(
                  growthStage,
                  style: FarmerDesign.heading3,
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
// ACTION CARD
// ================================================================

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.onEdit,
    required this.onDelete,
    required this.onRecommendation,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRecommendation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FarmerDesign.border,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRecommendation,
              icon: const Icon(
                Icons.water_drop_outlined,
              ),
              label: const Text(
                'Weather & Crop Recommendation',
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    FarmerDesign.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        FarmerDesign.primary,
                    side: const BorderSide(
                      color: FarmerDesign.primary,
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                  ),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        FarmerDesign.error,
                    side: const BorderSide(
                      color: FarmerDesign.error,
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================================================================
// EMPTY STATE
// ================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: FarmerDesign.primaryLight,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.grass_rounded,
                size: 34,
                color: FarmerDesign.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: FarmerDesign.bodyMedium,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}