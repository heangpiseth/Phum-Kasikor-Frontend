import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:phum_kasikors/controller/farmer/profile_controller.dart';
import 'package:phum_kasikors/core/constants/app_constants.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/view/Auth/wecome_screen.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';
import 'package:phum_kasikors/view/farmer/profile/farmer_camera_screen.dart';

// ================================================================
// FARMER PROFILE COLORS
// ================================================================

const Color farmerDeepGreen = Color(0xFF14532D);
const Color farmerGreen = Color(0xFF2E7D32);
const Color farmerLightGreen = Color(0xFFEAF6EA);
const Color farmerSoftGreen = Color(0xFFF3FAF3);
const Color farmerTextDark = Color(0xFF1F2A21);
const Color farmerTextGrey = Color(0xFF718071);

class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.isRegistered<FarmerProfileController>()
            ? Get.find<FarmerProfileController>()
            : Get.put(FarmerProfileController());

    return Scaffold(
      backgroundColor: FarmerDesign.background,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: FarmerDesign.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          'My Profile',
          style: TextStyle(
            color: farmerDeepGreen,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Edit profile',
            onPressed: () =>
                _openEditProfile(controller),
            icon: const Icon(
              Icons.edit_outlined,
              color: farmerDeepGreen,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Obx(
        () {
          if (controller.isLoading.value &&
              controller.userInfo.value == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: farmerGreen,
              ),
            );
          }

          return RefreshIndicator(
            color: farmerGreen,
            backgroundColor: Colors.white,
            onRefresh: controller.refreshProfile,

            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                35,
              ),

              children: [
                _buildHero(
                  context,
                  controller,
                ),

                const SizedBox(height: 18),

                _buildStats(),

                const SizedBox(height: 26),

                _buildSectionHeader(),

                const SizedBox(height: 13),

                _buildSettings(
                  controller,
                ),

                const SizedBox(height: 26),

                _buildLogout(),

                const SizedBox(height: 18),

                const Center(
                  child: Text(
                    'Phum Kasikor Farmer',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: farmerTextGrey,
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                const Center(
                  child: Text(
                    'Version 1.2.4',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFFA0ACA0),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==============================================================
  // HERO
  // ==============================================================

  Widget _buildHero(
    BuildContext context,
    FarmerProfileController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            farmerDeepGreen,
            Color(0xFF1B6B36),
            farmerGreen,
          ],
        ),

        boxShadow: const [
          BoxShadow(
            color: Color(0x261B5E20),
            blurRadius: 20,
            offset: Offset(0, 9),
          ),
        ],
      ),

      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.06,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            left: -35,
            bottom: -45,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.05,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Decorative leaf
          Positioned(
            right: 18,
            top: 30,
            child: Icon(
              Icons.eco_outlined,
              size: 42,
              color: Colors.white.withValues(
                alpha: 0.08,
              ),
            ),
          ),

          Positioned(
            left: 18,
            bottom: 24,
            child: Icon(
              Icons.grass_rounded,
              size: 40,
              color: Colors.white.withValues(
                alpha: 0.07,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              24,
              20,
              22,
            ),

            child: Column(
              children: [
                _buildAvatar(
                  context,
                  controller,
                ),

                const SizedBox(height: 14),

                // ==================================================
                // NAME
                // ==================================================

                Obx(
                  () => Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          controller.name.value
                                  .trim()
                                  .isEmpty
                              ? 'Farmer'
                              : controller.name.value,

                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),

                      const SizedBox(width: 7),

                      Container(
                        width: 21,
                        height: 21,

                        decoration:
                            const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: farmerGreen,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                // ==================================================
                // ROLE
                // ==================================================

                Obx(
                  () {
                    final role =
                        controller.role.value.trim();

                    final subtitle =
                        role.isEmpty ||
                                role.toLowerCase() ==
                                    'farmer'
                            ? 'Certified Organic Farmer'
                            : _formatRole(role);

                    return Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xD9FFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                // ==================================================
                // LOCAL FARMER BADGE
                // ==================================================

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.16,
                      ),
                    ),
                  ),

                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.eco_rounded,
                        size: 15,
                        color: Color(0xFFC8E6C9),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Local Farmer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // AVATAR
  // ==============================================================

  Widget _buildAvatar(
    BuildContext context,
    FarmerProfileController controller,
  ) {
    return GestureDetector(
      onTap: () => _showImageOptions(
        context,
        controller,
      ),

      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 104,
            height: 104,

            padding: const EdgeInsets.all(4),

            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,

              boxShadow: [
                BoxShadow(
                  color: Color(0x35000000),
                  blurRadius: 15,
                  offset: Offset(0, 6),
                ),
              ],
            ),

            child: Container(
              padding: const EdgeInsets.all(2),

              decoration: const BoxDecoration(
                color: Color(0xFFB7E0BB),
                shape: BoxShape.circle,
              ),

              child: ClipOval(
                child: Obx(
                  () {
                    final image =
                        controller.profileImage.value;

                    if (image == null ||
                        image.isEmpty) {
                      return _avatarFallback(
                        controller,
                      );
                    }

                    final imageUrl =
                        _profileImageUrl(image);

                    debugPrint(
                      'PROFILE IMAGE URL: $imageUrl',
                    );

                    return Image.network(
                      imageUrl,

                      key: ValueKey(imageUrl),

                      fit: BoxFit.cover,

                      loadingBuilder: (
                        context,
                        child,
                        loadingProgress,
                      ) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return const Center(
                          child: SizedBox(
                            width: 25,
                            height: 25,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: farmerGreen,
                            ),
                          ),
                        );
                      },

                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        debugPrint(
                          'PROFILE IMAGE ERROR: $error',
                        );

                        return _avatarFallback(
                          controller,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // ========================================================
          // UPLOAD LOADING
          // ========================================================

          Obx(
            () {
              if (!controller
                  .isUploadingImage.value) {
                return const SizedBox.shrink();
              }

              return Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: 0.45,
                    ),
                    shape: BoxShape.circle,
                  ),

                  child: const Center(
                    child: SizedBox(
                      width: 27,
                      height: 27,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // ========================================================
          // EDIT BADGE
          // ========================================================

          Positioned(
            right: 1,
            bottom: 0,

            child: Container(
              width: 32,
              height: 32,

              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: farmerGreen,
                  width: 2,
                ),
              ),

              child: const Icon(
                Icons.edit_rounded,
                size: 15,
                color: farmerGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // STATS
  // ==============================================================

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: const Color(0xFFDCEBDD),
        ),

        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          const Expanded(
            child: _StatItem(
              icon: Icons.inventory_2_outlined,
              value: '24',
              label: 'Products',
            ),
          ),

          _verticalDivider(),

          const Expanded(
            child: _StatItem(
              icon: Icons.receipt_long_outlined,
              value: '156',
              label: 'Orders',
            ),
          ),

          _verticalDivider(),

          const Expanded(
            child: _StatItem(
              icon: Icons.star_outline_rounded,
              value: '4.8',
              label: 'Rating',
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 48,
      color: const Color(0xFFDCE7DD),
    );
  }

  // ==============================================================
  // SECTION HEADER
  // ==============================================================

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          width: 39,
          height: 39,

          decoration: BoxDecoration(
            color: farmerLightGreen,
            borderRadius:
                BorderRadius.circular(12),
          ),

          child: const Icon(
            Icons.tune_rounded,
            size: 20,
            color: farmerGreen,
          ),
        ),

        const SizedBox(width: 11),

        const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Account & Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: farmerDeepGreen,
              ),
            ),

            SizedBox(height: 2),

            Text(
              'Manage your farmer account',
              style: TextStyle(
                fontSize: 11,
                color: farmerTextGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==============================================================
  // SETTINGS
  // ==============================================================

  Widget _buildSettings(
    FarmerProfileController controller,
  ) {
    return Column(
      children: [
        _ProfileMenuItem(
          icon: Icons.person_outline_rounded,
          title: 'Edit Profile Info',
          subtitle:
              'Update your personal information',
          onTap: () =>
              _openEditProfile(controller),
        ),

        const SizedBox(height: 10),

        _ProfileMenuItem(
          icon: Icons.eco_outlined,
          title: 'My Farm Details',
          subtitle:
              'Manage your farm information',
          onTap: _openMyFarm,
        ),

        const SizedBox(height: 10),

        _ProfileMenuItem(
          icon:
              Icons.account_balance_wallet_outlined,
          title: 'Payment & ABA Settings',
          subtitle:
              'Manage your payment information',
          onTap: () {
            Get.snackbar(
              'Payment & ABA',
              'Payment settings will be available here.',
              snackPosition:
                  SnackPosition.BOTTOM,
            );
          },
        ),

        const SizedBox(height: 10),

        _ProfileMenuItem(
          icon:
              Icons.notifications_none_rounded,
          title: 'Notification Preferences',
          subtitle:
              'Control your app notifications',
          onTap: () {
            Get.snackbar(
              'Notifications',
              'Notification preferences will be available here.',
              snackPosition:
                  SnackPosition.BOTTOM,
            );
          },
        ),

        const SizedBox(height: 10),

        _ProfileMenuItem(
          icon: Icons.language_rounded,
          title: 'Language (ភាសាខ្មែរ)',
          subtitle:
              'Choose your preferred language',
          onTap: () {
            Get.snackbar(
              'Language',
              'Language settings will be available here.',
              snackPosition:
                  SnackPosition.BOTTOM,
            );
          },
        ),

        const SizedBox(height: 10),

        _ProfileMenuItem(
          icon: Icons.help_outline_rounded,
          title: 'Help & Customer Support',
          subtitle:
              'Get help with Phum Kasikor',
          onTap: () {
            Get.snackbar(
              'Help & Support',
              'Customer support will be available here.',
              snackPosition:
                  SnackPosition.BOTTOM,
            );
          },
        ),

        const SizedBox(height: 10),

        _ProfileMenuItem(
          icon: Icons.description_outlined,
          title: 'Terms & Privacy Policy',
          subtitle:
              'Review our policies',
          onTap: () {
            Get.snackbar(
              'Terms & Privacy',
              'Terms and privacy information will be available here.',
              snackPosition:
                  SnackPosition.BOTTOM,
            );
          },
        ),
      ],
    );
  }

  // ==============================================================
  // LOGOUT
  // ==============================================================

  Widget _buildLogout() {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7F7),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: const Color(0xFFF3D4D4),
      ),
    ),
    child: SizedBox(
      width: double.infinity,
      height: 49,
      child: OutlinedButton.icon(
        onPressed: () {
          Get.defaultDialog(
            title: 'Log Out',
            titleStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              color: farmerDeepGreen,
            ),
            middleText: 'Are you sure you want to log out?',
            middleTextStyle: const TextStyle(
              color: farmerTextGrey,
            ),
            textCancel: 'Cancel',
            textConfirm: 'Log Out',
            confirmTextColor: Colors.white,
            cancelTextColor: farmerGreen,
            buttonColor: Colors.red,
            onConfirm: () {
              Get.back();

              Get.offAll(
                () => const WelcomeScreen(),
              );
            },
          );
        },
        icon: const Icon(
          Icons.logout_rounded,
          size: 18,
          color: Colors.red,
        ),
        label: const Text(
          'Log Out Account',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.red,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF1F1),
          side: const BorderSide(
            color: Color(0xFFE57373),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    ),
  );
}

  // ==============================================================
  // PROFILE IMAGE URL
  // ==============================================================

  String _profileImageUrl(String image) {
    final value = image.trim();

    if (value.isEmpty) {
      return '';
    }

    if (value.startsWith(
      'http://localhost:8000',
    )) {
      return value.replaceFirst(
        'http://localhost:8000',
        'http://10.0.2.2:8000',
      );
    }

    if (value.startsWith(
      'http://127.0.0.1:8000',
    )) {
      return value.replaceFirst(
        'http://127.0.0.1:8000',
        'http://10.0.2.2:8000',
      );
    }

    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    final baseUri =
        Uri.parse(ApiConstants.baseUrl);

    final origin = Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.hasPort
          ? baseUri.port
          : null,
    );

    final cleanPath =
        value.startsWith('/')
            ? value
            : '/$value';

    return '${origin.toString()}$cleanPath';
  }

  // ==============================================================
  // AVATAR FALLBACK
  // ==============================================================

  Widget _avatarFallback(
    FarmerProfileController controller,
  ) {
    final value =
        controller.name.value.trim();

    final letter = value.isEmpty
        ? 'F'
        : value[0].toUpperCase();

    return Container(
      color: farmerLightGreen,

      alignment: Alignment.center,

      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: farmerDeepGreen,
        ),
      ),
    );
  }

  // ==============================================================
  // IMAGE OPTIONS
  // ==============================================================

  void _showImageOptions(
    BuildContext context,
    FarmerProfileController controller,
  ) {
    if (controller.isUploadingImage.value) {
      return;
    }

    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            24,
          ),

          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,

                margin: const EdgeInsets.only(
                  bottom: 20,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFB9D4BB),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              const Text(
                'Profile photo',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: farmerDeepGreen,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Choose how you want to update your photo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: farmerTextGrey,
                ),
              ),

              const SizedBox(height: 18),

              // Camera
              _ImageOption(
                icon: Icons.camera_alt_rounded,
                title: 'Take a photo',
                subtitle: 'Use your camera',

                onTap: () async {
                  Get.back();

                  final result =
                      await Get.to<bool>(
                    () => const FarmerCameraScreen(),
                  );

                  if (result == true) {
                    await controller
                        .refreshProfile();

                    if (Get.isSnackbarOpen) {
                      Get.closeCurrentSnackbar();
                    }

                    Get.snackbar(
                      'Profile Photo',
                      'Your camera photo is now your profile photo.',
                      snackPosition:
                          SnackPosition.BOTTOM,
                      margin:
                          const EdgeInsets.all(16),
                    );
                  }
                },
              ),

              const SizedBox(height: 10),

              // Gallery
              _ImageOption(
                icon:
                    Icons.photo_library_rounded,
                title: 'Choose from gallery',
                subtitle:
                    'Select an existing photo',

                onTap: () async {
                  Get.back();

                  await controller
                      .pickProfileImage(
                    ImageSource.gallery,
                  );

                  await controller
                      .refreshProfile();
                },
              ),

              // Remove
              Obx(
                () {
                  final hasImage =
                      controller.profileImage.value !=
                              null &&
                          controller.profileImage
                              .value!
                              .isNotEmpty;

                  if (!hasImage) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      const SizedBox(height: 10),

                      _ImageOption(
                        icon:
                            Icons.delete_outline_rounded,
                        title: 'Remove photo',
                        subtitle:
                            'Use your default profile image',
                        iconColor: Colors.red,

                        onTap: () {
                          Get.back();

                          _removePhoto(
                            controller,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _removePhoto(
    FarmerProfileController controller,
  ) async {
    Get.snackbar(
      'Profile Photo',
      'Remove photo will be connected to the Laravel delete endpoint next.',
      snackPosition:
          SnackPosition.BOTTOM,
    );
  }

  // ==============================================================
  // NAVIGATION
  // ==============================================================

  Future<void> _openEditProfile(
    FarmerProfileController controller,
  ) async {
    final result = await Get.toNamed(
      AppRoutes.farmerEditProfile,
    );

    if (result == true) {
      await controller.refreshProfile();
    }
  }

  Future<void> _openMyFarm() async {
    await Get.toNamed(
      AppRoutes.farmerFarmProfile,
    );
  }
}

// ================================================================
// ROLE FORMATTER
// ================================================================

String _formatRole(String role) {
  if (role.isEmpty) {
    return 'Certified Organic Farmer';
  }

  return role[0].toUpperCase() +
      role.substring(1);
}

// ================================================================
// STAT ITEM
// ================================================================

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,

          decoration: const BoxDecoration(
            color: farmerLightGreen,
            shape: BoxShape.circle,
          ),

          child: Icon(
            icon,
            size: 17,
            color: farmerGreen,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: farmerDeepGreen,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: farmerTextGrey,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// PROFILE MENU ITEM
// ================================================================

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),

        splashColor: farmerLightGreen,
        highlightColor: farmerSoftGreen,

        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 11,
          ),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(17),

            border: Border.all(
              color: const Color(0xFFDCEBDD),
            ),

            boxShadow: const [
              BoxShadow(
                color: Color(0x09000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),

          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,

                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEAF7EA),
                      Color(0xFFDDF0DE),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(14),
                ),

                child: Icon(
                  icon,
                  size: 22,
                  color: farmerGreen,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: farmerTextDark,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 10.5,
                        color: farmerTextGrey,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 29,
                height: 29,

                decoration:
                    const BoxDecoration(
                  color: farmerSoftGreen,
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 19,
                  color: farmerGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// IMAGE OPTION
// ================================================================

class _ImageOption extends StatelessWidget {
  const _ImageOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final isDanger = iconColor != null;

    return Material(
      color: isDanger
          ? const Color(0xFFFFF5F5)
          : const Color(0xFFF1F8F1),

      borderRadius: BorderRadius.circular(17),

      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(17),

        child: Padding(
          padding: const EdgeInsets.all(13),

          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,

                decoration: BoxDecoration(
                  color: isDanger
                      ? const Color(0xFFFFE8E8)
                      : const Color(0xFFDFF0E0),

                  borderRadius:
                      BorderRadius.circular(14),
                ),

                child: Icon(
                  icon,
                  color:
                      iconColor ?? farmerGreen,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDanger
                            ? Colors.red.shade700
                            : farmerDeepGreen,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,

                      style: const TextStyle(
                        fontSize: 11,
                        color: farmerTextGrey,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: isDanger
                    ? Colors.red.shade300
                    : farmerGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}