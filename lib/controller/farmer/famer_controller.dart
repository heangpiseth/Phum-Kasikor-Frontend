import 'package:get/get.dart';
import 'package:phum_kasikors/model/farmer/crop_model.dart';
import 'package:phum_kasikors/model/farmer/product_model.dart';

class FarmerOrder {
  FarmerOrder({
    required this.id,
    required this.customer,
    required this.itemCount,
    required this.total,
    this.status = 'Pending',
  });

  final String id;
  final String customer;
  final int itemCount;
  final double total;
  String status;
}

class FarmerController extends GetxController {
  final crops = <CropModel>[].obs;
  final products = <ProductModel>[].obs;
  final orders = <FarmerOrder>[].obs;

  @override
  void onInit() {
    super.onInit();
    crops.assignAll([
      CropModel(
        id: 'crop-1',
        farmId: 'farm-1',
        name: 'Organic Rice',
        plantedAt: DateTime(2024, 8, 12),
        expectedHarvestAt: DateTime(2024, 12, 20),
        status: 'Growing',
      ),
    ]);
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
      ),
    ]);
    orders.assignAll([
      FarmerOrder(
        id: 'order-1001',
        customer: 'Dara Sok',
        itemCount: 2,
        total: 24.50,
      ),
    ]);
  }

  void addCrop(CropModel crop) => crops.add(crop);

  void addProduct(ProductModel product) => products.add(product);

  void advanceOrder(FarmerOrder order) {
    const stages = ['Pending', 'Preparing', 'Ready', 'Completed'];
    final currentIndex = stages.indexOf(order.status);
    if (currentIndex >= 0 && currentIndex < stages.length - 1) {
      order.status = stages[currentIndex + 1];
      orders.refresh();
    }
  }
}
