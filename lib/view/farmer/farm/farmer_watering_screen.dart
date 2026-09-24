import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';

import 'package:phum_kasikors/controller/farmer/crop_controller.dart';
import 'package:phum_kasikors/controller/farmer/field_controller.dart';
import 'package:phum_kasikors/controller/farmer/watering_controller.dart';
import 'package:phum_kasikors/model/farmer/crop_model.dart';
import 'package:phum_kasikors/model/farmer/field_model.dart';
import 'package:phum_kasikors/model/farmer/watering_log_model.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';

class FarmerWateringScreen extends StatefulWidget {
  const FarmerWateringScreen({
    super.key,
    this.farmId, required String cropId,
  });

  final String? farmId;

  @override
  State<FarmerWateringScreen> createState() =>
      _FarmerWateringScreenState();
}

class _FarmerWateringScreenState
    extends State<FarmerWateringScreen> {
  late final WateringController wateringController;
  late final CropController cropController;
  late final FieldController fieldController;

  @override
  void initState() {
    super.initState();

    wateringController =
        Get.isRegistered<WateringController>()
            ? Get.find<WateringController>()
            : Get.put(WateringController());

    cropController =
        Get.isRegistered<CropController>()
            ? Get.find<CropController>()
            : Get.put(CropController());

    fieldController =
        Get.isRegistered<FieldController>()
            ? Get.find<FieldController>()
            : Get.put(FieldController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFarmData();
    });
  }

  Future<void> _loadFarmData() async {
    final farmId = widget.farmId?.trim();

    // ------------------------------------------------------------
    // If a farm ID is available, refresh crops and fields from API.
    // If it is not available, we keep using already-loaded data.
    // ------------------------------------------------------------

    if (farmId != null && farmId.isNotEmpty) {
      await Future.wait([
        cropController.loadCrops(farmId),
        fieldController.loadFields(farmId),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerDesign.background,
      appBar: AppBar(
        title: const Text('Watering'),
        backgroundColor: FarmerDesign.background,
        foregroundColor: FarmerDesign.text,
        elevation: 0,
      ),
      body: Obx(
        () => RefreshIndicator(
          color: FarmerDesign.primary,
          onRefresh: _refresh,
          child: ListView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: FarmerDesign.pagePadding,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSummary(),
              const SizedBox(height: 24),
              _buildSectionTitle(),
              const SizedBox(height: 12),
              _buildCropContent(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Watering',
          style: FarmerDesign.heading1,
        ),
        const SizedBox(height: 6),
        Text(
          'Keep track of which crops have been watered today.',
          style: FarmerDesign.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.water_drop_rounded,
            title: 'Today',
            value:
                '${wateringController.totalWaterUsedToday.toStringAsFixed(1)} L',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.calendar_view_week_rounded,
            title: 'Last 7 Days',
            value:
                '${wateringController.totalWaterUsedThisWeek.toStringAsFixed(1)} L',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Today's Watering",
            style: FarmerDesign.heading2,
          ),
        ),
        if (cropController.crops.isNotEmpty)
          Text(
            '${cropController.crops.length} crops',
            style: FarmerDesign.caption,
          ),
      ],
    );
  }

  // ============================================================
  // CROP CONTENT
  // ============================================================

  Widget _buildCropContent() {
    if (cropController.isLoading.value) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (cropController.errorMessage.value.isNotEmpty &&
        cropController.crops.isEmpty) {
      return _ErrorCard(
        message: cropController.errorMessage.value,
        onRetry: _loadFarmData,
      );
    }

    if (cropController.crops.isEmpty) {
      return const _EmptyCrops();
    }

    return Column(
      children: cropController.crops.map(
        (crop) {
          return Padding(
            padding:
                const EdgeInsets.only(bottom: 12),
            child: _CropWateringCard(
              crop: crop,
              field: _getFieldForCrop(crop),
              wateredToday:
                  wateringController.hasWateredToday(
                crop.id,
              ),
              lastWatering:
                  wateringController.getLastWatering(
                crop.id,
              ),
              onRecord: () =>
                  _showRecordWatering(crop),
              onHistory: () =>
                  _showHistoryMessage(crop),
            ),
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // FIELD RESOLUTION
  // ============================================================

  FieldModel? _getFieldForCrop(
    CropModel crop,
  ) {
    final fieldId = crop.fieldId;

    if (fieldId == null ||
        fieldId.trim().isEmpty) {
      return null;
    }

    return fieldController.getFieldById(
      fieldId,
    );
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    await wateringController.refreshWateringLogs();
    await _loadFarmData();
  }

  // ============================================================
  // RECORD WATERING
  // ============================================================

  Future<void> _showRecordWatering(
    CropModel crop,
  ) async {
    final field = _getFieldForCrop(crop);

    if (field == null) {
      Get.snackbar(
        'Field not found',
        'This crop is not connected to a valid field.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final amountController =
        TextEditingController();

    final notesController =
        TextEditingController();

    DateTime selectedDateTime =
        DateTime.now();

    final result = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (
          context,
          setDialogState,
        ) {
          return AlertDialog(
            title: const Text(
              'Record Watering',
            ),
            content:
                SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // CROP
                  // ------------------------------------------------

                  _DialogInfoRow(
                    icon:
                        Icons.eco_rounded,
                    label: 'Crop',
                    value: crop.name,
                  ),

                  const SizedBox(height: 10),

                  // ------------------------------------------------
                  // FIELD
                  // ------------------------------------------------

                  _DialogInfoRow(
                    icon:
                        Icons.landscape_rounded,
                    label: 'Field',
                    value: field.name,
                  ),

                  const SizedBox(height: 18),

                  // ------------------------------------------------
                  // WATER AMOUNT
                  // ------------------------------------------------

                  TextFormField(
                    controller:
                        amountController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Water amount',
                      suffixText: 'L',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ------------------------------------------------
                  // DATE / TIME
                  // ------------------------------------------------

                  InkWell(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                    onTap: () async {
                      final date =
                          await showDatePicker(
                        context: context,
                        initialDate:
                            selectedDateTime,
                        firstDate:
                            DateTime(2020),
                        lastDate:
                            DateTime.now(),
                      );

                      if (date == null) {
                        return;
                      }

                      final time =
                          await showTimePicker(
                        context: context,
                        initialTime:
                            TimeOfDay.fromDateTime(
                          selectedDateTime,
                        ),
                      );

                      if (time == null) {
                        return;
                      }

                      setDialogState(() {
                        selectedDateTime =
                            DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    },
                    child: InputDecorator(
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Date & time',
                        border:
                            OutlineInputBorder(),
                        suffixIcon: Icon(
                          Icons
                              .calendar_today_rounded,
                        ),
                      ),
                      child: Text(
                        _formatDateTime(
                          selectedDateTime,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ------------------------------------------------
                  // NOTES
                  // ------------------------------------------------

                  TextFormField(
                    controller:
                        notesController,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(
                      labelText: 'Notes',
                      hintText:
                          'Optional irrigation notes',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Get.back(
                  result: false,
                ),
                child:
                    const Text('Cancel'),
              ),
              FilledButton(
                style:
                    FilledButton.styleFrom(
                  backgroundColor:
                      FarmerDesign.primary,
                ),
                onPressed: () async {
                  final amount =
                      double.tryParse(
                    amountController.text
                        .trim(),
                  );

                  if (amount == null ||
                      amount <= 0) {
                    Get.snackbar(
                      'Invalid amount',
                      'Enter a water amount greater than 0.',
                      snackPosition:
                          SnackPosition
                              .BOTTOM,
                    );
                    return;
                  }

                  final success =
                      await wateringController
                          .logWatering(
                    // CropModel.id is String.
                    cropId: crop.id,
                    fieldName:
                        field.name,
                    amount: amount,
                    date:
                        selectedDateTime,
                    notes:
                        notesController
                                .text
                                .trim()
                                .isEmpty
                            ? null
                            : notesController
                                .text
                                .trim(),
                  );

                  if (!success) {
                    Get.snackbar(
                      'Unable to save',
                      wateringController
                              .errorMessage
                              .value ??
                          'Something went wrong.',
                      snackPosition:
                          SnackPosition
                              .BOTTOM,
                    );
                    return;
                  }

                  Get.back(
                    result: true,
                  );
                },
                child:
                    const Text(
                  'Record Watering',
                ),
              ),
            ],
          );
        },
      ),
    );

    amountController.dispose();
    notesController.dispose();

    if (result == true) {
      Get.snackbar(
        'Watering recorded',
        '${crop.name} has been marked as watered.',
        snackPosition:
            SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // HISTORY
  // ============================================================

  Future<void> _showHistoryMessage(
    CropModel crop,
  ) async {
    final logs =
        wateringController.getLogsByCrop(
      crop.id,
    );

    if (logs.isEmpty) {
      Get.snackbar(
        'No watering history',
        '${crop.name} has no watering records yet.',
        snackPosition:
            SnackPosition.BOTTOM,
      );
      return;
    }

    await Get.dialog(
      AlertDialog(
        title: Text(
          '${crop.name} — History',
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: logs.length,
            separatorBuilder:
                (_, __) =>
                    const Divider(),
            itemBuilder: (
              context,
              index,
            ) {
              final log = logs[index];

              return ListTile(
                contentPadding:
                    EdgeInsets.zero,
                leading:
                    const CircleAvatar(
                  backgroundColor:
                      FarmerDesign
                          .primaryLight,
                  child: Icon(
                    Icons.water_drop_rounded,
                    color:
                        FarmerDesign.primary,
                  ),
                ),
                title: Text(
                  '${(log.waterAmount ?? 0).toStringAsFixed(1)} L',
                  style:
                      FarmerDesign.bodyMedium,
                ),
                subtitle: Text(
                  _formatDateTime(
                    log.wateringDate,
                  ),
                ),
                trailing:
                    log.notes == null ||
                            log.notes!
                                .isEmpty
                        ? null
                        : const Icon(
                            Icons
                                .notes_rounded,
                            size: 20,
                          ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child:
                const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDateTime(
    DateTime date,
  ) {
    final day =
        date.day.toString().padLeft(
              2,
              '0',
            );

    final month =
        date.month.toString().padLeft(
              2,
              '0',
            );

    final year =
        date.year.toString();

    final hour =
        date.hour == 0
            ? 12
            : date.hour > 12
                ? date.hour - 12
                : date.hour;

    final minute =
        date.minute.toString().padLeft(
              2,
              '0',
            );

    final period =
        date.hour >= 12
            ? 'PM'
            : 'AM';

    return '$day/$month/$year • $hour:$minute $period';
  }
}

// ============================================================================
// CROP WATERING CARD
// ============================================================================

class _CropWateringCard
    extends StatelessWidget {
  const _CropWateringCard({
    required this.crop,
    required this.field,
    required this.wateredToday,
    required this.lastWatering,
    required this.onRecord,
    required this.onHistory,
  });

  final CropModel crop;
  final FieldModel? field;
  final bool wateredToday;
  final WateringModel? lastWatering;
  final VoidCallback onRecord;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final fieldName =
        field?.name ?? 'No field assigned';

    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          FarmerDesign.radiusMedium,
        ),
        border: Border.all(
          color: FarmerDesign.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------------
          // CROP + STATUS
          // --------------------------------------------------------

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      FarmerDesign.primaryLight,
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color:
                      FarmerDesign.primary,
                  size: 26,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      crop.name,
                      style:
                          FarmerDesign.heading3,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons
                              .landscape_rounded,
                          size: 15,
                          color:
                              AppColors
                                  .textSecondary,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: Text(
                            fieldName,
                            style:
                                FarmerDesign
                                    .caption,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              _StatusBadge(
                watered: wateredToday,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // --------------------------------------------------------
          // LAST WATERING
          // --------------------------------------------------------

          if (lastWatering != null)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    FarmerDesign.background,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.water_drop_rounded,
                    size: 20,
                    color:
                        FarmerDesign.info,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      wateredToday
                          ? '${(lastWatering!.waterAmount ?? 0).toStringAsFixed(1)} L • ${_formatTime(lastWatering!.wateringDate)}'
                          : 'Last watered ${_formatDate(lastWatering!.wateringDate)}',
                      style:
                          FarmerDesign
                              .bodyMedium,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    FarmerDesign
                        .warningLight,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color:
                        FarmerDesign.warning,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No watering recorded yet.',
                      style:
                          FarmerDesign
                              .bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 14),

          // --------------------------------------------------------
          // ACTIONS
          // --------------------------------------------------------

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onHistory,
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        FarmerDesign.primary,
                    side: const BorderSide(
                      color:
                          FarmerDesign.primary,
                    ),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'View History',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      field == null
                          ? null
                          : onRecord,
                  style:
                      FilledButton.styleFrom(
                    backgroundColor:
                        FarmerDesign.primary,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(
                    Icons.water_drop_rounded,
                    size: 18,
                  ),
                  label: Text(
                    wateredToday
                        ? 'Water Again'
                        : 'Record Watering',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatTime(
    DateTime date,
  ) {
    final hour =
        date.hour == 0
            ? 12
            : date.hour > 12
                ? date.hour - 12
                : date.hour;

    final minute =
        date.minute.toString().padLeft(
              2,
              '0',
            );

    final period =
        date.hour >= 12
            ? 'PM'
            : 'AM';

    return '$hour:$minute $period';
  }

  static String _formatDate(
    DateTime date,
  ) {
    final day =
        date.day.toString().padLeft(
              2,
              '0',
            );

    final month =
        date.month.toString().padLeft(
              2,
              '0',
            );

    return '$day/$month/${date.year}';
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge
    extends StatelessWidget {
  const _StatusBadge({
    required this.watered,
  });

  final bool watered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: watered
            ? FarmerDesign.successLight
            : FarmerDesign.warningLight,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            watered
                ? Icons.check_circle_rounded
                : Icons.circle_outlined,
            size: 16,
            color: watered
                ? FarmerDesign.success
                : FarmerDesign.warning,
          ),
          const SizedBox(width: 5),
          Text(
            watered
                ? 'Watered'
                : 'Not watered',
            style:
                FarmerDesign.caption.copyWith(
              color: watered
                  ? FarmerDesign.success
                  : FarmerDesign.warning,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SUMMARY CARD
// ============================================================================

class _SummaryCard
    extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            FarmerDesign.primaryLight,
        borderRadius:
            BorderRadius.circular(
          FarmerDesign.radiusMedium,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: FarmerDesign.primary,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: FarmerDesign.caption,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: FarmerDesign.heading3,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DIALOG INFO ROW
// ============================================================================

class _DialogInfoRow
    extends StatelessWidget {
  const _DialogInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            FarmerDesign.background,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: FarmerDesign.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      FarmerDesign.caption,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style:
                      FarmerDesign.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EMPTY CROPS
// ============================================================================

class _EmptyCrops
    extends StatelessWidget {
  const _EmptyCrops();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          FarmerDesign.radiusMedium,
        ),
        border: Border.all(
          color: FarmerDesign.border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.eco_outlined,
            size: 52,
            color: FarmerDesign.primary,
          ),
          SizedBox(height: 14),
          Text(
            'No crops yet',
            style: FarmerDesign.heading3,
          ),
          SizedBox(height: 6),
          Text(
            'Add crops to your farm before recording watering activity.',
            textAlign: TextAlign.center,
            style: FarmerDesign.caption,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ERROR CARD
// ============================================================================

class _ErrorCard
    extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          FarmerDesign.radiusMedium,
        ),
        border: Border.all(
          color: FarmerDesign.border,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 44,
            color: FarmerDesign.error,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style:
                FarmerDesign.bodyMedium,
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text(
              'Try Again',
            ),
          ),
        ],
      ),
    );
  }
}