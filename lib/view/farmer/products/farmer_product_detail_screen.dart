import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phum_kasikors/controller/farmer/product_controller.dart';

import 'package:phum_kasikors/model/farmer/product_model.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';
import 'package:phum_kasikors/view/farmer/products/farmer_edit_product_screen.dart';

class FarmerProductDetailScreen extends StatefulWidget {
  const FarmerProductDetailScreen({
    super.key,
    required this.farmId,
    required this.productId,
  });

  final String farmId;
  final String productId;

  @override
  State<FarmerProductDetailScreen> createState() =>
      _FarmerProductDetailScreenState();
}

class _FarmerProductDetailScreenState
    extends State<FarmerProductDetailScreen> {
  late final FarmerProductController controller;

  final ImagePicker _imagePicker = ImagePicker();

  ProductModel? product;

  bool isLoadingProduct = true;
  bool isDeletingProduct = false;

  String? busyImageId;

  @override
  void initState() {
    super.initState();

    controller =
        Get.isRegistered<FarmerProductController>()
            ? Get.find<FarmerProductController>()
            : Get.put(FarmerProductController());

    _loadProduct();
  }

  // ============================================================
  // LOAD PRODUCT
  // ============================================================

  Future<void> _loadProduct() async {
    if (mounted) {
      setState(() {
        isLoadingProduct = true;
      });
    }

    try {
      ProductModel? loaded =
          controller.getProductById(
        widget.productId,
      );

      if (loaded == null) {
        loaded = await controller.fetchProduct(
          farmId: widget.farmId,
          productId: widget.productId,
        );
      }

      if (mounted) {
        setState(() {
          product = loaded;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingProduct = false;
        });
      }
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    final loaded =
        await controller.fetchProduct(
      farmId: widget.farmId,
      productId: widget.productId,
    );

    if (!mounted) return;

    if (loaded != null) {
      setState(() {
        product = loaded;
      });
    }
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    if (controller.isUploadingImage.value) {
      return;
    }

    try {
      final XFile? picked =
          await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (picked == null) {
        return;
      }

      final success =
          await controller.uploadProductImage(
        farmId: widget.farmId,
        productId: widget.productId,
        imageFile: File(picked.path),
      );

      if (!mounted) return;

      if (success) {
        await _loadProduct();

        _showSuccess(
          'Product image uploaded successfully.',
        );
      } else {
        _showError(
          controller.errorMessage.value,
        );
      }
    } catch (e) {
      _showError(
        'Unable to select image.',
      );
    }
  }

  // ============================================================
  // SET PRIMARY
  // ============================================================

  Future<void> _setPrimary(
    String imageId,
  ) async {
    if (imageId.isEmpty) {
      return;
    }

    setState(() {
      busyImageId = imageId;
    });

    final success =
        await controller.setPrimaryImage(
      farmId: widget.farmId,
      productId: widget.productId,
      imageId: imageId,
    );

    if (!mounted) return;

    setState(() {
      busyImageId = null;
    });

    if (success) {
      await _loadProduct();

      _showSuccess(
        'Primary image updated.',
      );
    } else {
      _showError(
        controller.errorMessage.value,
      );
    }
  }

  // ============================================================
  // DELETE IMAGE
  // ============================================================

  Future<void> _deleteImage(
    String imageId,
  ) async {
    if (imageId.isEmpty) {
      return;
    }

    final confirmed =
        await _confirmDeleteImage();

    if (confirmed != true) {
      return;
    }

    setState(() {
      busyImageId = imageId;
    });

    final success =
        await controller.deleteProductImage(
      farmId: widget.farmId,
      productId: widget.productId,
      imageId: imageId,
    );

    if (!mounted) return;

    setState(() {
      busyImageId = null;
    });

    if (success) {
      await _loadProduct();

      _showSuccess(
        'Image deleted.',
      );
    } else {
      _showError(
        controller.errorMessage.value,
      );
    }
  }

  // ============================================================
  // DELETE IMAGE CONFIRMATION
  // ============================================================

  Future<bool?> _confirmDeleteImage() {
    return Get.dialog<bool>(
      AlertDialog(
        backgroundColor: FarmerDesign.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            FarmerDesign.radiusLarge,
          ),
        ),
        title: Text(
          'Delete image?',
          style: FarmerDesign.heading3,
        ),
        content: Text(
          'This image will be permanently removed '
          'from this product.',
          style: FarmerDesign.body,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: FarmerDesign.secondaryText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(result: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FarmerDesign.error,
              foregroundColor: FarmerDesign.white,
              elevation: 0,
              shape: FarmerDesign.buttonShape(),
            ),
            child: const Text(
              'Delete',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EDIT PRODUCT
  // ============================================================

  Future<void> _editProduct() async {
    final current = product;

    if (current == null) {
      return;
    }

    await Get.to(
      () => FarmerEditProductScreen(
        farmId: widget.farmId,
        productId: current.id,
      ),
    );

    await _loadProduct();
  }

  // ============================================================
  // DELETE PRODUCT
  // ============================================================

  Future<void> _deleteProduct() async {
    final current = product;

    if (current == null) {
      return;
    }

    final confirmed =
        await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: FarmerDesign.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            FarmerDesign.radiusLarge,
          ),
        ),
        title: Text(
          'Delete product?',
          style: FarmerDesign.heading3,
        ),
        content: Text(
          'Are you sure you want to delete '
          '"${current.name}"?',
          style: FarmerDesign.body,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: FarmerDesign.secondaryText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(result: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FarmerDesign.error,
              foregroundColor: FarmerDesign.white,
              elevation: 0,
              shape: FarmerDesign.buttonShape(),
            ),
            child: const Text(
              'Delete',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      isDeletingProduct = true;
    });

    final success =
        await controller.deleteProduct(
      farmId: widget.farmId,
      productId: current.id,
    );

    if (!mounted) return;

    setState(() {
      isDeletingProduct = false;
    });

    if (success) {
      _showSuccess(
        'Product deleted successfully.',
      );

      Get.back();
    } else {
      _showError(
        controller.errorMessage.value,
      );
    }
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
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FarmerDesign.primaryDark,
          ),
        ),
        title: Text(
          'Product Details',
          style: FarmerDesign.heading3.copyWith(
            color: FarmerDesign.primaryDark,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                product == null ? null : _editProduct,
            icon: Icon(
              Icons.edit_outlined,
              color: FarmerDesign.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoadingProduct
          ? Center(
              child: CircularProgressIndicator(
                color: FarmerDesign.primary,
              ),
            )
          : product == null
              ? _buildNotFound()
              : RefreshIndicator(
                  color: FarmerDesign.primary,
                  onRefresh: _refresh,
                  child: _buildBody(),
                ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    return SingleChildScrollView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: FarmerDesign.pagePadding,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildImages(),
          const SizedBox(
            height: FarmerDesign.xl,
          ),
          _buildHeader(),
          const SizedBox(
            height: FarmerDesign.lg,
          ),
          _buildStats(),
          const SizedBox(
            height: FarmerDesign.lg,
          ),
          _buildInformation(),
          const SizedBox(
            height: FarmerDesign.lg,
          ),
          _buildDescription(),
          const SizedBox(
            height: FarmerDesign.xxl,
          ),
          _buildActions(),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGES
  // ============================================================

  Widget _buildImages() {
    final images = product!.images;

    if (images.isEmpty) {
      return _buildEmptyImages();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          Icons.photo_library_outlined,
          'Product Photos',
          '${images.length} ${images.length == 1 ? 'photo' : 'photos'}',
        ),
        const SizedBox(
          height: FarmerDesign.md,
        ),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length + 1,
            separatorBuilder: (_, __) =>
                const SizedBox(
              width: FarmerDesign.md,
            ),
            itemBuilder: (_, index) {
              if (index == images.length) {
                return _buildAddImage();
              }

              return _buildImageCard(
                images[index],
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY IMAGES
  // ============================================================

  Widget _buildEmptyImages() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          Icons.photo_library_outlined,
          'Product Photos',
          'Add photos to show your customers',
        ),
        const SizedBox(
          height: FarmerDesign.md,
        ),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 220,
            width: double.infinity,
            decoration:
                FarmerDesign.greenCardDecoration(),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: FarmerDesign.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_a_photo_outlined,
                    size: 32,
                    color: FarmerDesign.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Add Product Photo',
                  style:
                      FarmerDesign.heading4.copyWith(
                    color:
                        FarmerDesign.primaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Upload a clear photo of your product.',
                  style:
                      FarmerDesign.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ADD IMAGE CARD
  // ============================================================

  Widget _buildAddImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 170,
        decoration:
            FarmerDesign.greenCardDecoration(),
        child: Obx(
          () {
            final uploading =
                controller.isUploadingImage.value;

            return Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: FarmerDesign.white,
                    shape: BoxShape.circle,
                  ),
                  child: uploading
                      ? Padding(
                          padding:
                              const EdgeInsets.all(16),
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color:
                                FarmerDesign.primary,
                          ),
                        )
                      : Icon(
                          Icons.add_rounded,
                          size: 32,
                          color:
                              FarmerDesign.primary,
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  uploading
                      ? 'Uploading...'
                      : 'Add Photo',
                  style:
                      FarmerDesign.bodyMedium.copyWith(
                    color:
                        FarmerDesign.primaryDark,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE CARD
  // ============================================================

  Widget _buildImageCard(
    dynamic image,
  ) {
    final imageId = _imageId(image);
    final imageUrl = _imageUrl(image);
    final primary = _isPrimary(image);
    final busy = busyImageId == imageId;

    return SizedBox(
      width: 280,
      child: Stack(
        children: [
          GestureDetector(
            onTap: imageUrl.isEmpty
                ? null
                : () => _showFullImage(imageUrl),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                FarmerDesign.radiusLarge,
              ),
              child: Container(
                width: 280,
                height: 250,
                color: FarmerDesign.primaryLight,
                child: imageUrl.isEmpty
                    ? Icon(
                        Icons.image_not_supported_outlined,
                        size: 42,
                        color:
                            FarmerDesign.primary,
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) {
                          return Icon(
                            Icons.broken_image_outlined,
                            size: 42,
                            color:
                                FarmerDesign.primary,
                          );
                        },
                        loadingBuilder:
                            (
                          context,
                          child,
                          progress,
                        ) {
                          if (progress == null) {
                            return child;
                          }

                          return Center(
                            child:
                                CircularProgressIndicator(
                              color:
                                  FarmerDesign.primary,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),

          if (primary)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color:
                      FarmerDesign.primaryDark,
                  borderRadius:
                      BorderRadius.circular(
                    FarmerDesign.radiusRound,
                  ),
                ),
                child: const Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Primary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            top: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color:
                    FarmerDesign.white.withValues(
                  alpha: 0.95,
                ),
                borderRadius:
                    BorderRadius.circular(
                  FarmerDesign.radiusMedium,
                ),
              ),
              child: busy
                  ? Padding(
                      padding:
                          const EdgeInsets.all(12),
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                            FarmerDesign.primary,
                      ),
                    )
                  : PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color:
                            FarmerDesign.primaryDark,
                      ),
                      onSelected: (value) {
                        if (value == 'primary') {
                          _setPrimary(imageId);
                        }

                        if (value == 'delete') {
                          _deleteImage(imageId);
                        }
                      },
                      itemBuilder: (_) => [
                        if (!primary)
                          const PopupMenuItem(
                            value: 'primary',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star_outline_rounded,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Make Primary',
                                ),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Delete',
                              ),
                            ],
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
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    final current = product!;

    return Container(
      padding: FarmerDesign.cardPadding,
      decoration:
          FarmerDesign.cardDecoration(),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        current.name,
                        style:
                            FarmerDesign.heading1.copyWith(
                          color:
                              FarmerDesign.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusBadge(
                      current.isActive,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Product #${current.id}',
                  style:
                      FarmerDesign.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _statusBadge(
    bool active,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: active
            ? FarmerDesign.successLight
            : FarmerDesign.errorLight,
        borderRadius:
            BorderRadius.circular(
          FarmerDesign.radiusRound,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: active
                  ? FarmerDesign.success
                  : FarmerDesign.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            active ? 'Active' : 'Inactive',
            style:
                FarmerDesign.caption.copyWith(
              color: active
                  ? FarmerDesign.success
                  : FarmerDesign.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats() {
    final current = product!;

    return Row(
      children: [
        Expanded(
          child: _statCard(
            Icons.payments_outlined,
            'Price',
            '\$${current.price.toStringAsFixed(2)}',
            'per ${current.unit}',
          ),
        ),
        const SizedBox(
          width: FarmerDesign.md,
        ),
        Expanded(
          child: _statCard(
            Icons.inventory_2_outlined,
            'Stock',
            _formatNumber(
              current.quantityAvailable,
            ),
            current.unit,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    IconData icon,
    String title,
    String value,
    String subtitle,
  ) {
    return Container(
      padding: FarmerDesign.cardPadding,
      decoration:
          FarmerDesign.cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: FarmerDesign.primaryLight,
              borderRadius:
                  BorderRadius.circular(
                FarmerDesign.radiusMedium,
              ),
            ),
            child: Icon(
              icon,
              color: FarmerDesign.primary,
              size: 21,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: FarmerDesign.caption,
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style:
                FarmerDesign.heading2.copyWith(
              color: FarmerDesign.primaryDark,
            ),
          ),
          Text(
            subtitle,
            style: FarmerDesign.bodySmall,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION
  // ============================================================

  Widget _buildInformation() {
    final current = product!;

    return Container(
      padding: FarmerDesign.cardPadding,
      decoration:
          FarmerDesign.cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.info_outline_rounded,
            'Product Information',
            null,
          ),
          const SizedBox(height: 16),
          _infoRow(
            Icons.eco_outlined,
            'Farming method',
            _displayValue(
              current.farmingMethod,
            ),
          ),
          const Divider(
            height: 24,
            color: FarmerDesign.divider,
          ),
          _infoRow(
            Icons.calendar_today_outlined,
            'Harvest date',
            _formatDate(
              current.harvestDate,
            ),
          ),
          const Divider(
            height: 24,
            color: FarmerDesign.divider,
          ),
          _infoRow(
            Icons.scale_outlined,
            'Unit',
            _displayValue(
              current.unit,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: FarmerDesign.primaryLight,
            borderRadius:
                BorderRadius.circular(
              FarmerDesign.radiusMedium,
            ),
          ),
          child: Icon(
            icon,
            color: FarmerDesign.primary,
            size: 20,
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
                    FarmerDesign.caption,
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style:
                    FarmerDesign.bodyMedium.copyWith(
                  color:
                      FarmerDesign.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  Widget _buildDescription() {
    final description =
        product!.description?.trim();

    return Container(
      width: double.infinity,
      padding: FarmerDesign.cardPadding,
      decoration:
          FarmerDesign.cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.notes_rounded,
            'Description',
            null,
          ),
          const SizedBox(height: 12),
          Text(
            description == null ||
                    description.isEmpty
                ? 'No description added yet.'
                : description,
            style: FarmerDesign.body.copyWith(
              color: description == null ||
                      description.isEmpty
                  ? FarmerDesign.mutedText
                  : FarmerDesign.text,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _editProduct,
            icon: const Icon(
              Icons.edit_outlined,
            ),
            label: const Text(
              'Edit Product',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  FarmerDesign.primary,
              foregroundColor:
                  FarmerDesign.white,
              elevation: 0,
              shape:
                  FarmerDesign.buttonShape(),
              textStyle:
                  FarmerDesign.button,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: isDeletingProduct
                ? null
                : _deleteProduct,
            icon: isDeletingProduct
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                          FarmerDesign.error,
                    ),
                  )
                : const Icon(
                    Icons.delete_outline_rounded,
                  ),
            label: Text(
              isDeletingProduct
                  ? 'Deleting...'
                  : 'Delete Product',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  FarmerDesign.error,
              side: BorderSide(
                color:
                    FarmerDesign.error,
              ),
              shape:
                  FarmerDesign.buttonShape(),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    IconData icon,
    String title,
    String? subtitle,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: FarmerDesign.primaryLight,
            borderRadius:
                BorderRadius.circular(
              FarmerDesign.radiusMedium,
            ),
          ),
          child: Icon(
            icon,
            color: FarmerDesign.primary,
            size: 20,
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
                    FarmerDesign.heading4.copyWith(
                  color:
                      FarmerDesign.primaryDark,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style:
                      FarmerDesign.caption,
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // IMAGE HELPERS
  // ============================================================

  String _imageId(
    dynamic image,
  ) {
    try {
      return image.id?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  String _imageUrl(
    dynamic image,
  ) {
    try {
      return image.image?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  bool _isPrimary(
    dynamic image,
  ) {
    try {
      return image.isPrimary == true;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // FULL SCREEN IMAGE
  // ============================================================

  void _showFullImage(
    String url,
  ) {
    Get.dialog(
      GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: InteractiveViewer(
            child: Image.network(
              url,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      barrierColor: Colors.black,
    );
  }

  // ============================================================
  // NOT FOUND
  // ============================================================

  Widget _buildNotFound() {
    return Center(
      child: Padding(
        padding: FarmerDesign.pagePadding,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: FarmerDesign.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 38,
                color: FarmerDesign.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Product not found',
              style:
                  FarmerDesign.heading2.copyWith(
                color:
                    FarmerDesign.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value.isEmpty
                  ? 'We could not load this product.'
                  : controller.errorMessage.value,
              textAlign: TextAlign.center,
              style:
                  FarmerDesign.bodySmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadProduct,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Try Again',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    FarmerDesign.primary,
                foregroundColor:
                    FarmerDesign.white,
                elevation: 0,
                shape:
                    FarmerDesign.buttonShape(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FORMATTERS
  // ============================================================

  String _displayValue(
    dynamic value,
  ) {
    if (value == null) {
      return 'Not specified';
    }

    final text = value.toString().trim();

    return text.isEmpty
        ? 'Not specified'
        : text;
  }

  String _formatDate(
    dynamic value,
  ) {
    if (value == null) {
      return 'Not specified';
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return 'Not specified';
    }

    try {
      final date = DateTime.parse(text);

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return text;
    }
  }

  String _formatNumber(
    dynamic value,
  ) {
    if (value == null) {
      return '0';
    }

    final number =
        double.tryParse(value.toString());

    if (number == null) {
      return value.toString();
    }

    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }

    return number
        .toStringAsFixed(2)
        .replaceFirst(
          RegExp(r'\.?0+$'),
          '',
        );
  }

  // ============================================================
  // SNACKBARS
  // ============================================================

  void _showSuccess(
    String message,
  ) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          FarmerDesign.success,
      colorText: FarmerDesign.white,
      margin: const EdgeInsets.all(16),
      borderRadius:
          FarmerDesign.radiusMedium,
    );
  }

  void _showError(
    String message,
  ) {
    Get.snackbar(
      'Error',
      message.isEmpty
          ? 'Something went wrong.'
          : message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          FarmerDesign.error,
      colorText: FarmerDesign.white,
      margin: const EdgeInsets.all(16),
      borderRadius:
          FarmerDesign.radiusMedium,
    );
  }
}