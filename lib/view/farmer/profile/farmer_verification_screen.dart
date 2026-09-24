import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/controller/farmer/farmer_verification_controller.dart';

class FarmerVerificationScreen extends StatefulWidget {
  const FarmerVerificationScreen({super.key});

  @override
  State<FarmerVerificationScreen> createState() =>
      _FarmerVerificationScreenState();
}

class _FarmerVerificationScreenState
    extends State<FarmerVerificationScreen> {
  late final FarmerVerificationController controller;

  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _idNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();

    controller = Get.find<FarmerVerificationController>();

    final verification = controller.verification.value;

    if (verification != null) {
      _fullNameController.text = verification.fullName;
      _idNumberController.text = verification.idNumber;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8F3),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Identity Verification',
          style: TextStyle(
            color: Color(0xFF1B1B1B),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF1B1B1B),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2E7D32),
            ),
          );
        }

        final verification = controller.verification.value;

        if (verification?.isPending == true) {
          return _buildPendingState();
        }

        if (verification?.isApproved == true) {
          return _buildApprovedState();
        }

        return _buildVerificationForm(
          rejectedVerification: verification?.isRejected == true,
        );
      }),
    );
  }

  // ============================================================
  // FORM
  // ============================================================

  Widget _buildVerificationForm({
    required bool rejectedVerification,
  }) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          32,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                rejectedVerification: rejectedVerification,
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(
                'Personal Information',
                'Enter the information exactly as shown on your ID.',
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _fullNameController,
                label: 'Full name',
                hint: 'Enter your full name',
                icon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _idNumberController,
                label: 'National ID number',
                hint: 'Enter your National ID number',
                icon: Icons.badge_outlined,
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your National ID number.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 28),

              _buildSectionTitle(
                'ID Documents',
                'Take clear photos of both sides of your National ID.',
              ),

              const SizedBox(height: 16),

              Obx(
                () => _buildImagePickerCard(
                  title: 'Front side',
                  subtitle: 'Front of your National ID',
                  icon: Icons.credit_card_outlined,
                  image: controller.frontImage.value,
                  onPick: controller.pickFrontImage,
                  onRemove: controller.removeFrontImage,
                ),
              ),

              const SizedBox(height: 16),

              Obx(
                () => _buildImagePickerCard(
                  title: 'Back side',
                  subtitle: 'Back of your National ID',
                  icon: Icons.credit_card_outlined,
                  image: controller.backImage.value,
                  onPick: controller.pickBackImage,
                  onRemove: controller.removeBackImage,
                ),
              ),

              const SizedBox(height: 24),

              _buildPrivacyNotice(),

              const SizedBox(height: 24),

              Obx(() {
                final error = controller.errorMessage.value;

                if (error.isEmpty) {
                  return const SizedBox.shrink();
                }

                return _buildErrorMessage(error);
              }),

              const SizedBox(height: 12),

              Obx(
                () => _buildSubmitButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader({
    required bool rejectedVerification,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rejectedVerification
                      ? 'Resubmit your verification'
                      : 'Verify your identity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  rejectedVerification
                      ? 'Please correct the information and submit your documents again.'
                      : 'Verify your identity to build trust with customers on Phum Kasikor.',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF365A39),
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
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            height: 1.4,
            color: Color(0xFF6B6B6B),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextCapitalization textCapitalization =
        TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2B2B2B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF2E7D32),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF2E7D32),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.redAccent,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // IMAGE CARD
  // ============================================================

  Widget _buildImagePickerCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required File? image,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    final hasImage = image != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasImage
              ? const Color(0xFF2E7D32)
              : Colors.grey.shade200,
          width: hasImage ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          if (hasImage)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 190,
                    child: Image.file(
                      image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onRemove,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasImage
                        ? Icons.check_circle_outline
                        : icon,
                    color: const Color(0xFF2E7D32),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        hasImage
                            ? 'Photo selected'
                            : subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF777777),
                        ),
                      ),
                    ],
                  ),
                ),

                TextButton(
                  onPressed: onPick,
                  style: TextButton.styleFrom(
                    foregroundColor:
                        const Color(0xFF2E7D32),
                  ),
                  child: Text(
                    hasImage ? 'Change' : 'Add photo',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
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
  // PRIVACY NOTICE
  // ============================================================

  Widget _buildPrivacyNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline,
            color: Color(0xFF8D6E00),
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your ID documents are uploaded securely and kept private. They are not displayed publicly on your farmer profile.',
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF6D5A00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.redAccent,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFFC62828),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================

  Widget _buildSubmitButton() {
    final isSubmitting = controller.isSubmitting.value;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          disabledBackgroundColor:
              const Color(0xFF9E9E9E),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Submit for Verification',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await controller.submitVerification(
      idNumber: _idNumberController.text,
      fullName: _fullNameController.text,
    );

    if (!mounted) return;

    if (success) {
      Get.snackbar(
        'Verification submitted',
        'Your identity documents have been submitted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ============================================================
  // PENDING
  // ============================================================

  Widget _buildPendingState() {
    final verification = controller.verification.value;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3CD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: Color(0xFFB8860B),
                  size: 45,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Verification Pending',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Your identity documents have been submitted successfully and are waiting for verification.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF6B6B6B),
                ),
              ),

              if (verification?.submittedAt != null) ...[
                const SizedBox(height: 18),
                Text(
                  'Submitted ${_formatDate(verification!.submittedAt!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.security_outlined,
                      color: Color(0xFF2E7D32),
                      size: 28,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Your documents are kept private.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'You can return here later to check your verification status.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              OutlinedButton.icon(
                onPressed: controller.refreshVerification,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Status'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                  side: const BorderSide(
                    color: Color(0xFF2E7D32),
                  ),
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // APPROVED
  // ============================================================

  Widget _buildApprovedState() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 95,
                height: 95,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF2E7D32),
                  size: 52,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Identity Verified',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B5E20),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Your farmer identity has been verified successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF6B6B6B),
                ),
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: Color(0xFF2E7D32),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Verified farmer',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF2E7D32),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
} 