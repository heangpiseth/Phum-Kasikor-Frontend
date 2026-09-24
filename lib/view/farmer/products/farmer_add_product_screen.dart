import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:phum_kasikors/controller/farmer/product_controller.dart';
import 'package:phum_kasikors/controller/farmer/farm_controller.dart';
import 'package:phum_kasikors/model/farmer/product_model.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';
import 'package:phum_kasikors/view/farmer/products/farmer_product_detail_screen.dart';

class FarmerAddProductScreen extends StatefulWidget {
  const FarmerAddProductScreen({
    super.key,
    this.farmId,
  });

  final String? farmId;

  @override
  State<FarmerAddProductScreen> createState() =>
      _FarmerAddProductScreenState();
}

class _FarmerAddProductScreenState
    extends State<FarmerAddProductScreen> {
  late final FarmerProductController controller;
  late final FarmController farmController;

  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;

  // ============================================================
  // FORM
  // ============================================================

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  String? _selectedCategory;

  String _selectedUnit = 'kg';

  String? _selectedFarmingMethod;

  DateTime? _harvestDate;

  bool _isSaving = false;

  // ============================================================
  // OPTIONS
  // ============================================================

  final List<_CategoryOption> _categories = const [
    _CategoryOption(
      id: '1',
      name: 'Vegetables',
      icon: Icons.eco_outlined,
    ),
    _CategoryOption(
      id: '2',
      name: 'Fruits',
      icon: Icons.apple_outlined,
    ),
    _CategoryOption(
      id: '3',
      name: 'Rice & Grains',
      icon: Icons.grass_outlined,
    ),
    _CategoryOption(
      id: '4',
      name: 'Herbs',
      icon: Icons.spa_outlined,
    ),
    _CategoryOption(
      id: '5',
      name: 'Other',
      icon: Icons.more_horiz,
    ),
  ];

  final List<String> _units = const [
    'kg',
    'g',
    'piece',
    'bundle',
    'box',
    'bag',
    'dozen',
  ];

  final List<String> _farmingMethods = const [
    'Organic',
    'Conventional',
    'Hydroponic',
    'Greenhouse',
    'Natural',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<FarmerProductController>()
        ? Get.find<FarmerProductController>()
        : Get.put(FarmerProductController());

    farmController = Get.isRegistered<FarmController>()
        ? Get.find<FarmController>()
        : Get.put(FarmController());

    debugPrint('========================================');
    debugPrint('FARMER ADD PRODUCT SCREEN');
    debugPrint('Passed farm ID: ${widget.farmId}');
    debugPrint('========================================');
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  Future<void> _showImagePicker() async {
    FocusScope.of(context).unfocus();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E5E1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Add Product Photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF263238),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Take a photo or choose one from your gallery.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF78909C),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _ImageSourceButton(
                        icon: Icons.camera_alt_outlined,
                        title: 'Camera',
                        subtitle: 'Take a photo',
                        onTap: () async {
                          Navigator.pop(context);
                          await _takePhoto();
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _ImageSourceButton(
                        icon: Icons.photo_library_outlined,
                        title: 'Gallery',
                        subtitle: 'Choose photo',
                        onTap: () async {
                          Navigator.pop(context);
                          await _pickFromGallery();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
      });

      debugPrint(
        'SELECTED CAMERA IMAGE: ${image.path}',
      );
    } catch (e) {
      debugPrint('CAMERA ERROR: $e');

      _showError(
        'Could not open the camera.',
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
      });

      debugPrint(
        'SELECTED GALLERY IMAGE: ${image.path}',
      );
    } catch (e) {
      debugPrint('GALLERY ERROR: $e');

      _showError(
        'Could not open the gallery.',
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> _pickHarvestDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: FarmerDesign.primary,
              brightness: Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _harvestDate = picked;
      });
    }
  }

  // ============================================================
  // SUBMIT PRODUCT
  // ============================================================

  Future<void> _submitProduct() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      _showError(
        'Please choose a product category.',
      );
      return;
    }

    if (_selectedFarmingMethod == null) {
      _showError(
        'Please choose a farming method.',
      );
      return;
    }

    final price = double.tryParse(
      _priceController.text.trim(),
    );

    final quantity = double.tryParse(
      _quantityController.text.trim(),
    );

    if (price == null || price <= 0) {
      _showError(
        'Please enter a valid price.',
      );
      return;
    }

    if (quantity == null || quantity <= 0) {
      _showError(
        'Please enter a valid stock quantity.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // ========================================================
      // RESOLVE FARM ID
      // ========================================================

      String? resolvedFarmId =
          widget.farmId?.trim();

      debugPrint('========================================');
      debugPrint('ADD PRODUCT');
      debugPrint(
        'Passed farm ID: $resolvedFarmId',
      );
      debugPrint('========================================');

      if (resolvedFarmId == null ||
          resolvedFarmId.isEmpty ||
          resolvedFarmId == 'null') {
        debugPrint(
          'No farm ID passed. Calling ensureFarmId()...',
        );

        resolvedFarmId =
            await farmController.ensureFarmId();
      }

      if (!mounted) return;

      if (resolvedFarmId == null ||
          resolvedFarmId.trim().isEmpty) {
        _showError(
          farmController.errorMessage.value.isNotEmpty
              ? farmController.errorMessage.value
              : 'No farm was found for your account.',
        );
        return;
      }

      resolvedFarmId =
          resolvedFarmId.trim();

      debugPrint('========================================');
      debugPrint(
        'REAL FARM ID: $resolvedFarmId',
      );
      debugPrint(
        'PRODUCT CATEGORY: $_selectedCategory',
      );
      debugPrint(
        'PRODUCT NAME: ${_nameController.text.trim()}',
      );
      debugPrint('PRICE: $price');
      debugPrint('QUANTITY: $quantity');
      debugPrint('UNIT: $_selectedUnit');
      debugPrint(
        'FARMING METHOD: $_selectedFarmingMethod',
      );
      debugPrint(
        'IMAGE: ${_selectedImage?.path ?? 'NO IMAGE'}',
      );
      debugPrint('========================================');

      // ========================================================
      // CREATE PRODUCT
      // ========================================================

      final ProductModel? product =
          await controller.createProduct(
        farmId: resolvedFarmId,
        categoryId: _selectedCategory!,
        name: _nameController.text.trim(),
        price: price,
        unit: _selectedUnit,
        quantityAvailable: quantity,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        harvestDate: _harvestDate,
        farmingMethod: _selectedFarmingMethod,
      );

      if (!mounted) return;

      // ========================================================
      // PRODUCT FAILED
      // ========================================================

      if (product == null) {
        _showError(
          controller.errorMessage.value.isEmpty
              ? 'Could not create the product.'
              : controller.errorMessage.value,
        );
        return;
      }

      debugPrint('========================================');
      debugPrint('PRODUCT CREATED');
      debugPrint('PRODUCT ID: ${product.id}');
      debugPrint('========================================');

      // ========================================================
      // UPLOAD IMAGE
      // ========================================================

      if (_selectedImage != null) {
        debugPrint('========================================');
        debugPrint('UPLOADING PRODUCT IMAGE');
        debugPrint(
          'PRODUCT ID: ${product.id}',
        );
        debugPrint(
          'IMAGE: ${_selectedImage!.path}',
        );
        debugPrint('========================================');

        final imageUploaded =
            await controller.uploadProductImage(
          farmId: resolvedFarmId,
          productId: product.id,
          imageFile: _selectedImage!,
        );

        if (!mounted) return;

        if (!imageUploaded) {
          Get.back(result: true);

          Get.snackbar(
            'Product added',
            'Product was created, but the photo could not be uploaded.',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            backgroundColor: Colors.orange.shade700,
            colorText: Colors.white,
            icon: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
            ),
          );

          return;
        }

        debugPrint(
          'PRODUCT IMAGE UPLOADED SUCCESSFULLY',
        );
      }

      // ========================================================
// SUCCESS
// ========================================================

if (!mounted) return;

Get.snackbar(
  'Product added',
  _selectedImage != null
      ? '${_nameController.text.trim()} and its photo were added.'
      : '${_nameController.text.trim()} is now in your products.',
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
  backgroundColor: FarmerDesign.primary,
  colorText: Colors.white,
  icon: const Icon(
    Icons.check_circle_outline,
    color: Colors.white,
  ),
);

// Open the newly created product.
await Get.off(
  () => FarmerProductDetailScreen(
    farmId: resolvedFarmId!,
    productId: product.id,
  ),
);
    } catch (e) {
      debugPrint(
        'CREATE PRODUCT ERROR: $e',
      );

      if (!mounted) return;

      _showError(
        'Could not save the product. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    Get.snackbar(
      'Check your product',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFFB3261E),
      colorText: Colors.white,
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerDesign.background,
      appBar: AppBar(
        backgroundColor: FarmerDesign.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: _isSaving
              ? null
              : () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
        ),
        title: const Text(
          'Add Product',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Color(0xFF263238),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics:
                const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              120,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildHeroHeader(),

                const SizedBox(height: 24),

                // ==================================================
                // PRODUCT PHOTO
                // ==================================================

                _buildProductPhoto(),

                const SizedBox(height: 28),

                const _SectionTitle(
                  icon: Icons.eco_outlined,
                  title: 'What are you selling?',
                  subtitle:
                      'Tell customers what this product is.',
                ),

                const SizedBox(height: 14),

                _buildProductNameField(),

                const SizedBox(height: 14),

                _buildCategorySelector(),

                const SizedBox(height: 28),

                const _SectionTitle(
                  icon: Icons.sell_outlined,
                  title: 'Price & availability',
                  subtitle:
                      'Set your selling price and current stock.',
                ),

                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildPriceField(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuantityField(),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _buildUnitSelector(),

                const SizedBox(height: 28),

                const _SectionTitle(
                  icon: Icons.agriculture_outlined,
                  title: 'How is it grown?',
                  subtitle:
                      'Help customers understand your farming method.',
                ),

                const SizedBox(height: 14),

                _buildFarmingMethodSelector(),

                const SizedBox(height: 28),

                const _SectionTitle(
                  icon: Icons.calendar_month_outlined,
                  title: 'Harvest information',
                  subtitle:
                      'Optional, but useful for fresh produce.',
                ),

                const SizedBox(height: 14),

                _buildHarvestDate(),

                const SizedBox(height: 28),

                const _SectionTitle(
                  icon: Icons.notes_outlined,
                  title: 'Tell customers more',
                  subtitle:
                      'Describe freshness, quality, size, or anything important.',
                ),

                const SizedBox(height: 14),

                _buildDescription(),

                const SizedBox(height: 28),

                _buildProductPreview(),

                const SizedBox(height: 28),

                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF43A047),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32)
                .withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(alpha: 0.18),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'List a new product',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Add the details customers need before buying.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.35,
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
  // PRODUCT PHOTO
  // ============================================================

  Widget _buildProductPhoto() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Product photo',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF263238),
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Show customers what your fresh product looks like.',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF78909C),
          ),
        ),

        const SizedBox(height: 14),

        GestureDetector(
          onTap: _isSaving
              ? null
              : _showImagePicker,
          child: Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(22),
              border: Border.all(
                color: _selectedImage == null
                    ? const Color(0xFFE0E5E1)
                    : FarmerDesign.primary,
                width: _selectedImage == null
                    ? 1
                    : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: 0.035),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _selectedImage == null
                ? _buildEmptyPhoto()
                : _buildSelectedPhoto(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPhoto() {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: FarmerDesign.primaryLight,
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.add_a_photo_outlined,
            size: 32,
            color: FarmerDesign.primary,
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          'Add a product photo',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF263238),
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Tap here to take a photo or choose from gallery',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF78909C),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSelectedPhoto() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius:
              BorderRadius.circular(20),
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
          ),
        ),

        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: _removeImage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black
                    .withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 21,
              ),
            ),
          ),
        ),

        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.black
                  .withValues(alpha: 0.65),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 17,
                ),
                SizedBox(width: 6),
                Text(
                  'Photo selected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PRODUCT NAME
  // ============================================================

  Widget _buildProductNameField() {
    return _FieldContainer(
      child: TextFormField(
        controller: _nameController,
        textCapitalization:
            TextCapitalization.words,
        validator: (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return 'Product name is required';
          }

          return null;
        },
        decoration: _inputDecoration(
          label: 'Product name',
          hint: 'e.g. Fresh Morning Glory',
          icon: Icons.eco_outlined,
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  Widget _buildCategorySelector() {
    return _FieldContainer(
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCategory,
        decoration: _inputDecoration(
          label: 'Category',
          hint: 'Choose a category',
          icon: Icons.category_outlined,
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
        ),
        items: _categories.map(
          (category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Row(
                children: [
                  Icon(
                    category.icon,
                    size: 19,
                    color: FarmerDesign.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(category.name),
                ],
              ),
            );
          },
        ).toList(),
        validator: (value) {
          if (value == null ||
              value.isEmpty) {
            return 'Please choose a category';
          }

          return null;
        },
        onChanged: _isSaving
            ? null
            : (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
      ),
    );
  }

  // ============================================================
  // PRICE
  // ============================================================

  Widget _buildPriceField() {
    return _FieldContainer(
      child: TextFormField(
        controller: _priceController,
        keyboardType:
            const TextInputType.numberWithOptions(
          decimal: true,
        ),
        validator: (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return 'Required';
          }

          final price =
              double.tryParse(value.trim());

          if (price == null ||
              price <= 0) {
            return 'Enter valid price';
          }

          return null;
        },
        decoration: _inputDecoration(
          label: 'Price',
          hint: '0.00',
          prefixText: '\$ ',
          icon: Icons.attach_money_rounded,
        ),
      ),
    );
  }

  // ============================================================
  // QUANTITY
  // ============================================================

  Widget _buildQuantityField() {
    return _FieldContainer(
      child: TextFormField(
        controller: _quantityController,
        keyboardType:
            const TextInputType.numberWithOptions(
          decimal: true,
        ),
        validator: (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return 'Required';
          }

          final quantity =
              double.tryParse(value.trim());

          if (quantity == null ||
              quantity <= 0) {
            return 'Enter valid stock';
          }

          return null;
        },
        decoration: _inputDecoration(
          label: 'Available stock',
          hint: '0',
          icon: Icons.inventory_2_outlined,
        ),
      ),
    );
  }

  // ============================================================
  // UNIT
  // ============================================================

  Widget _buildUnitSelector() {
    return _FieldContainer(
      child: DropdownButtonFormField<String>(
        initialValue: _selectedUnit,
        decoration: _inputDecoration(
          label: 'Sold by',
          hint: 'Choose unit',
          icon: Icons.straighten_outlined,
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
        ),
        items: _units.map(
          (unit) {
            return DropdownMenuItem<String>(
              value: unit,
              child: Text(unit),
            );
          },
        ).toList(),
        onChanged: _isSaving
            ? null
            : (value) {
                if (value == null) return;

                setState(() {
                  _selectedUnit = value;
                });
              },
      ),
    );
  }

  // ============================================================
  // FARMING METHOD
  // ============================================================

  Widget _buildFarmingMethodSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _farmingMethods.map(
        (method) {
          final selected =
              _selectedFarmingMethod == method;

          return GestureDetector(
            onTap: _isSaving
                ? null
                : () {
                    setState(() {
                      _selectedFarmingMethod =
                          method;
                    });
                  },
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? FarmerDesign.primary
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? FarmerDesign.primary
                      : const Color(0xFFE0E5E1),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: FarmerDesign
                              .primary
                              .withValues(
                            alpha: 0.16,
                          ),
                          blurRadius: 10,
                          offset:
                              const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    method == 'Organic'
                        ? Icons.eco_outlined
                        : Icons
                            .agriculture_outlined,
                    size: 17,
                    color: selected
                        ? Colors.white
                        : FarmerDesign.primary,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    method,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : const Color(0xFF455A64),
                      fontWeight:
                          FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // HARVEST DATE
  // ============================================================

  Widget _buildHarvestDate() {
    final selected =
        _harvestDate != null;

    return GestureDetector(
      onTap: _isSaving
          ? null
          : _pickHarvestDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? FarmerDesign.primary
                : const Color(0xFFE0E5E1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    FarmerDesign.primaryLight,
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                color: FarmerDesign.primary,
                size: 21,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expected harvest date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          Color(0xFF263238),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    selected
                        ? _formatDate(
                            _harvestDate!,
                          )
                        : 'Optional — tell customers when it will be ready',
                    style: TextStyle(
                      fontSize: 12,
                      color: selected
                          ? FarmerDesign.primary
                          : const Color(
                              0xFF78909C,
                            ),
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: selected ? 22 : 15,
              color: FarmerDesign.primary,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  Widget _buildDescription() {
    return _FieldContainer(
      child: TextFormField(
        controller:
            _descriptionController,
        maxLines: 5,
        textCapitalization:
            TextCapitalization.sentences,
        decoration: _inputDecoration(
          label: 'Description',
          hint:
              'Example: Freshly harvested this morning. '
              'No chemical pesticides used.',
          icon: Icons.notes_outlined,
        ),
      ),
    );
  }

  // ============================================================
  // PREVIEW
  // ============================================================

  Widget _buildProductPreview() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _nameController,
        _priceController,
        _quantityController,
      ]),
      builder: (context, child) {
        final productName =
            _nameController.text.trim();

        final price =
            _priceController.text.trim();

        final quantity =
            _quantityController.text.trim();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: FarmerDesign.primaryLight,
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: FarmerDesign.primary
                  .withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    color: FarmerDesign.primary,
                    size: 19,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Customer preview',
                    style: TextStyle(
                      color:
                          FarmerDesign.primary,
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Text(
                productName.isEmpty
                    ? 'Your product name'
                    : productName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      Color(0xFF263238),
                ),
              ),

              const SizedBox(height: 7),

              Text(
                price.isEmpty
                    ? 'Price not set'
                    : '\$$price / $_selectedUnit',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      FarmerDesign.primary,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                quantity.isEmpty
                    ? 'Stock not set'
                    : '$quantity $_selectedUnit available',
                style: const TextStyle(
                  fontSize: 12,
                  color:
                      Color(0xFF607D8B),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed:
            _isSaving ? null : _submitProduct,
        style: FilledButton.styleFrom(
          backgroundColor:
              FarmerDesign.primary,
          disabledBackgroundColor:
              FarmerDesign.primary
                  .withValues(alpha: 0.5),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 23,
                height: 23,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 21,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Add Product',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefixText,
      prefixIcon: Icon(
        icon,
        color: FarmerDesign.primary,
        size: 21,
      ),
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(
        color: Color(0xFF607D8B),
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFFB0BEC5),
        fontSize: 13,
      ),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Color(0xFFE0E5E1),
        ),
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Color(0xFFE0E5E1),
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: FarmerDesign.primary,
          width: 1.7,
        ),
      ),
      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Color(0xFFE57373),
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Color(0xFFE57373),
          width: 1.5,
        ),
      ),
    );
  }
}

// ================================================================
// FIELD CONTAINER
// ================================================================

class _FieldContainer
    extends StatelessWidget {
  const _FieldContainer({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ================================================================
// SECTION TITLE
// ================================================================

class _SectionTitle
    extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color:
                FarmerDesign.primaryLight,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color:
                FarmerDesign.primary,
            size: 20,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color:
                      Color(0xFF78909C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ================================================================
// CATEGORY MODEL
// ================================================================

class _CategoryOption {
  const _CategoryOption({
    required this.id,
    required this.name,
    required this.icon,
  });

  final String id;
  final String name;
  final IconData icon;
}

// ================================================================
// IMAGE SOURCE BUTTON
// ================================================================

class _ImageSourceButton
    extends StatelessWidget {
  const _ImageSourceButton({
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
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(18),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color:
              FarmerDesign.primaryLight,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: FarmerDesign.primary
                .withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color:
                  FarmerDesign.primary,
            ),

            const SizedBox(height: 9),

            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(0xFF263238),
              ),
            ),

            const SizedBox(height: 3),

            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color:
                    Color(0xFF78909C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}