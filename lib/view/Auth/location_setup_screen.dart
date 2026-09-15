 import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/controller/auth/location_setup_controller.dart';

class LocationSetupScreen extends StatelessWidget {
  const LocationSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LocationSetupController());

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF6),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(21, 35, 21, 10),
                child: Column(
                  children: [
                    _buildMapCard(),
                    const SizedBox(height: 18),
                    const Text('Set Your Location', textAlign: TextAlign.center, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Color(0xFF263238))),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        'PHUM KASIKOR uses your location to discover the\nnearest fresh farms and optimal delivery routes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5, height: 1.45, color: Color(0xFF66808D)),
                      ),
                    ),
                    const SizedBox(height: 17),

                    _buildLabel('Province / City'),
                    Obx(() => _buildDropdown(
                      value: controller.selectedProvince.value,
                      items: const ['Phnom Penh', 'Kampong Cham', 'Siem Reap', 'Kandal'],
                      onChanged: controller.setProvince,
                    )),
                    const SizedBox(height: 10),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('District'),
                              Obx(() => _buildDropdown(
                                value: controller.selectedDistrict.value,
                                items: const ['Chroy Chang...', 'Doun Penh', 'Sen Sok', 'Chamkarmon'],
                                onChanged: controller.setDistrict,
                              )),
                            ],
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Commune'),
                              Obx(() => _buildDisabledField(controller.selectedCommune.value)),
                            ],
                          ),
                        ),
                      ],
                    ),
 const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity, height: 43,
                      child: ElevatedButton.icon(
                        onPressed: controller.useCurrentLocation,
                        icon: const Icon(Icons.navigation_outlined, size: 19),
                        label: const Text('Use Current Location', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE7F4E9), foregroundColor: const Color(0xFF2E7D32), elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 11),

                    Obx(() => controller.errorMessage.value != null
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(controller.errorMessage.value!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                          )
                        : const SizedBox.shrink()),

                    Obx(() => SizedBox(
                      width: double.infinity, height: 46,
                      child: ElevatedButton(
                        onPressed: controller.isSubmitting.value ? null : controller.setLocationAndContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, elevation: 2,
                          shadowColor: const Color(0x662E7D32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(controller.isSubmitting.value ? 'Saving...' : 'Set Location', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    )),
                    const SizedBox(height: 7),

                    TextButton(
                      onPressed: controller.skip,
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF607D8B)),
                      child: const Text('Skip', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Container(width: 110, height: 4, decoration: BoxDecoration(color: const Color(0xFFD0D0D0), borderRadius: BorderRadius.circular(10))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      width: double.infinity, height: 192, padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE0E0E0))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            Container(decoration: const BoxDecoration(color: Color(0xFF9FE58D))),
            const Positioned(
              top: 10, left: 0, right: 0,
              child: Center(child: Text('PHNOM PENH', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: .5))),
            ),
            Positioned(
              left: 5, top: 5,
              child: Container(
                width: 34, height: 34,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: IconButton(padding: EdgeInsets.zero, onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF37474F))),
              ),
            ),
            const Center(child: Icon(Icons.location_on, size: 42, color: Color(0xFFEF5350))),
          ],
        ),
      ),
    );
  }
 Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 1, bottom: 5),
    child: Align(alignment: Alignment.centerLeft, child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF557180)))),
  );

  Widget _buildDropdown({required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      height: 42, padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11), border: Border.all(color: const Color(0xFFE0E0E0))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF607D8B)),
          style: const TextStyle(fontSize: 13, color: Color(0xFF37474F)),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDisabledField(String value) {
    return Container(
      height: 42, padding: const EdgeInsets.symmetric(horizontal: 13), alignment: Alignment.centerLeft,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11), border: Border.all(color: const Color(0xFFE0E0E0))),
      child: Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF90A4AE))),
    );
  }
}