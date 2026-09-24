import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/controller/costumer/costumer_product_controller.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';

class FarmProductsScreen extends StatefulWidget {
  const FarmProductsScreen({super.key});

  @override
  State<FarmProductsScreen> createState() => _FarmProductsScreenState();
}

class _FarmProductsScreenState extends State<FarmProductsScreen> {
  late final FarmProductsController controller;
  late final String _tag;

  @override
  void initState() {
    super.initState();

    _tag = UniqueKey().toString();

    final args = Get.arguments;

    final List<ProductModel> products =
        args is List<ProductModel>
            ? List<ProductModel>.from(args)
            : <ProductModel>[];

    controller = Get.put(
      FarmProductsController(
        allProducts: products,
      ),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<FarmProductsController>(
      tag: _tag,
    )) {
      Get.delete<FarmProductsController>(
        tag: _tag,
      );
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Products'),
        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.cycleSortOrder,
              icon: const Icon(Icons.sort),
              tooltip: controller.sortLabel,
            ),
          ),
        ],
      ),
      body: Obx(() {
        final products = controller.visibleProducts;

        if (products.isEmpty) {
          return const Center(
            child: Text('No products found for this farm.'),
          );
        }

        return Column(
          children: [
            _buildCategoryFilter(),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildProductCard(product);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCategoryFilter() {
    return Obx(() {
      final categories = ['All', ...controller.availableCategories];
      return SizedBox(
        height: 50,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          scrollDirection: Axis.horizontal,
          children: categories.map((category) {
            return Obx(() {
              final selected = controller.selectedCategory.value == category;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) {
                    controller.selectCategory(category == 'All' ? null : category);
                  },
                ),
              );
            });
          }).toList(),
        ),
      );
    });
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Get.toNamed(
            AppRoutes.productDetail,
            arguments: product,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: product.images.isNotEmpty && product.images[0].image != null
                        ? Image.network(
                            product.images[0].image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              SizedBox(
                width: double.infinity,
                height: 36,
                child: Obx(() {
                  final inCart = controller.isInCart(product.id.toString());

                  return ElevatedButton.icon(
                    onPressed: () {
                      if (inCart) {
                        controller.removeFromCart(product);
                      } else {
                        controller.addToCart(product);
                      }
                    },
                    icon: Icon(
                      inCart ? Icons.check : Icons.add_shopping_cart,
                      size: 18,
                    ),
                    label: Text(inCart ? 'Added' : 'Add'),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}