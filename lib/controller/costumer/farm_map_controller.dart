import 'package:get/get.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/model/customer/costumer_farm_model.dart';
import 'package:phum_kasikors/repositories/costumer/customer_product_repository.dart';

enum FarmMapDisplayMode { map, list }

class FarmMapController extends GetxController {
  final repository = Get.find<CustomerProductRepository>();

  final displayMode = FarmMapDisplayMode.map.obs;
  final selectedFarmId = RxnInt();

  final RxList<FarmModel> farms = <FarmModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    ever(repository.farms, (_) => _syncFarms());
    ever(repository.isLoading, (_) => _syncFarms());
    ever(repository.errorMessage, (_) => _syncFarms());

    _syncFarms();

    final arg = Get.arguments;
    if (arg is String) {
      selectedFarmId.value = int.tryParse(arg);
    } else if (arg is int) {
      selectedFarmId.value = arg;
    }
  }

  void _syncFarms() {
    isLoading.value = repository.isLoading.value;
    errorMessage.value = repository.errorMessage.value;

    if (!repository.isLoading.value && repository.errorMessage.value.isEmpty) {
      farms.assignAll(repository.farms);
      if (selectedFarmId.value == null && farms.isNotEmpty) {
        selectedFarmId.value = farms.first.id;
      }
    }
  }

  FarmModel? get selectedFarm {
    if (farms.isEmpty) return null;
    return farms.firstWhere(
      (f) => f.id == selectedFarmId.value,
      orElse: () => farms.first,
    );
  }

  void selectFarm(String farmId) {
    selectedFarmId.value = int.tryParse(farmId);
  }

  void setDisplayMode(FarmMapDisplayMode mode) => displayMode.value = mode;

  void openDirections() {
    final farm = selectedFarm;
    if (farm == null) return;
    Get.snackbar('Directions', 'Opening directions to ${farm.name}...');
  }

  void visitStorefront() => Get.toNamed(
    AppRoutes.costumerFarmDetailscreen,
    arguments: selectedFarm?.id.toString() ?? '',
  );

  void openFarmProducts(String farmId) => Get.toNamed(
    AppRoutes.costumerFarmProductsscreen,
    arguments: repository.productsByFarm(farmId),
  );

  void openFarmDetail(String farmId) =>
      Get.toNamed(AppRoutes.costumerFarmDetailscreen, arguments: farmId);
}
