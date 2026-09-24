import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/controller/farmer/watering_recommendation_controller.dart';

class FarmerWateringRecommendationScreen extends StatelessWidget {
  FarmerWateringRecommendationScreen({
    super.key,
    required this.cropId,
  });

  final dynamic cropId;

  final WateringRecommendationController controller = Get.put(
    WateringRecommendationController(),
  );

  @override
  Widget build(BuildContext context) {
    controller.loadRecommendation(cropId);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3),
      appBar: AppBar(
        title: const Text('Crop Recommendation'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 50,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      controller.loadRecommendation(cropId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = controller.recommendation.value;

        if (data == null) {
          return const Center(
            child: Text(
              'No recommendation available.',
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () {
            return controller.loadRecommendation(cropId);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _cropCard(data),
              const SizedBox(height: 12),

              _weatherCard(data),
              const SizedBox(height: 12),

              _wateringCard(data),
              const SizedBox(height: 12),

              _harvestCard(data),
              const SizedBox(height: 12),

              _relationshipCard(data),
            ],
          ),
        );
      }),
    );
  }

  // ============================================================
  // CROP
  // ============================================================

  Widget _cropCard(dynamic data) {
    final crop = data.crop;

    return _card(
      icon: Icons.grass,
      title: 'Crop',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Crop', crop.name),
          _row(
            'Growth stage',
            _capitalize(crop.growthStage),
          ),
          _row(
            'Planting date',
            crop.plantingDate ?? 'Not available',
          ),
          _row(
            'Days after planting',
            crop.daysAfterPlanting?.toString() ??
                'Not available',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REAL WEATHER
  // ============================================================

  Widget _weatherCard(dynamic data) {
    final weather = data.weather;

    return _card(
      icon: Icons.cloud,
      title: 'Real Weather',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(
            'Temperature',
            '${weather.temperature.toStringAsFixed(1)} °C',
          ),
          _row(
            'Rainfall',
            '${weather.rainfallMm.toStringAsFixed(1)} mm',
          ),
          _row(
            'Rain probability',
            '${weather.rainProbability.toStringAsFixed(0)}%',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WATERING
  // ============================================================

  Widget _wateringCard(dynamic data) {
    final watering = data.watering;

    return _card(
      icon: Icons.water_drop,
      title: 'Watering Recommendation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _status(
            watering.required
                ? 'Watering Required'
                : 'No Watering Needed',
            watering.required,
          ),

          const SizedBox(height: 12),

          _row(
            'Amount',
            '${watering.recommendedAmountMm.toStringAsFixed(1)} mm',
          ),

          _row(
            'Timing',
            watering.timing,
          ),

          const SizedBox(height: 8),

          Text(
            watering.reason,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),

          if (watering.weatherEffect.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              watering.weatherEffect,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // HARVEST
  // ============================================================

  Widget _harvestCard(dynamic data) {
    final harvest = data.harvest;

    final bool harvested = harvest.isHarvested;

    return _card(
      icon: harvested
          ? Icons.check_circle
          : Icons.agriculture,
      title: 'Harvest',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------
          // ACTUAL HARVEST EXISTS
          // ------------------------------------------------------

          if (harvested) ...[
            _status(
              'Harvested',
              false,
            ),

            const SizedBox(height: 14),

            if (harvest.actualHarvestDate != null)
              _row(
                'Actual harvest date',
                harvest.actualHarvestDate!,
              ),

            if (harvest.quantity != null)
              _row(
                'Quantity',
                harvest.quantity.toString(),
              ),

            if (harvest.quality != null &&
                harvest.quality!.isNotEmpty)
              _row(
                'Quality',
                harvest.quality!,
              ),

            if (harvest.condition != null &&
                harvest.condition!.isNotEmpty)
              _row(
                'Condition',
                harvest.condition!,
              ),

            if (harvest.notes != null &&
                harvest.notes!.isNotEmpty)
              _row(
                'Notes',
                harvest.notes!,
              ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This crop has an actual harvest record.',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]

          // ------------------------------------------------------
          // NOT HARVESTED YET
          // ------------------------------------------------------

          else ...[
            _status(
              'Not Harvested Yet',
              true,
            ),

            const SizedBox(height: 14),

            if (harvest.estimatedDate != null)
              _row(
                'Estimated harvest',
                harvest.estimatedDate!,
              ),

            if (harvest.daysRemaining != null)
              _row(
                'Days remaining',
                '${harvest.daysRemaining} days',
              ),

            _row(
              'Growth stage',
              _capitalize(harvest.growthStage),
            ),

            if (harvest.harvestDays != null)
              _row(
                'Expected growing period',
                '${harvest.harvestDays} days',
              ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.orange.shade800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Weather and crop growth are used to estimate the harvest timing.',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // RELATIONSHIP
  // ============================================================

  Widget _relationshipCard(dynamic data) {
    final relationship = data.relationship;

    return _card(
      icon: Icons.account_tree,
      title: 'How Everything Is Connected',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _relationship(
            'Weather',
            'Watering',
            relationship.weatherAffectsWatering,
          ),
          _relationship(
            'Crop growth stage',
            'Watering',
            relationship.cropStageAffectsWatering,
          ),
          _relationship(
            'Crop growth stage',
            'Harvest',
            relationship.cropStageAffectsHarvest,
          ),
          _relationship(
            'Planting date',
            'Harvest',
            relationship.plantingDateAffectsHarvest,
          ),
        ],
      ),
    );
  }

  Widget _relationship(
    String from,
    String to,
    bool active,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            active
                ? Icons.check_circle
                : Icons.cancel,
            size: 20,
            color: active
                ? const Color(0xFF2E7D32)
                : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$from → $to',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _card({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF2E7D32),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ROW
  // ============================================================

  Widget _row(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _status(
    String text,
    bool required,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: required
            ? Colors.orange.shade50
            : Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: required
              ? Colors.orange.shade800
              : Colors.green.shade800,
        ),
      ),
    );
  }

  // ============================================================
  // CAPITALIZE
  // ============================================================

  String _capitalize(String value) {
    if (value.isEmpty) return value;

    return value[0].toUpperCase() +
        value.substring(1);
  }
}