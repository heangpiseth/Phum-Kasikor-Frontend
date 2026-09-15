import 'package:get/get.dart';
import 'package:phum_kasikors/model/customer/costumer_farm_model.dart';
import 'package:phum_kasikors/repositories/costumer/data_service.dart';


enum FarmMapDisplayMode { map, list }

class FarmMapController extends GetxController {
  final _dataService = MockDataService.to;

  final displayMode = FarmMapDisplayMode.map.obs;
  final selectedFarmId = RxnString();

  late final RxList<FarmModel> farms = <FarmModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    farms.assignAll(_dataService.farms);
    selectedFarmId.value = arg is String ? arg : farms.first.id;
  }

  FarmModel get selectedFarm =>
      farms.firstWhere((f) => f.id == selectedFarmId.value, orElse: () => farms.first);

  void selectFarm(String farmId) => selectedFarmId.value = farmId;
  void setDisplayMode(FarmMapDisplayMode mode) => displayMode.value = mode;

  void openDirections() {
    Get.snackbar('Directions', 'Opening directions to ${selectedFarm.name}...');
  }

  void visitStorefront(dynamic Routes) =>
      Get.toNamed(Routes.farmDetail, arguments: selectedFarm.id);

  void openFarmProducts(id) {}

  void openFarmDetail(id) {}
}



