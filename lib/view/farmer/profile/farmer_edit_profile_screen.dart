import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';

class FarmerEditProfileScreen extends StatefulWidget {
  const FarmerEditProfileScreen({super.key});

  @override
  State<FarmerEditProfileScreen> createState() =>
      _FarmerEditProfileScreenState();
}

class _FarmerEditProfileScreenState
    extends State<FarmerEditProfileScreen> {
  final nameController = TextEditingController();
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final bioController = TextEditingController();

  bool isLoading = false;
  bool isSaving = false;

  String? selectedGender;
  DateTime? selectedDateOfBirth;

  final List<String> genders = const [
    'male',
    'female',
    'other',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadProfile();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    displayNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final response = await ApiClient.get('me');

      if (response is Map) {
        final data = Map<String, dynamic>.from(response);

        final user = data['user'] is Map
            ? Map<String, dynamic>.from(data['user'])
            : data;

        nameController.text =
            user['name']?.toString() ?? '';

        displayNameController.text =
            user['display_name']?.toString() ?? '';

        emailController.text =
            user['email']?.toString() ?? '';

        phoneController.text =
            user['phone']?.toString() ?? '';

        locationController.text =
            user['location']?.toString() ?? '';

        bioController.text =
            user['bio']?.toString() ?? '';

        final gender = user['gender']?.toString();

        if (gender != null &&
            genders.contains(gender.toLowerCase())) {
          selectedGender = gender.toLowerCase();
        }

        final dob = user['date_of_birth']?.toString();

        if (dob != null && dob.isNotEmpty) {
          selectedDateOfBirth = DateTime.tryParse(dob);
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Unable to load profile',
          _cleanError(e),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> selectDateOfBirth() async {
    final now = DateTime.now();

    final initialDate =
        selectedDateOfBirth ??
        DateTime(
          now.year - 18,
          now.month,
          now.day,
        );

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: DateTime(
        now.year - 13,
        now.month,
        now.day,
      ),
      helpText: 'Select your date of birth',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
    );

    if (date != null) {
      setState(() {
        selectedDateOfBirth = date;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> saveProfile() async {
    FocusScope.of(context).unfocus();

    final name = nameController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Missing name',
        'Please enter your full name.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (emailController.text.trim().isNotEmpty &&
        !_isValidEmail(emailController.text.trim())) {
      Get.snackbar(
        'Invalid email',
        'Please enter a valid email address.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (phoneController.text.trim().isNotEmpty &&
        phoneController.text.trim().length < 8) {
      Get.snackbar(
        'Invalid phone',
        'Please enter a valid phone number.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (mounted) {
      setState(() {
        isSaving = true;
      });
    }

    try {
      final body = <String, dynamic>{
        'name': name,
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'location': locationController.text.trim(),
        'bio': bioController.text.trim(),
        'display_name':
            displayNameController.text.trim(),
      };

      if (selectedGender != null) {
        body['gender'] = selectedGender;
      }

      if (selectedDateOfBirth != null) {
        body['date_of_birth'] =
            _formatDate(selectedDateOfBirth!);
      }

      await ApiClient.put('me', body);

      if (!mounted) return;

      Get.snackbar(
        'Profile updated',
        'Your profile has been saved successfully.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        icon: const Icon(
          Icons.check_circle_rounded,
          color: FarmerDesign.success,
        ),
      );

      Get.back(result: true);
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Update failed',
          _cleanError(e),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  String _cleanError(dynamic error) {
    final value = error.toString();

    if (value.startsWith('Exception: ')) {
      return value.substring(11);
    }

    return value;
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
          'Edit Profile',
          style: FarmerDesign.heading2,
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: FarmerDesign.primary,
              ),
            )
          : Form(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  32,
                ),
                children: [
                  _buildIntro(),
                  const SizedBox(height: 18),
                  _buildPersonalInformation(),
                  const SizedBox(height: 16),
                  _buildContactInformation(),
                  const SizedBox(height: 16),
                  _buildAboutSection(),
                  const SizedBox(height: 22),
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: FarmerDesign.greenCardDecoration(
        radius: FarmerDesign.radiusLarge,
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.person_pin_circle_outlined,
            color: FarmerDesign.primary,
            size: 30,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep your profile up to date',
                  style: FarmerDesign.heading4,
                ),
                SizedBox(height: 5),
                Text(
                  'Customers can use this information to know more about the farmer behind their products.',
                  style: FarmerDesign.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformation() {
    return _SectionCard(
      title: 'Personal information',
      icon: Icons.person_outline_rounded,
      children: [
        _field(
          controller: nameController,
          label: 'Full name',
          hint: 'Enter your full name',
          icon: Icons.person_outline_rounded,
          textCapitalization: TextCapitalization.words,
          required: true,
        ),
        _field(
          controller: displayNameController,
          label: 'Display name',
          hint: 'Name customers will see',
          icon: Icons.badge_outlined,
          textCapitalization: TextCapitalization.words,
        ),
        _buildGenderField(),
        _buildDateField(),
      ],
    );
  }

  Widget _buildContactInformation() {
    return _SectionCard(
      title: 'Contact & location',
      icon: Icons.contact_page_outlined,
      children: [
        _field(
          controller: emailController,
          label: 'Email',
          hint: 'example@email.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        _field(
          controller: phoneController,
          label: 'Phone',
          hint: 'Phone number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        _field(
          controller: locationController,
          label: 'Location',
          hint: 'Village, district, province',
          icon: Icons.location_on_outlined,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _SectionCard(
      title: 'About you',
      icon: Icons.info_outline_rounded,
      children: [
        _field(
          controller: bioController,
          label: 'Bio',
          hint: 'Tell customers a little about yourself...',
          icon: Icons.edit_note_rounded,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        decoration: _inputDecoration(
          label: 'Gender',
          hint: 'Select gender',
          icon: Icons.wc_outlined,
        ),
        items: genders.map((gender) {
          final label =
              gender[0].toUpperCase() +
              gender.substring(1);

          return DropdownMenuItem(
            value: gender,
            child: Text(label),
          );
        }).toList(),
        onChanged: isSaving
            ? null
            : (value) {
                setState(() {
                  selectedGender = value;
                });
              },
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: isSaving ? null : selectDateOfBirth,
        borderRadius: BorderRadius.circular(
          FarmerDesign.radiusMedium,
        ),
        child: InputDecorator(
          decoration: _inputDecoration(
            label: 'Date of birth',
            hint: 'Select your date of birth',
            icon: Icons.cake_outlined,
          ),
          child: Text(
            selectedDateOfBirth == null
                ? 'Select your date of birth'
                : _formatDate(selectedDateOfBirth!),
            style: TextStyle(
              fontSize: 14,
              color: selectedDateOfBirth == null
                  ? FarmerDesign.mutedText
                  : FarmerDesign.text,
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool required = false,
    TextCapitalization textCapitalization =
        TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textCapitalization: textCapitalization,
        enabled: !isSaving,
        decoration: _inputDecoration(
          label: required ? '$label *' : label,
          hint: hint,
          icon: icon,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: FarmerDesign.secondaryText,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          FarmerDesign.radiusMedium,
        ),
        borderSide: const BorderSide(
          color: FarmerDesign.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          FarmerDesign.radiusMedium,
        ),
        borderSide: const BorderSide(
          color: FarmerDesign.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          FarmerDesign.radiusMedium,
        ),
        borderSide: const BorderSide(
          color: FarmerDesign.primary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        onPressed: isSaving ? null : saveProfile,
        style: FilledButton.styleFrom(
          backgroundColor: FarmerDesign.primary,
          disabledBackgroundColor:
              FarmerDesign.primary.withValues(alpha: 0.55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              FarmerDesign.radiusMedium,
            ),
          ),
        ),
        icon: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_outlined),
        label: Text(
          isSaving ? 'Saving...' : 'Save Changes',
          style: FarmerDesign.button,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: FarmerDesign.cardDecoration(
        radius: FarmerDesign.radiusLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: FarmerDesign.primaryLight,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: FarmerDesign.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: FarmerDesign.heading4,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}