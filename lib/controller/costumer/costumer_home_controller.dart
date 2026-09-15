import 'package:get/get.dart';
import 'package:phum_kasikors/model/customer/costumer_farm_model.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';
import 'package:phum_kasikors/repositories/costumer/data_service.dart';

class HomeController extends GetxController {
  final _dataService = MockDataService.to;

  final userName = 'Channa'.obs;
  final userLocation = 'Phnom Penh, Cambodia'.obs;
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs; // All / Vegetables / Fruits / Grains

  late final RxList<FarmModel> featuredFarms = <FarmModel>[].obs;
  late final RxList<ProductModel> freshToday = <ProductModel>[].obs;
  late final RxList<FarmModel> nearYou = <FarmModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    featuredFarms.assignAll(_dataService.farms);
    freshToday.assignAll(_dataService.featuredToday);
    nearYou.assignAll(_dataService.farms);
  }

  void setFilter(String filter) => selectedFilter.value = filter;

  void goToSearch(dynamic Routes) => Get.toNamed(Routes.search);

  void openFarm(String farmId, dynamic Routes) =>
      Get.toNamed(Routes.farmDetail, arguments: farmId);

  void openProduct(ProductModel product, dynamic Routes) =>
      Get.toNamed(Routes.productDetail, arguments: product);

  void openFilter() {}
}