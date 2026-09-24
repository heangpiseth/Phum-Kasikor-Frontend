import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/farm_map_controller.dart';
import 'package:phum_kasikors/model/customer/costumer_farm_model.dart';
import 'package:phum_kasikors/widgets/costumer/rating_stars.dart';

class FarmMapView extends GetView<FarmMapController> {
  const FarmMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return Center(child: Text(controller.errorMessage.value));
              }
              return controller.displayMode.value == FarmMapDisplayMode.map
                  ? _MapCanvas(controller: controller)
                  : _FarmListView(controller: controller);
            }),

            Positioned(
              top: 8,
              left: 8,
              child: RoundIconButton(
                icon: Icons.arrow_back,
                onTap: () => Get.back(),
                backgroundColor: const Color(0xFFE0E0E0),
                iconColor: const Color(0xFF616161),
              ),
            ),

            Positioned(
              top: 8,
              left: 60,
              child: Obx(
                () => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _toggleChip(
                        'Map View',
                        FarmMapDisplayMode.map,
                        controller,
                      ),
                      _toggleChip(
                        'List View',
                        FarmMapDisplayMode.list,
                        controller,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 8,
              right: 8,
              child: RoundIconButton(
                icon: Icons.my_location,
                onTap: () {
                  Get.snackbar(
                    'Location',
                    'Current-location centering is not available yet.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                backgroundColor: const Color(0xFFE0E0E0),
                iconColor: const Color(0xFF616161),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Obx(() {
                final farm = controller.selectedFarm;
                if (farm == null) {
                  return const SizedBox.shrink();
                }
                return _FarmInfoCard(controller: controller, farm: farm);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleChip(
    String label,
    FarmMapDisplayMode mode,
    FarmMapController controller,
  ) {
    final selected = controller.displayMode.value == mode;
    return GestureDetector(
      onTap: () => controller.setDisplayMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required Color backgroundColor,
    required Color iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

class _MapCanvas extends StatelessWidget {
  final FarmMapController controller;
  const _MapCanvas({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFDCEBD8),
      child: Obx(
        () => Stack(
          children: List.generate(controller.farms.length, (i) {
            final farm = controller.farms[i];
            final selected = farm.id == controller.selectedFarmId.value;
            final left = 60.0 + (i * 90) % 260;
            final top = 140.0 + (i * 130) % 320;
            return Positioned(
              left: left,
              top: top,
              child: GestureDetector(
                onTap: () => controller.selectFarm(farm.id.toString()),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 150),
                  scale: selected ? 1.15 : 1.0,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          farm.farmName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color:
                                selected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.location_on,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _FarmListView extends StatelessWidget {
  final FarmMapController controller;
  const _FarmListView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 70, 16, 160),
        itemCount: controller.farms.length,
        itemBuilder: (_, i) {
          final farm = controller.farms[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              onTap: () => controller.selectFarm(farm.id.toString()),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  farm.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 50,
                    height: 50,
                    color: AppColors.divider,
                    child: const Icon(Icons.agriculture),
                  ),
                ),
              ),
              title: Text(
                farm.farmName,
                style:
                    const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${farm.location} • ${farm.distanceKm}km away',
              ),
              trailing: RatingStars(rating: farm.rating),
            ),
          );
        },
      ),
    );
  }
}

class _FarmInfoCard extends StatelessWidget {
  final FarmMapController controller;
  final FarmModel farm;

  const _FarmInfoCard({required this.controller, required this.farm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  farm.imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 56,
                    height: 56,
                    color: AppColors.divider,
                    child: const Icon(Icons.agriculture),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farm.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${farm.location} • ${farm.distanceKm}km away',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              RatingStars(rating: farm.rating),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => controller.openFarmDetail(farm.id.toString()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View Details'),
              ),
              OutlinedButton(
                onPressed: () =>
                    controller.openFarmProducts(farm.id.toString()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View Products'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
