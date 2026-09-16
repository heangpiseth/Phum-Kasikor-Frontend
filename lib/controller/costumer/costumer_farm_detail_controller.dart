import 'package:get/get.dart';
import 'package:phum_kasikors/model/customer/costumer_farm_model.dart';
import 'package:phum_kasikors/model/customer/costumer_review_model.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';
import 'package:phum_kasikors/repositories/costumer/data_service.dart';


class FarmDetailController extends GetxController {
  final _dataService = MockDataService.to;

  late final FarmModel farm;
  final isFollowing = false.obs;
  final selectedCategory = 'All'.obs;
  final sortBy = 'Price Low-High'.obs;

  late final RxList<ProductModel> products = <ProductModel>[].obs;
  late final List<ReviewModel> reviews;

  @override
  void onInit() {
    super.onInit();
    final farmId = Get.arguments as String? ?? _dataService.farms.first.id;
    farm = _dataService.farmById(farmId);
    products.assignAll(_dataService.productsByFarm(farmId));
    reviews = _dataService.reviews;
  }

  void toggleFollow() => isFollowing.value = !isFollowing.value;

  void filterByCategory(String category) {
    selectedCategory.value = category;
    var list = _dataService.productsByFarm(farm.id);
    if (category != 'All') {
      list = list
          .where((p) => p.category.name.toLowerCase().contains(category.toLowerCase()))
          .toList();
    }
    products.assignAll(list);
  }

  void openProduct(ProductModel product) =>
      Get.toNamed('/costumer/product-detailscreen', arguments: product);
}
