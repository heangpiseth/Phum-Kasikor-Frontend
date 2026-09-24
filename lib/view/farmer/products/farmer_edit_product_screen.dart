// lib/view/farmer/products/farmer_edit_product_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/controller/farmer/product_controller.dart';
import 'package:phum_kasikors/model/farmer/product_model.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';

class FarmerEditProductScreen extends StatefulWidget {
  const FarmerEditProductScreen({
    super.key,
    required this.farmId,
    required this.productId,
  });

  final String farmId;
  final String productId;

  @override
  State<FarmerEditProductScreen> createState() =>
      _FarmerEditProductScreenState();
}

class _FarmerEditProductScreenState
    extends State<FarmerEditProductScreen> {
  late final FarmerProductController controller;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final unitController = TextEditingController();
  final quantityController = TextEditingController();
  final descriptionController = TextEditingController();
  final farmingMethodController = TextEditingController();

  ProductModel? product;

  DateTime? harvestDate;

  bool isActive = true;
  bool isLoadingProduct = true;

  @override
  void initState() {
    super.initState();

    controller =
        Get.isRegistered<FarmerProductController>()
            ? Get.find<FarmerProductController>()
            : Get.put(FarmerProductController());

    _loadProduct();
  }

  Future<void> _loadProduct() async {
    ProductModel? loadedProduct =
        controller.getProductById(widget.productId);

    if (loadedProduct == null) {
      loadedProduct = await controller.fetchProduct(
        farmId: widget.farmId,
        productId: widget.productId,
      );
    }

    if (!mounted) {
      return;
    }

    if (loadedProduct != null) {
      product = loadedProduct;

      nameController.text = loadedProduct.name;
      priceController.text =
          loadedProduct.price.toStringAsFixed(2);
      unitController.text = loadedProduct.unit;
      quantityController.text =
          _formatQuantity(
        loadedProduct.quantityAvailable,
      );

      descriptionController.text =
          loadedProduct.description ?? '';

      farmingMethodController.text =
          loadedProduct.farmingMethod ?? '';

      harvestDate = loadedProduct.harvestDate;
      isActive = loadedProduct.isActive;
    }

    setState(() {
      isLoadingProduct = false;
    });
  }

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    unitController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    farmingMethodController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final price = double.tryParse(
      priceController.text.trim(),
    );

    final quantity = double.tryParse(
      quantityController.text.trim(),
    );

    if (price == null || quantity == null) {
      return;
    }

    final success = await controller.updateProduct(
      farmId: widget.farmId,
      productId: widget.productId,
      data: {
        'name': nameController.text.trim(),
        'price': price,
        'unit': unitController.text.trim(),
        'quantity_available': quantity,
        'description':
            descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
        'farming_method':
            farmingMethodController.text.trim().isEmpty
                ? null
                : farmingMethodController.text.trim(),
        'harvest_date': harvestDate == null
            ? null
            : _formatDate(harvestDate!),
        'is_active': isActive,
      },
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Get.back(result: true);

      Get.snackbar(
        'Product updated',
        'Your changes were saved successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: FarmerDesign.primary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        icon: const Icon(
          Icons.check_circle_outline,
          color: Colors.white,
        ),
      );
    } else {
      Get.snackbar(
        'Update failed',
        controller.errorMessage.value.isEmpty
            ? 'Something went wrong. Please try again.'
            : controller.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: FarmerDesign.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
    }
  }

  Future<void> _delete() async {
    if (controller.isSaving.value) {
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: FarmerDesign.error.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: FarmerDesign.error,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Delete product?',
                style: FarmerDesign.heading3,
              ),
            ),
          ],
        ),
        content: const Text(
          'This product will be removed from your farm. '
          'Customers will no longer be able to purchase it.',
          style: FarmerDesign.body,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20,
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Get.back(result: true),
            style: FilledButton.styleFrom(
              backgroundColor: FarmerDesign.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final success =
        await controller.deleteProduct(
      farmId: widget.farmId,
      productId: widget.productId,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Get.back(result: true);

      Get.snackbar(
        'Product deleted',
        'The product was removed successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: FarmerDesign.primary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
    } else {
      Get.snackbar(
        'Delete failed',
        controller.errorMessage.value.isEmpty
            ? 'Something went wrong. Please try again.'
            : controller.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: FarmerDesign.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
    }
  }

  Future<void> _pickHarvestDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: harvestDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(
              primary: FarmerDesign.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      harvestDate = selected;
    });
  }

  void _clearHarvestDate() {
    setState(() {
      harvestDate = null;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _displayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingProduct) {
      return Scaffold(
        backgroundColor: FarmerDesign.background,
        appBar: _buildAppBar(),
        body: const Center(
          child: CircularProgressIndicator(
            color: FarmerDesign.primary,
          ),
        ),
      );
    }

    if (product == null) {
      return Scaffold(
        backgroundColor: FarmerDesign.background,
        appBar: _buildAppBar(),
        body: _buildProductNotFound(),
      );
    }

    return Scaffold(
      backgroundColor: FarmerDesign.background,
      appBar: _buildAppBar(),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            40,
          ),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildBasicInformationCard(),
            const SizedBox(height: 16),
            _buildStockInformationCard(),
            const SizedBox(height: 16),
            _buildFarmingInformationCard(),
            const SizedBox(height: 16),
            _buildDescriptionCard(),
            const SizedBox(height: 16),
            _buildStatusCard(),
            const SizedBox(height: 24),
            Obx(
              () => SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      controller.isSaving.value
                          ? null
                          : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        FarmerDesign.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        FarmerDesign.primary.withValues(
                      alpha: 0.5,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child:
                      controller.isSaving.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
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
                                  Icons.check_rounded,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Save Changes',
                                  style:
                                      FarmerDesign.button,
                                ),
                              ],
                            ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => OutlinedButton.icon(
                onPressed:
                    controller.isSaving.value
                        ? null
                        : _delete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: FarmerDesign.error,
                ),
                label: const Text(
                  'Delete Product',
                  style: TextStyle(
                    color: FarmerDesign.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize:
                      const Size.fromHeight(52),
                  side: BorderSide(
                    color:
                        FarmerDesign.error.withValues(
                      alpha: 0.35,
                    ),
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: FarmerDesign.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(
          Icons.arrow_back_rounded,
        ),
      ),
      title: const Text(
        'Edit Product',
        style: FarmerDesign.heading2,
      ),
      actions: [
        if (product != null)
          IconButton(
            onPressed: _delete,
            tooltip: 'Delete product',
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: FarmerDesign.error,
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            FarmerDesign.primary,
            FarmerDesign.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color:
                  Colors.white.withValues(
                alpha: 0.16,
              ),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update your product',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep your price, stock and product details up to date.',
                  style: TextStyle(
                    color:
                        Colors.white.withValues(
                      alpha: 0.82,
                    ),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInformationCard() {
    return _SectionCard(
      icon: Icons.inventory_2_outlined,
      title: 'Basic Information',
      subtitle:
          'The main information customers see.',
      children: [
        _Field(
          controller: nameController,
          label: 'Product name',
          hint: 'e.g. Fresh Morning Glory',
          prefixIcon:
              Icons.shopping_basket_outlined,
          validator: _required,
        ),
        const SizedBox(height: 14),
        _Field(
          controller: priceController,
          label: 'Price',
          hint: 'e.g. 2.50',
          prefixIcon:
              Icons.attach_money_rounded,
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
          ),
          validator: _priceValidator,
        ),
        const SizedBox(height: 14),
        _Field(
          controller: unitController,
          label: 'Unit',
          hint: 'e.g. kg, bunch, basket',
          prefixIcon:
              Icons.straighten_outlined,
          validator: _required,
        ),
      ],
    );
  }

  Widget _buildStockInformationCard() {
    return _SectionCard(
      icon: Icons.warehouse_outlined,
      title: 'Stock',
      subtitle:
          'Tell customers how much is available.',
      children: [
        _Field(
          controller: quantityController,
          label: 'Available quantity',
          hint: 'e.g. 50',
          prefixIcon:
              Icons.inventory_outlined,
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
          ),
          validator: _quantityValidator,
        ),
      ],
    );
  }

  Widget _buildFarmingInformationCard() {
    return _SectionCard(
      icon: Icons.eco_outlined,
      title: 'Farming Information',
      subtitle:
          'Optional information about how it was grown.',
      children: [
        _Field(
          controller: farmingMethodController,
          label: 'Farming method',
          hint:
              'e.g. Organic, Natural, Hydroponic',
          prefixIcon: Icons.grass_outlined,
        ),
        const SizedBox(height: 16),
        const Text(
          'Harvest date',
          style: FarmerDesign.bodyMedium,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickHarvestDate,
          borderRadius:
              BorderRadius.circular(14),
          child: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: FarmerDesign.background,
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color:
                    Colors.black.withValues(
                  alpha: 0.10,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color:
                        FarmerDesign.primaryLight,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_month_outlined,
                    color:
                        FarmerDesign.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    harvestDate == null
                        ? 'Select harvest date'
                        : _displayDate(
                            harvestDate!,
                          ),
                    style: TextStyle(
                      color: harvestDate == null
                          ? Colors.grey.shade600
                          : Colors.black87,
                      fontSize: 15,
                      fontWeight:
                          harvestDate == null
                              ? FontWeight.w400
                              : FontWeight.w600,
                    ),
                  ),
                ),
                if (harvestDate != null)
                  IconButton(
                    onPressed:
                        _clearHarvestDate,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                    ),
                    color:
                        Colors.grey.shade600,
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return _SectionCard(
      icon: Icons.description_outlined,
      title: 'Description',
      subtitle:
          'Help customers understand your product.',
      children: [
        _Field(
          controller: descriptionController,
          label: 'Product description',
          hint:
              'Describe freshness, quality, size, taste, or anything customers should know.',
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? FarmerDesign.primaryLight
                  : Colors.grey.shade100,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              isActive
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: isActive
                  ? FarmerDesign.primary
                  : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Product visibility',
                  style:
                      FarmerDesign.bodyMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  isActive
                      ? 'Customers can see and purchase this product.'
                      : 'Customers cannot see this product.',
                  style: FarmerDesign.caption,
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            activeThumbColor:
                FarmerDesign.primary,
            onChanged: (value) {
              setState(() {
                isActive = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductNotFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    FarmerDesign.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: FarmerDesign.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Product not found',
              style: FarmerDesign.heading3,
            ),
            const SizedBox(height: 8),
            const Text(
              'This product may have been deleted or is no longer available.',
              textAlign: TextAlign.center,
              style: FarmerDesign.body,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProduct,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    FarmerDesign.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  String? _priceValidator(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Price is required';
    }

    final number =
        double.tryParse(value.trim());

    if (number == null) {
      return 'Enter a valid price';
    }

    if (number <= 0) {
      return 'Price must be greater than 0';
    }

    return null;
  }

  String? _quantityValidator(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Quantity is required';
    }

    final number =
        double.tryParse(value.trim());

    if (number == null) {
      return 'Enter a valid quantity';
    }

    if (number < 0) {
      return 'Quantity cannot be negative';
    }

    return null;
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      FarmerDesign.primaryLight,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: FarmerDesign.primary,
                  size: 21,
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
                      style:
                          FarmerDesign.heading3,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style:
                          FarmerDesign.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textInputAction: maxLines > 1
          ? TextInputAction.newline
          : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon == null
            ? null
            : Icon(
                prefixIcon,
                color: FarmerDesign.primary,
              ),
        filled: true,
        fillColor: FarmerDesign.background,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide(
            color:
                Colors.black.withValues(
              alpha: 0.08,
            ),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: FarmerDesign.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: FarmerDesign.error,
          ),
        ),
        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: FarmerDesign.error,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}