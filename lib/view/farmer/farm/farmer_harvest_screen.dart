import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/controller/farmer/crop_controller.dart';
import 'package:phum_kasikors/controller/farmer/harvest_controller.dart';

class FarmerHarvestScreen extends StatefulWidget {
  const FarmerHarvestScreen({
    super.key,
    this.farmId,
  });

  final String? farmId;

  @override
  State<FarmerHarvestScreen> createState() =>
      _FarmerHarvestScreenState();
}

class _FarmerHarvestScreenState extends State<FarmerHarvestScreen> {
  late final HarvestController harvestController;
  late final CropController cropController;

  String? farmId;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xFFF7F8F3);
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color textDark = Color(0xFF263238);
  static const Color textGrey = Color(0xFF68747A);

  @override
  void initState() {
    super.initState();

    farmId = widget.farmId;

    harvestController = Get.put(
      HarvestController(),
    );

    if (Get.isRegistered<CropController>()) {
      cropController = Get.find<CropController>();
    } else {
      cropController = Get.put(
        CropController(),
        permanent: true,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    await harvestController.loadHarvests();

    if (farmId == null || farmId!.isEmpty) {
      final args = Get.arguments;

      if (args is Map && args['farmId'] != null) {
        farmId = args['farmId'].toString();
      }
    }

    if (farmId != null && farmId!.isNotEmpty) {
      await cropController.loadCrops(farmId!);
    }

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: textDark,
        title: const Text(
          'Harvest',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        if (harvestController.isLoading.value &&
            harvestController.harvests.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          );
        }

        if (harvestController.errorMessage.value.isNotEmpty &&
            harvestController.harvests.isEmpty) {
          return _ErrorView(
            message: harvestController.errorMessage.value,
            onRetry: _loadData,
          );
        }

        if (harvestController.harvests.isEmpty) {
          return _EmptyView(
            onAdd: _showHarvestDialog,
          );
        }

        return RefreshIndicator(
          color: primaryColor,
          onRefresh: _loadData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              100,
            ),
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _summaryCard(),
              const SizedBox(height: 20),
              const Text(
                'Harvest Records',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              ...harvestController.harvests.map(
                (harvest) => _harvestCard(harvest),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: _showHarvestDialog,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Harvest',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryDark,
            primaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.agriculture,
              color: Colors.white,
              size: 29,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harvest Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Record and track your harvested crops.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _summaryCard() {
    double totalQuantity = 0;

    for (final harvest in harvestController.harvests) {
      totalQuantity += _toDouble(
        harvest['quantity'],
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryItem(
              icon: Icons.agriculture_outlined,
              title: 'Harvests',
              value: harvestController.harvests.length.toString(),
            ),
          ),
          Container(
            width: 1,
            height: 55,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _summaryItem(
              icon: Icons.scale_outlined,
              title: 'Total Quantity',
              value: _formatNumber(totalQuantity),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.agriculture_outlined,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          value,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: textGrey,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HARVEST CARD
  // ============================================================

  Widget _harvestCard(
    Map<String, dynamic> harvest,
  ) {
    final crop = harvest['crop'];

    String cropName = 'Unknown Crop';

    if (crop is Map) {
      cropName =
          crop['name']?.toString() ??
          crop['crop_name']?.toString() ??
          'Unknown Crop';
    }

    final quantity = _toDouble(
      harvest['quantity'],
    );

    final date =
        harvest['harvest_date']?.toString() ??
        harvest['date']?.toString() ??
        '';

    final condition =
        harvest['condition']?.toString().toLowerCase() ?? '';

    final quality =
        harvest['quality']?.toString().toLowerCase() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.agriculture,
              color: primaryColor,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cropName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(
                      Icons.scale_outlined,
                      size: 15,
                      color: textGrey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Quantity: ${_formatNumber(quantity)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: textGrey,
                      ),
                    ),
                  ],
                ),
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: textGrey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 13,
                          color: textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 7,
                  runSpacing: 6,
                  children: [
                    if (quality.isNotEmpty)
                      _tag(
                        _displayValue(quality),
                        Icons.star_outline,
                      ),
                    if (condition.isNotEmpty)
                      _tag(
                        _displayValue(condition),
                        Icons.eco_outlined,
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: textGrey,
            ),
            onSelected: (value) {
              if (value == 'edit') {
                _showHarvestDialog(
                  harvest: harvest,
                );
              }

              if (value == 'delete') {
                _deleteHarvest(harvest);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 10),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 10),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(
    String text,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADD / EDIT DIALOG
  // ============================================================

  Future<void> _showHarvestDialog({
    Map<String, dynamic>? harvest,
  }) async {
    final bool isEdit = harvest != null;

    String? selectedCropId;

    if (isEdit) {
      selectedCropId = harvest['crop_id']?.toString();

      if (selectedCropId == null) {
        final crop = harvest['crop'];

        if (crop is Map && crop['id'] != null) {
          selectedCropId = crop['id'].toString();
        }
      }
    }

    // Make sure the existing crop actually exists in the dropdown.
    final availableCropIds = cropController.crops
        .map((crop) => crop.id)
        .toSet();

    if (selectedCropId != null &&
        !availableCropIds.contains(selectedCropId)) {
      selectedCropId = null;
    }

    String? selectedCondition;

    if (isEdit) {
      final value =
          harvest['condition']?.toString().toLowerCase().trim();

      if (value == 'fresh' ||
          value == 'good' ||
          value == 'damaged') {
        selectedCondition = value;
      }
    }

    String? selectedQuality;

    if (isEdit) {
      final value =
          harvest['quality']?.toString().toLowerCase().trim();

      if (value == 'excellent' ||
          value == 'good' ||
          value == 'fair' ||
          value == 'poor') {
        selectedQuality = value;
      }
    }

    final quantityController = TextEditingController(
      text: isEdit
          ? harvest['quantity']?.toString() ?? ''
          : '',
    );

    final notesController = TextEditingController(
      text: isEdit
          ? harvest['notes']?.toString() ?? ''
          : '',
    );

    DateTime selectedDate = DateTime.now();

    if (isEdit && harvest['harvest_date'] != null) {
      final parsed = DateTime.tryParse(
        harvest['harvest_date'].toString(),
      );

      if (parsed != null) {
        selectedDate = parsed;
      }
    }

    final formKey = GlobalKey<FormState>();

    await Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 24,
        ),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            final hasCrops = cropController.crops.isNotEmpty;

            return Container(
              constraints: const BoxConstraints(
                maxHeight: 680,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ------------------------------------------------
                  // DIALOG HEADER
                  // ------------------------------------------------

                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      18,
                      12,
                      18,
                    ),
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Icon(
                            Icons.agriculture,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isEdit
                                ? 'Edit Harvest'
                                : 'Record Harvest',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ------------------------------------------------
                  // FORM
                  // ------------------------------------------------

                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Harvest Details',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // CROP
                            DropdownButtonFormField<String>(
                              value: selectedCropId,
                              isExpanded: true,
                              decoration: _inputDecoration(
                                label: 'Crop',
                                icon: Icons.grass_outlined,
                              ),
                              hint: Text(
                                hasCrops
                                    ? 'Select crop'
                                    : 'No crops available',
                              ),
                              items: cropController.crops
                                  .map(
                                    (crop) =>
                                        DropdownMenuItem<String>(
                                      value: crop.id,
                                      child: Text(
                                        crop.name,
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: hasCrops
                                  ? (value) {
                                      setDialogState(() {
                                        selectedCropId = value;
                                      });
                                    }
                                  : null,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Please select a crop';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            // QUANTITY
                            TextFormField(
                              controller: quantityController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: _inputDecoration(
                                label: 'Quantity',
                                hint: 'Enter harvested quantity',
                                icon: Icons.scale_outlined,
                              ),
                              validator: (value) {
                                final quantity =
                                    double.tryParse(
                                  value?.trim() ?? '',
                                );

                                if (quantity == null ||
                                    quantity <= 0) {
                                  return 'Enter a valid quantity';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            // DATE
                            InkWell(
                              borderRadius:
                                  BorderRadius.circular(14),
                              onTap: () async {
                                final picked =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate:
                                      DateTime(2020),
                                  lastDate:
                                      DateTime(2100),
                                );

                                if (picked != null) {
                                  setDialogState(() {
                                    selectedDate = picked;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: _inputDecoration(
                                  label: 'Harvest Date',
                                  icon:
                                      Icons.calendar_today_outlined,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _formatDate(
                                          selectedDate,
                                        ),
                                        style: const TextStyle(
                                          color: textDark,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons
                                          .keyboard_arrow_down_rounded,
                                      color: textGrey,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // QUALITY DROPDOWN
                            DropdownButtonFormField<String>(
                              value: selectedQuality,
                              isExpanded: true,
                              decoration: _inputDecoration(
                                label: 'Quality',
                                icon: Icons.star_outline,
                              ),
                              hint: const Text(
                                'Select quality',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'excellent',
                                  child: Text('Excellent'),
                                ),
                                DropdownMenuItem(
                                  value: 'good',
                                  child: Text('Good'),
                                ),
                                DropdownMenuItem(
                                  value: 'fair',
                                  child: Text('Fair'),
                                ),
                                DropdownMenuItem(
                                  value: 'poor',
                                  child: Text('Poor'),
                                ),
                              ],
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedQuality = value;
                                });
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Please select quality';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            // CONDITION DROPDOWN
                            DropdownButtonFormField<String>(
                              value: selectedCondition,
                              isExpanded: true,
                              decoration: _inputDecoration(
                                label: 'Condition',
                                icon: Icons.eco_outlined,
                              ),
                              hint: const Text(
                                'Select condition',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'fresh',
                                  child: Text('Fresh'),
                                ),
                                DropdownMenuItem(
                                  value: 'good',
                                  child: Text('Good'),
                                ),
                                DropdownMenuItem(
                                  value: 'damaged',
                                  child: Text('Damaged'),
                                ),
                              ],
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedCondition = value;
                                });
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Please select condition';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            // NOTES
                            TextFormField(
                              controller: notesController,
                              maxLines: 3,
                              textCapitalization:
                                  TextCapitalization.sentences,
                              decoration: _inputDecoration(
                                label: 'Notes',
                                hint: 'Optional harvest notes',
                                icon: Icons.notes_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ------------------------------------------------
                  // ACTIONS
                  // ------------------------------------------------

                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              minimumSize:
                                  const Size.fromHeight(50),
                              side: const BorderSide(
                                color: primaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => ElevatedButton(
                              onPressed:
                                  harvestController
                                          .isSaving.value
                                      ? null
                                      : () async {
                                          if (!formKey
                                              .currentState!
                                              .validate()) {
                                            return;
                                          }

                                          final quantity =
                                              double.parse(
                                            quantityController
                                                .text
                                                .trim(),
                                          );

                                          final date =
                                              _dateForApi(
                                            selectedDate,
                                          );

                                          bool success;

                                          if (isEdit) {
                                            success =
                                                await harvestController
                                                    .updateHarvest(
                                              harvestId:
                                                  harvest!['id']
                                                      .toString(),
                                              harvestDate:
                                                  date,
                                              quantity:
                                                  quantity,
                                              quality:
                                                  selectedQuality!,
                                              condition:
                                                  selectedCondition!,
                                              notes:
                                                  notesController
                                                      .text,
                                            );
                                          } else {
                                            success =
                                                await harvestController
                                                    .createHarvest(
                                              cropId:
                                                  selectedCropId!,
                                              harvestDate:
                                                  date,
                                              quantity:
                                                  quantity,
                                              quality:
                                                  selectedQuality!,
                                              condition:
                                                  selectedCondition!,
                                              notes:
                                                  notesController
                                                      .text,
                                            );
                                          }

                                          if (!context.mounted) {
                                            return;
                                          }

                                          if (success) {
                                            Get.back();

                                            Get.snackbar(
                                              'Success',
                                              isEdit
                                                  ? 'Harvest updated successfully.'
                                                  : 'Harvest recorded successfully.',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              backgroundColor:
                                                  primaryColor,
                                              colorText:
                                                  Colors.white,
                                              margin:
                                                  const EdgeInsets
                                                      .all(16),
                                              borderRadius: 14,
                                            );
                                          } else {
                                            Get.snackbar(
                                              'Unable to save',
                                              harvestController
                                                      .errorMessage
                                                      .value
                                                      .isNotEmpty
                                                  ? harvestController
                                                      .errorMessage
                                                      .value
                                                  : 'Something went wrong.',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              backgroundColor:
                                                  Colors.red.shade700,
                                              colorText:
                                                  Colors.white,
                                              margin:
                                                  const EdgeInsets
                                                      .all(16),
                                              borderRadius: 14,
                                            );
                                          }
                                        },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    Colors.grey.shade300,
                                minimumSize:
                                    const Size.fromHeight(50),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                              ),
                              child: harvestController
                                      .isSaving.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isEdit
                                          ? 'Update'
                                          : 'Save Harvest',
                                      style: const TextStyle(
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    );

    quantityController.dispose();
    notesController.dispose();
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteHarvest(
    Map<String, dynamic> harvest,
  ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            SizedBox(width: 10),
            Text('Delete Harvest'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this harvest record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final id = harvest['id']?.toString();

    if (id == null || id.isEmpty) {
      return;
    }

    final success =
        await harvestController.deleteHarvest(id);

    if (success) {
      Get.snackbar(
        'Deleted',
        'Harvest deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: primaryColor,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
    } else {
      Get.snackbar(
        'Error',
        harvestController.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
    }
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: primaryColor,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  String _formatDate(DateTime date) {
    final month =
        date.month.toString().padLeft(2, '0');

    final day =
        date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  String _dateForApi(DateTime date) {
    final month =
        date.month.toString().padLeft(2, '0');

    final day =
        date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  String _displayValue(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1).toLowerCase();
  }
}

// ================================================================
// EMPTY VIEW
// ================================================================

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.agriculture_outlined,
                size: 52,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'No harvest records yet',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start recording your harvested crops\n'
              'to keep track of your farm production.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF68747A),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'Record First Harvest',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
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
// ERROR VIEW
// ================================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 45,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Unable to load harvests',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF68747A),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}