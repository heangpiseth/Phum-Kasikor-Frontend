import 'package:get/get.dart';
import 'package:phum_kasikors/controller/costumer/costumer_product_controller.dart';
import 'package:phum_kasikors/model/farmer/product_model.dart';
import 'package:phum_kasikors/repositories/costumer/data_service.dart';


// Named SearchFilterController (not SearchController) to avoid clashing
// with Flutter Material's own SearchController class.
class SearchFilterController extends GetxController {
  final _dataService = MockDataService.to;

  final queryText = 'Organic vegetables'.obs;
  final isOrganicOnly = true.obs;
  final isVegetablesOnly = true.obs;
  final priceMax = 50.0.obs;
  final priceMin = 0.0.obs;

  late final RxList<ProductModel> results = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is ProductCategory) {
      isVegetablesOnly.value = arg == ProductCategory.vegetables;
    }
    runSearch();
  }

  void runSearch() {
    var list = _dataService.search(queryText.value);
    if (isVegetablesOnly.value) {
      list = list.where((p) => p.category == ProductCategory.vegetables).toList();
    }
    list = list.where((p) => p.price <= priceMax.value && p.price >= priceMin.value).toList();
    results.assignAll(list as Iterable<ProductModel>);
  }

  void clearFilters() {
    isOrganicOnly.value = false;
    isVegetablesOnly.value = false;
    priceMin.value = 0;
    priceMax.value = 50;
    runSearch();
  }

  void updatePriceRange(double min, double max) {
    priceMin.value = min;
    priceMax.value = max;
    runSearch();
  }

  void openProduct(ProductModel product, dynamic Routes) =>
      Get.toNamed(Routes.productDetail, arguments: product);
}