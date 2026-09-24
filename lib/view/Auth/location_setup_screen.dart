import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phum_kasikors/controller/auth/location_setup_controller.dart';

class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  late final LocationSetupController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<LocationSetupController>()
        ? Get.find<LocationSetupController>()
        : Get.put(LocationSetupController());
  }

  @override
  void dispose() {
    // Do not delete the controller here because it may still be needed
    // while the location is being saved / route is changing.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8F3),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farm Location',
              style: TextStyle(
                color: Color(0xFF18231C),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Set where your farm is located',
              style: TextStyle(
                color: Color(0xFF748078),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntro(),
                const SizedBox(height: 20),
                _buildMap(),
                const SizedBox(height: 18),
                _buildDetectedMessage(),
                const SizedBox(height: 14),
                _buildLocationDetails(),
                const SizedBox(height: 14),
                _buildErrorMessage(),
                const SizedBox(height: 22),
                _buildConfirmButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INTRO
  // ============================================================

  Widget _buildIntro() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Where is your farm?',
          style: TextStyle(
            color: Color(0xFF18231C),
            fontSize: 25,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Move the pin to your farm location. '
          'We will automatically detect your province, district, and commune.',
          style: TextStyle(
            color: Color(0xFF748078),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MAP
  // ============================================================

  Widget _buildMap() {
    final location = controller.pickedLocation.value;

    return Container(
      height: 345,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE3E8E1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: location,
              zoom: 15,
            ),
            onMapCreated: controller.onMapCreated,
            onTap: controller.onPinMoved,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId('farm_location'),
                position: location,
                draggable: true,
                onDragEnd: controller.onPinMoved,
              ),
            },
          ),

          // ------------------------------------------------------
          // MAP TOP LABEL
          // ------------------------------------------------------

          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF3D7A4A),
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set your farm pin',
                          style: TextStyle(
                            color: Color(0xFF18231C),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tap the map or drag the pin',
                          style: TextStyle(
                            color: Color(0xFF748078),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------------------------
          // CURRENT LOCATION BUTTON
          // ------------------------------------------------------

          Positioned(
            right: 14,
            bottom: 14,
            child: _CircleButton(
              icon: Icons.my_location_rounded,
              onTap: controller.isLocating.value
                  ? null
                  : controller.useCurrentLocation,
            ),
          ),

          // ------------------------------------------------------
          // FARM LOCATION LABEL
          // ------------------------------------------------------

          Positioned(
            bottom: 18,
            left: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.push_pin_rounded,
                    color: Color(0xFF3D7A4A),
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Farm location',
                    style: TextStyle(
                      color: Color(0xFF18231C),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETECTION STATUS
  // ============================================================

  Widget _buildDetectedMessage() {
    if (controller.isDetectingAddress.value) {
      return _StatusCard(
        icon: Icons.sync_rounded,
        iconColor: const Color(0xFF3D7A4A),
        backgroundColor: const Color(0xFFEAF4E9),
        title: 'Detecting location...',
        subtitle: 'Finding your province, district, and commune.',
      );
    }

    final hasLocation =
        controller.selectedProvince.value.isNotEmpty ||
        controller.selectedDistrict.value.isNotEmpty ||
        controller.selectedCommune.value.isNotEmpty;

    if (hasLocation) {
      return _StatusCard(
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFF3D7A4A),
        backgroundColor: const Color(0xFFEAF4E9),
        title: 'Location detected',
        subtitle: 'Your administrative location has been detected.',
      );
    }

    return const SizedBox.shrink();
  }

  // ============================================================
  // LOCATION DETAILS
  // ============================================================

  Widget _buildLocationDetails() {
    final hasAddress =
        controller.formattedAddress.value.trim().isNotEmpty;

    final hasAdminLocation =
        controller.selectedProvince.value.trim().isNotEmpty ||
        controller.selectedDistrict.value.trim().isNotEmpty ||
        controller.selectedCommune.value.trim().isNotEmpty;

    final hasCoordinates =
        controller.latitude.value != null &&
        controller.longitude.value != null;

    if (!hasAddress && !hasAdminLocation && !hasCoordinates) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE3E8E1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------
          // HEADER
          // ------------------------------------------------------

          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4E9),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF3D7A4A),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detected location',
                      style: TextStyle(
                        color: Color(0xFF18231C),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Based on your selected map position',
                      style: TextStyle(
                        color: Color(0xFF748078),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasAdminLocation)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Detected',
                    style: TextStyle(
                      color: Color(0xFF3D7A4A),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------------
          // FULL ADDRESS
          // ------------------------------------------------------

          if (hasAddress) ...[
            const Text(
              'Full address',
              style: TextStyle(
                color: Color(0xFF748078),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              controller.formattedAddress.value,
              style: const TextStyle(
                color: Color(0xFF18231C),
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
          ],

          // ------------------------------------------------------
          // PROVINCE
          // ------------------------------------------------------

          _buildLocationField(
            icon: Icons.map_rounded,
            label: 'Province',
            value: controller.selectedProvince.value,
          ),

          const SizedBox(height: 12),

          // ------------------------------------------------------
          // DISTRICT
          // ------------------------------------------------------

          _buildLocationField(
            icon: Icons.location_city_rounded,
            label: 'District',
            value: controller.selectedDistrict.value,
          ),

          const SizedBox(height: 12),

          // ------------------------------------------------------
          // COMMUNE
          // ------------------------------------------------------

          _buildLocationField(
            icon: Icons.home_work_rounded,
            label: 'Commune',
            value: controller.selectedCommune.value,
          ),

          // ------------------------------------------------------
          // GPS
          // ------------------------------------------------------

          if (hasCoordinates) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8F3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.gps_fixed_rounded,
                    color: Color(0xFF3D7A4A),
                    size: 18,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'GPS: ${controller.latitude.value!.toStringAsFixed(6)}, '
                      '${controller.longitude.value!.toStringAsFixed(6)}',
                      style: const TextStyle(
                        color: Color(0xFF59645D),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
  // LOCATION FIELD
  // ============================================================

  Widget _buildLocationField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final hasValue = value.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE3E8E1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3D7A4A),
              size: 18,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF748078),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hasValue ? value : 'Waiting for location...',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasValue
                        ? const Color(0xFF18231C)
                        : const Color(0xFF9AA39D),
                    fontSize: 14,
                    fontWeight: hasValue
                        ? FontWeight.w600
                        : FontWeight.w400,
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
  // ERROR
  // ============================================================

  Widget _buildErrorMessage() {
    final message = controller.errorMessage.value;

    if (message == null || message.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1D0CB),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFC75C4D),
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF8E4036),
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONFIRM BUTTON
  // ============================================================

  Widget _buildConfirmButton() {
    final isLoading = controller.isSubmitting.value;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : controller.setLocationAndContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3D7A4A),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFFB7C6B9),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Confirm Farm Location',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }
}

// ================================================================
// STATUS CARD
// ================================================================

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF18231C),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF748078),
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

// ================================================================
// CIRCLE BUTTON
// ================================================================

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: const Color(0xFF3D7A4A),
            size: 22,
          ),
        ),
      ),
    );
  }
}