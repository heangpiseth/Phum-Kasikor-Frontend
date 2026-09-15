import 'package:get/get.dart';
import 'package:phum_kasikors/model/farmer/category_model.dart';
import 'package:phum_kasikors/model/farmer/product_model.dart';

class ProductController extends GetxController {
  final products = <ProductModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final selectedCategory = Rxn<String>();

  List<ProductModel> get filteredProducts {
    if (selectedCategory.value == null) {
      return products;
    }
    return products
        .where((p) => p.categoryId == selectedCategory.value)
        .toList();
  }

  List<ProductModel> get availableProducts =>
      products.where((p) => p.isAvailable).toList();

  List<ProductModel> get lowStockProducts =>
      products.where((p) => p.stock > 0 && p.stock <= 10).toList();

  List<ProductModel> get outOfStockProducts =>
      products.where((p) => p.stock == 0).toList();

  @override
  void onInit() {
    super.onInit();
    _initializeCategories();
    loadProducts();
  }

  void _initializeCategories() {
    categories.assignAll([
      CategoryModel(id: 'grains', name: 'Grains', productCount: 12),
      CategoryModel(id: 'vegetables', name: 'Vegetables', productCount: 8),
      CategoryModel(id: 'fruits', name: 'Fruits', productCount: 6),
      CategoryModel(id: 'herbs', name: 'Herbs', productCount: 4),
    ]);
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await Future.delayed(const Duration(seconds: 1));

      products.assignAll([
        ProductModel(
          id: 'product-1',
          farmId: 'farm-1',
          name: 'Organic Rice',
          price: 2.40,
          unit: 'kg',
          stock: 120,
          categoryId: 'grains',
          description: 'Fresh organic rice from our farm.',
          imageUrl: 'assets/images/rice.jpg',
        ),
        ProductModel(
          id: 'product-2',
          farmId: 'farm-1',
          name: 'Organic Tomatoes',
          price: 3.50,
          unit: 'kg',
          stock: 50,
          categoryId: 'vegetables',
          description: 'Fresh organic tomatoes.',
          imageUrl: 'assets/images/tomatoes.jpg',
        ),
        ProductModel(
          id: 'product-3',
          farmId: 'farm-1',
          name: 'Organic Bananas',
          price: 1.80,
          unit: 'kg',
          stock: 80,
          categoryId: 'fruits',
          description: 'Sweet organic bananas.',
          imageUrl: 'assets/images/bananas.jpg',
        ),
        ProductModel(
          id: 'product-4',
          farmId: 'farm-1',
          name: 'Organic Basil',
          price: 5.00,
          unit: 'bunch',
          stock: 30,
          categoryId: 'herbs',
          description: 'Fresh organic basil.',
          imageUrl: 'assets/images/basil.jpg',
        ),
      ]);

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  Future<void> refreshProducts() async {
    await loadProducts();
  }

  void selectCategory(String? categoryId) {
    selectedCategory.value = categoryId;
  }

  void clearCategoryFilter() {
    selectedCategory.value = null;
  }

  Future<bool> addProduct(ProductModel product) async {
    try {
      products.add(product);
      _updateCategoryCount(product.categoryId, 1);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> updateProduct(
    String productId,
    ProductModel updatedProduct,
  ) async {
    try {
      final index = products.indexWhere((p) => p.id == productId);
      if (index >= 0) {
        final oldProduct = products[index];
        products[index] = updatedProduct;
        products.refresh();
        if (oldProduct.categoryId != updatedProduct.categoryId) {
          _updateCategoryCount(oldProduct.categoryId, -1);
          _updateCategoryCount(updatedProduct.categoryId, 1);
        }
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      final index = products.indexWhere((p) => p.id == productId);
      if (index >= 0) {
        final product = products[index];
        products.removeAt(index);
        _updateCategoryCount(product.categoryId, -1);
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> toggleAvailability(String productId) async {
    try {
      final index = products.indexWhere((p) => p.id == productId);
      if (index >= 0) {
        final product = products[index];
        products[index] = ProductModel(
          id: product.id,
          farmId: product.farmId,
          name: product.name,
          price: product.price,
          unit: product.unit,
          stock: product.stock,
          categoryId: product.categoryId,
          description: product.description,
          imageUrl: product.imageUrl,
          isAvailable: !product.isAvailable,
        );
        products.refresh();
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> updateStock(String productId, int newStock) async {
    try {
      final index = products.indexWhere((p) => p.id == productId);
      if (index >= 0) {
        final product = products[index];
        products[index] = ProductModel(
          id: product.id,
          farmId: product.farmId,
          name: product.name,
          price: product.price,
          unit: product.unit,
          stock: newStock,
          categoryId: product.categoryId,
          description: product.description,
          imageUrl: product.imageUrl,
          isAvailable: product.isAvailable,
        );
        products.refresh();
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  ProductModel? getProductById(String productId) {
    try {
      return products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  List<ProductModel> searchProducts(String query) {
    if (query.isEmpty) {
      return products;
    }
    final lowerQuery = query.toLowerCase();
    return products
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  void _updateCategoryCount(String? categoryId, int delta) {
    if (categoryId == null) return;
    final index = categories.indexWhere((c) => c.id == categoryId);
    if (index >= 0) {
      final category = categories[index];
      categories[index] = CategoryModel(
        id: category.id,
        name: category.name,
        imageUrl: category.imageUrl,
        productCount: category.productCount + delta,
      );
      categories.refresh();
    }
  }
}
