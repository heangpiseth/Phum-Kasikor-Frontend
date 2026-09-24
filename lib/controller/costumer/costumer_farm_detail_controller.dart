import 'package:get/get.dart';
import 'package:phum_kasikors/model/customer/costumer_farm_model.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';
import 'package:phum_kasikors/model/customer/costumer_review_model.dart';
import 'package:phum_kasikors/repositories/costumer/customer_product_repository.dart';

class FarmDetailController extends GetxController {
  final repository = Get.find<CustomerProductRepository>();

  late final int farmId;
  FarmModel? farm;

  final isFollowing = false.obs;
  final selectedCategory = 'All'.obs;
  final sortBy = 'Price Low-High'.obs;

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    final arg = Get.arguments;
    if (arg is String) {
      final parsedFarmId = int.tryParse(arg);
      if (parsedFarmId == null) {
        isLoading.value = false;
        errorMessage.value = 'Invalid farm id';
        return;
      }
      farmId = parsedFarmId;
    } else if (arg is int) {
      farmId = arg;
    } else if (repository.farms.isNotEmpty) {
      farmId = repository.farms.first.id;
    } else {
      isLoading.value = false;
      errorMessage.value = 'No farms available';
      return;
    }

    _loadFarmDetail();
  }

  Future<void> _loadFarmDetail() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final detail = await repository.getFarmDetail(farmId);
      if (detail != null) {
        farm = detail.farm;
        products.assignAll(detail.products);
        reviews.assignAll(detail.reviews);
      } else {
        errorMessage.value = 'Farm not found';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void toggleFollow() => isFollowing.value = !isFollowing.value;

  void filterByCategory(String category) {
    selectedCategory.value = category;
    var list = repository.productsByFarm(farmId.toString());
    if (category != 'All') {
      list = list
          .where(
            (p) =>
                p.category?.name.toLowerCase().contains(
                  category.toLowerCase(),
                ) ??
                false,
          )
          .toList();
    }
    products.assignAll(list);
  }

  void openProduct(ProductModel product) =>
      Get.toNamed('/costumer/product-detailscreen', arguments: product);
}
