import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/controller/farmer/farm_controller.dart';
import 'package:phum_kasikors/controller/farmer/product_controller.dart';
import 'package:phum_kasikors/model/farmer/product_model.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';
import 'package:phum_kasikors/view/farmer/products/farmer_add_product_screen.dart';
import 'package:phum_kasikors/view/farmer/products/farmer_product_detail_screen.dart';

class FarmerProductsScreen extends StatefulWidget {
  const FarmerProductsScreen({super.key, this.farmId});

  final String? farmId;

  @override
  State<FarmerProductsScreen> createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends State<FarmerProductsScreen> {
  late final FarmerProductController productController;
  late final FarmController farmController;

  String farmId = '';
  bool _initializing = true;

  @override
  void initState() {
    super.initState();

    productController = Get.isRegistered<FarmerProductController>()
        ? Get.find<FarmerProductController>()
        : Get.put(FarmerProductController());

    farmController = Get.isRegistered<FarmController>()
        ? Get.find<FarmController>()
        : Get.put(FarmController());

    _initialize();
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> _initialize() async {
    try {
      String? resolvedFarmId;

      // ----------------------------------------------------------
      // 1. Widget farm ID
      // ----------------------------------------------------------

      if (widget.farmId != null && widget.farmId!.trim().isNotEmpty) {
        resolvedFarmId = widget.farmId!.trim();
      }

      // ----------------------------------------------------------
      // 2. Get.arguments
      // ----------------------------------------------------------

      if (resolvedFarmId == null) {
        final arguments = Get.arguments;

        if (arguments is String && arguments.trim().isNotEmpty) {
          resolvedFarmId = arguments.trim();
        }

        if (arguments is Map) {
          final value = arguments['farmId']?.toString().trim();

          if (value != null && value.isNotEmpty) {
            resolvedFarmId = value;
          }
        }
      }

      // ----------------------------------------------------------
      // 3. Ask FarmController if necessary
      // ----------------------------------------------------------

      if (resolvedFarmId == null) {
        debugPrint('PRODUCTS: No farm ID supplied. Resolving farm...');

        resolvedFarmId = await farmController.ensureFarmId();
      }

      // ----------------------------------------------------------
      // 4. Make sure farm exists
      // ----------------------------------------------------------

      if (resolvedFarmId == null || resolvedFarmId.trim().isEmpty) {
        debugPrint('PRODUCTS: Could not resolve farm ID.');

        if (mounted) {
          setState(() {
            farmId = '';
          });
        }

        return;
      }

      farmId = resolvedFarmId.trim();

      debugPrint('PRODUCTS: Loading products for farm $farmId');

      // ----------------------------------------------------------
      // 5. Load products
      // ----------------------------------------------------------

      await productController.loadProducts(farmId);
    } catch (e) {
      debugPrint('PRODUCTS INITIALIZATION ERROR: $e');
    } finally {
      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    try {
      String? resolvedFarmId = farmId;

      if (resolvedFarmId.isEmpty) {
        resolvedFarmId = await farmController.ensureFarmId();
      }

      if (resolvedFarmId == null || resolvedFarmId.trim().isEmpty) {
        return;
      }

      farmId = resolvedFarmId.trim();

      await productController.refreshProducts(farmId);
    } catch (e) {
      debugPrint('PRODUCTS REFRESH ERROR: $e');
    }
  }

  // ============================================================
  // ADD PRODUCT
  // ============================================================

  Future<void> _openAddProduct() async {
    String? resolvedFarmId = farmId;

    if (resolvedFarmId.isEmpty) {
      resolvedFarmId = await farmController.ensureFarmId();
    }

    if (resolvedFarmId == null || resolvedFarmId.trim().isEmpty) {
      Get.snackbar(
        'Farm not found',
        farmController.errorMessage.value.isNotEmpty
            ? farmController.errorMessage.value
            : 'Please complete your farm setup first.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: FarmerDesign.error,
        colorText: Colors.white,
      );

      return;
    }

    farmId = resolvedFarmId.trim();

    debugPrint('PRODUCTS: Opening Add Product with farm $farmId');

    final result = await Get.to(() => FarmerAddProductScreen(farmId: farmId));

    if (result == true) {
      await productController.refreshProducts(farmId);
    }
  }

  // ============================================================
  // OPEN PRODUCT DETAIL
  // ============================================================

  void _openProduct(ProductModel product) {
    if (farmId.isEmpty) {
      return;
    }

    Get.to(
      () => FarmerProductDetailScreen(farmId: farmId, productId: product.id),
    );
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

        title: const Text('My Products', style: FarmerDesign.heading2),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _initializing ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
            color: FarmerDesign.primary,
          ),
        ],
      ),

      floatingActionButton: _initializing || farmId.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _openAddProduct,
              backgroundColor: FarmerDesign.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Product'),
            ),

      body: Obx(() {
        // ========================================================
        // INITIAL LOADING
        // ========================================================

        if (_initializing) {
          return const _LoadingView();
        }

        // ========================================================
        // FARM NOT FOUND
        // ========================================================

        if (farmId.isEmpty) {
          return _ErrorView(
            message: farmController.errorMessage.value.isNotEmpty
                ? farmController.errorMessage.value
                : 'No farm was found for your account.',
            onRetry: _initialize,
          );
        }

        // ========================================================
        // PRODUCT LOADING
        // ========================================================

        if (productController.isLoading.value &&
            productController.products.isEmpty) {
          return const _LoadingView();
        }

        // ========================================================
        // PRODUCT ERROR
        // ========================================================

        if (productController.errorMessage.value.isNotEmpty &&
            productController.products.isEmpty) {
          return _ErrorView(
            message: productController.errorMessage.value,
            onRetry: _refresh,
          );
        }

        // ========================================================
        // EMPTY
        // ========================================================

        if (productController.products.isEmpty) {
          return _EmptyProducts(
            onAddProduct: _openAddProduct,
            onRefresh: _refresh,
          );
        }

        // ========================================================
        // PRODUCTS
        // ========================================================

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refresh,
              color: FarmerDesign.primary,

              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),

                itemCount: productController.products.length,

                separatorBuilder: (_, __) => const SizedBox(height: 12),

                itemBuilder: (_, index) {
                  final product = productController.products[index];

                  return _ProductCard(
                    product: product,
                    onTap: () => _openProduct(product),
                  );
                },
              ),
            ),

            // ----------------------------------------------------
            // Refresh/loading indicator while existing products
            // remain visible
            // ----------------------------------------------------
            if (productController.isLoading.value)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  color: FarmerDesign.primary,
                  backgroundColor: FarmerDesign.primaryLight,
                ),
              ),
          ],
        );
      }),
    );
  }
}

// ============================================================================
// LOADING VIEW
// ============================================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: FarmerDesign.primary),
    );
  }
}

// ============================================================================
// PRODUCT CARD
// ============================================================================

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = product.images.isNotEmpty ? product.images.first.image : '';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(FarmerDesign.radiusMedium),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(FarmerDesign.radiusMedium),

        child: Container(
          padding: const EdgeInsets.all(12),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FarmerDesign.radiusMedium),

            border: Border.all(color: FarmerDesign.border),
          ),

          child: Row(
            children: [
              // --------------------------------------------------
              // IMAGE
              // --------------------------------------------------

              _ProductImage(image: image),

              const SizedBox(width: 14),

              // --------------------------------------------------
              // INFORMATION
              // --------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: FarmerDesign.heading3,
                          ),
                        ),

                        const SizedBox(width: 8),

                        _StatusBadge(active: product.isActive),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        const Icon(
                          Icons.sell_outlined,
                          size: 15,
                          color: FarmerDesign.primary,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: FarmerDesign.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(width: 4),

                        Text('/ ${product.unit}', style: FarmerDesign.caption),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          product.isInStock
                              ? Icons.inventory_2_outlined
                              : Icons.inventory_2_outlined,
                          size: 15,
                          color: product.isInStock
                              ? FarmerDesign.success
                              : FarmerDesign.error,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          product.isInStock
                              ? '${product.quantityAvailable} ${product.unit} in stock'
                              : 'Out of stock',
                          style: FarmerDesign.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              const Icon(
                Icons.chevron_right_rounded,
                color: FarmerDesign.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PRODUCT IMAGE
// ============================================================================

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    if (image.trim().isEmpty) {
      return _placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),

      child: Image.network(
        image,
        width: 78,
        height: 78,
        fit: BoxFit.cover,

        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return _placeholder(loading: true);
        },

        errorBuilder: (_, __, ___) {
          return _placeholder(broken: true);
        },
      ),
    );
  }

  Widget _placeholder({bool loading = false, bool broken = false}) {
    return Container(
      width: 78,
      height: 78,

      decoration: BoxDecoration(
        color: FarmerDesign.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Icon(
        loading
            ? Icons.image_outlined
            : broken
            ? Icons.broken_image_outlined
            : Icons.eco_outlined,
        color: FarmerDesign.primary,
        size: 30,
      ),
    );
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

      decoration: BoxDecoration(
        color: active ? FarmerDesign.successLight : FarmerDesign.errorLight,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        active ? 'Active' : 'Inactive',

        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: active ? FarmerDesign.success : FarmerDesign.error,
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY PRODUCTS
// ============================================================================

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts({required this.onAddProduct, required this.onRefresh});

  final VoidCallback onAddProduct;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: FarmerDesign.primary,

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.symmetric(horizontal: 28),

        children: [
          const SizedBox(height: 90),

          Container(
            width: 100,
            height: 100,

            decoration: BoxDecoration(
              color: FarmerDesign.primaryLight,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.eco_outlined,
              size: 52,
              color: FarmerDesign.primary,
            ),
          ),

          const SizedBox(height: 24),

          const Center(
            child: Text('No products yet', style: FarmerDesign.heading2),
          ),

          const SizedBox(height: 10),

          const Text(
            'Add products from your farm so customers can discover and purchase your fresh produce.',
            textAlign: TextAlign.center,
            style: FarmerDesign.body,
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 50,

            child: ElevatedButton.icon(
              onPressed: onAddProduct,

              icon: const Icon(Icons.add_rounded),

              label: const Text('Add Your First Product'),

              style: ElevatedButton.styleFrom(
                backgroundColor: FarmerDesign.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    FarmerDesign.radiusMedium,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ============================================================================
// ERROR VIEW
// ============================================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 76,
              height: 76,

              decoration: BoxDecoration(
                color: FarmerDesign.errorLight,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.cloud_off_rounded,
                size: 38,
                color: FarmerDesign.error,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Could not load products',
              style: FarmerDesign.heading3,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: FarmerDesign.caption,
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: onRetry,

              icon: const Icon(Icons.refresh_rounded),

              label: const Text('Try Again'),

              style: ElevatedButton.styleFrom(
                backgroundColor: FarmerDesign.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    FarmerDesign.radiusMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
