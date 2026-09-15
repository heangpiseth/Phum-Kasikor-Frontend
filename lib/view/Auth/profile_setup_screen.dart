import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/controller/auth/profile_setup_controller.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileSetupController());

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF6),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Profile Setup', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: Color(0xFF263238))),
                      const SizedBox(height: 3),
                      const Text('Tell us about yourself to begin trading.', style: TextStyle(fontSize: 13, color: Color(0xFF66808D))),
                      const SizedBox(height: 17),

                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 84, height: 84, padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF2E7D32), width: 2)),
                              child: const ClipOval(child: Icon(Icons.person, size: 45, color: Colors.grey)),
                            ),
                            Positioned(
                              right: -1, bottom: 0,
                              child: Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(color: const Color(0xFF2E7D32), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),
                      _buildLabel('Full Name'),
                      _buildTextField(controller: controller.fullNameController, hint: 'Enter your full name'),
                      const SizedBox(height: 10),
                      _buildLabel('Display Name'),
                      _buildTextField(controller: controller.displayNameController, hint: 'Enter your display name', required: false),
                      const SizedBox(height: 10),
                      _buildLabel('Bio / Description'),
                      _buildTextField(controller: controller.bioController, hint: 'Tell us about yourself', required: false),
                      const SizedBox(height: 10),

                      Obx(() => controller.isFarmer.value
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Farm Name (For Farmers)'),
                                _buildTextField(controller: controller.farmNameController, hint: 'Enter your farm name', required: false),
                                const SizedBox(height: 10),
                              ],
                            )
                          : const SizedBox.shrink()),

                      _buildLabel('Gender'),
                      Obx(() => _buildDropdown(controller.selectedGender.value, controller.setGender)),
                      const SizedBox(height: 10),
                      _buildLabel('Date of Birth'),
                      Obx(() => _buildDateField(context, controller)),
                      const SizedBox(height: 18),
 Obx(() => controller.errorMessage.value != null
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(controller.errorMessage.value!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                            )
                          : const SizedBox.shrink()),

                      Obx(() => SizedBox(
                        width: double.infinity, height: 44,
                        child: ElevatedButton(
                          onPressed: controller.isSubmitting.value ? null : controller.saveAndContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(controller.isSubmitting.value ? 'Saving...' : 'Save & Continue', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ),
                      )),

                      const SizedBox(height: 11),
                      Center(
                        child: TextButton(
                          onPressed: controller.skip,
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF607D8B)),
                          child: const Text('Skip for now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
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
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 1, bottom: 5),
    child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF557180))),
  );

  Widget _buildTextField({required TextEditingController controller, required String hint, bool required = true}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 13, color: Color(0xFF37474F)),
      validator: required ? (value) => (value == null || value.trim().isEmpty) ? 'Required' : null : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF90A4AE)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        filled: true, fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.3)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Colors.redAccent)),
      ),
    );
  }
Widget _buildDropdown(String value, ValueChanged<String?> onChanged) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11), border: Border.all(color: const Color(0xFFE0E0E0))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF607D8B)),
          style: const TextStyle(fontSize: 13, color: Color(0xFF37474F)),
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, ProfileSetupController controller) {
    final date = controller.selectedDate.value;
    return InkWell(
      onTap: () => controller.pickDate(context),
      borderRadius: BorderRadius.circular(11),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11), border: Border.all(color: const Color(0xFFE0E0E0))),
        child: Row(
          children: [
            Expanded(child: Text(date == null ? 'Select date' : '${date.day}/${date.month}/${date.year}', style: const TextStyle(fontSize: 13, color: Color(0xFF37474F)))),
            const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF607D8B)),
          ],
        ),
      ),
    );
  }
}