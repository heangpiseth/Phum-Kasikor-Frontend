import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/controller/farmer/crop_controller.dart';
import 'package:phum_kasikors/controller/farmer/farm_controller.dart';
import 'package:phum_kasikors/model/farmer/crop_model.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';
import 'package:phum_kasikors/view/farmer/farm/farmer_add_crop_screen.dart';
import 'package:phum_kasikors/view/farmer/farm/farmer_crop_detail_screen.dart';

class FarmerCropsScreen extends StatefulWidget {
  const FarmerCropsScreen({
    super.key,
    this.farmId,
  });

  final String? farmId;

  @override
  State<FarmerCropsScreen> createState() => _FarmerCropsScreenState();
}

class _FarmerCropsScreenState extends State<FarmerCropsScreen> {
  late final CropController cropController;
  late final FarmController farmController;

  String get resolvedFarmId {
    if (widget.farmId != null &&
        widget.farmId!.trim().isNotEmpty) {
      return widget.farmId!;
    }

    return farmController.farm.value?.id ?? '';
  }

  @override
  void initState() {
    super.initState();

    cropController = Get.isRegistered<CropController>()
        ? Get.find<CropController>()
        : Get.put(CropController());

    farmController = Get.isRegistered<FarmController>()
        ? Get.find<FarmController>()
        : Get.put(FarmController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCrops();
    });
  }

  Future<void> _loadCrops() async {
    final farmId = resolvedFarmId;

    if (farmId.isEmpty) {
      return;
    }

    await cropController.loadCrops(farmId);
  }

  Future<void> _addCrop() async {
    final farmId = resolvedFarmId;

    if (farmId.isEmpty) {
      _showMessage(
        'Farm unavailable',
        'Your farm information could not be found.',
        isError: true,
      );
      return;
    }

    await Get.to(
      () => FarmerAddCropScreen(
        farmId: farmId,
      ),
    );

    await _loadCrops();
  }

  Future<void> _openCrop(CropModel crop) async {
    final farmId = resolvedFarmId;

    if (farmId.isEmpty) {
      return;
    }

    await Get.to(
      () => FarmerCropDetailScreen(
        farmId: farmId,
        cropId: crop.id,
      ),
    );

    await _loadCrops();
  }

  void _showMessage(
    String title,
    String message, {
    bool isError = false,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          isError ? FarmerDesign.error : FarmerDesign.primaryDark,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
    );
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
          'Crops',
          style: FarmerDesign.heading2,
        ),
        actions: [
          IconButton(
            onPressed: _loadCrops,
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh_rounded,
              color: FarmerDesign.text,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCrop,
        backgroundColor: FarmerDesign.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add crop',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        final crops = cropController.crops.toList();
        final loading = cropController.isLoading.value;
        final error = cropController.errorMessage.value;

        if (loading && crops.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: FarmerDesign.primary,
            ),
          );
        }

        return RefreshIndicator(
          color: FarmerDesign.primary,
          onRefresh: _loadCrops,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              100,
            ),
            children: [
              _CropSummary(count: crops.length),
              const SizedBox(height: 22),
              if (error.isNotEmpty && crops.isEmpty)
                _ErrorState(
                  message: error,
                  onRetry: _loadCrops,
                )
              else if (crops.isEmpty)
                _EmptyCrops(
                  onAdd: _addCrop,
                )
              else ...[
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Your crops',
                        style: FarmerDesign.heading3,
                      ),
                    ),
                    Text(
                      '${crops.length} ${crops.length == 1 ? 'crop' : 'crops'}',
                      style: FarmerDesign.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...crops.map(
                  (crop) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CropCard(
                      crop: crop,
                      onTap: () => _openCrop(crop),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _CropSummary extends StatelessWidget {
  const _CropSummary({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FarmerDesign.primary,
        borderRadius: BorderRadius.circular(
          FarmerDesign.radiusLarge,
        ),
        boxShadow: FarmerDesign.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.grass_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active crops',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  count == 1
                      ? 'crop on your farm'
                      : 'crops on your farm',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  const _CropCard({
    required this.crop,
    required this.onTap,
  });

  final CropModel crop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = crop.status.trim().isEmpty
        ? 'Growing'
        : crop.status;

    final quantity = crop.quantityPlanted;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        FarmerDesign.radiusMedium,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          FarmerDesign.radiusMedium,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              FarmerDesign.radiusMedium,
            ),
            border: Border.all(
              color: FarmerDesign.border,
            ),
            boxShadow: FarmerDesign.cardShadow,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _CropImage(
                    image: crop.imageUrl,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.name.isEmpty
                              ? 'Unnamed crop'
                              : crop.name,
                          style: FarmerDesign.heading3,
                        ),
                        const SizedBox(height: 5),
                        if (crop.variety != null &&
                            crop.variety!.trim().isNotEmpty)
                          Text(
                            crop.variety!,
                            style: FarmerDesign.caption,
                          ),
                        const SizedBox(height: 8),
                        _StatusBadge(status: status),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: FarmerDesign.mutedText,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(
                height: 1,
                color: FarmerDesign.border,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _CropInfo(
                      icon: Icons.calendar_today_outlined,
                      title: 'Planted',
                      value: crop.plantedAt == null
                          ? 'Not set'
                          : _formatDate(crop.plantedAt!),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 34,
                    color: FarmerDesign.border,
                  ),
                  Expanded(
                    child: _CropInfo(
                      icon: Icons.inventory_2_outlined,
                      title: 'Quantity',
                      value: quantity == null
                          ? 'Not set'
                          : _formatNumber(quantity),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}

class _CropImage extends StatelessWidget {
  const _CropImage({
    required this.image,
  });

  final String? image;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        image != null && image!.trim().isNotEmpty;

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: FarmerDesign.primaryLight,
        borderRadius: BorderRadius.circular(17),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              image!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.grass_rounded,
                  color: FarmerDesign.primary,
                  size: 29,
                );
              },
            )
          : const Icon(
              Icons.grass_rounded,
              color: FarmerDesign.primary,
              size: 29,
            ),
    );
  }
}

class _CropInfo extends StatelessWidget {
  const _CropInfo({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 17,
          color: FarmerDesign.primary,
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: FarmerDesign.caption,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FarmerDesign.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final Color background;
    final Color foreground;

    if (normalized.contains('harvest') ||
        normalized.contains('ready')) {
      background = FarmerDesign.warningLight;
      foreground = FarmerDesign.warning;
    } else if (normalized.contains('complete') ||
        normalized.contains('healthy')) {
      background = FarmerDesign.successLight;
      foreground = FarmerDesign.success;
    } else {
      background = FarmerDesign.infoLight;
      foreground = FarmerDesign.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyCrops extends StatelessWidget {
  const _EmptyCrops({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        24,
        36,
        24,
        36,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          FarmerDesign.radiusLarge,
        ),
        border: Border.all(
          color: FarmerDesign.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: FarmerDesign.primaryLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.grass_rounded,
              size: 38,
              color: FarmerDesign.primary,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No crops yet',
            style: FarmerDesign.heading3,
          ),
          const SizedBox(height: 7),
          const Text(
            'Add your crops to keep track of planting, '
            'growth and harvest information.',
            textAlign: TextAlign.center,
            style: FarmerDesign.body,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add first crop'),
            style: FilledButton.styleFrom(
              backgroundColor: FarmerDesign.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FarmerDesign.errorLight,
        borderRadius: BorderRadius.circular(
          FarmerDesign.radiusMedium,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: FarmerDesign.error,
            size: 34,
          ),
          const SizedBox(height: 10),
          const Text(
            'Could not load crops',
            style: FarmerDesign.heading3,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: FarmerDesign.caption,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}