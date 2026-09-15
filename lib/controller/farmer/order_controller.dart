import 'package:get/get.dart';
import 'package:phum_kasikors/model/farmer/order_model.dart';


class OrderController extends GetxController {
  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  static const fulfillmentStages = [
    'Pending',
    'Preparing',
    'Ready',
    'Delivered',
  ];

  List<OrderModel> get pendingOrders =>
      orders.where((o) => o.fulfillmentStage == 0).toList();

  List<OrderModel> get preparingOrders =>
      orders.where((o) => o.fulfillmentStage == 1).toList();

  List<OrderModel> get readyOrders =>
      orders.where((o) => o.fulfillmentStage == 2).toList();

  List<OrderModel> get deliveredOrders =>
      orders.where((o) => o.fulfillmentStage == 3).toList();

  List<OrderModel> get activeOrders =>
      orders.where((o) => o.fulfillmentStage < 3).toList();

  double get totalEarnings => orders
      .where((o) => o.fulfillmentStage == 3)
      .fold(0, (sum, o) => sum + o.total);

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await Future.delayed(const Duration(seconds: 1));

      orders.assignAll([
        OrderModel(
          orderId: 'order-1001',
          productName: 'Organic Rice',
          sellerName: 'Sok Chanthan',
          customerName: 'Dara Sok',
          phone: '0987654321',
          address: 'Phnom Penh, Cambodia',
          items: [
            OrderItemModel(
              name: 'Rice',
              khmerName: 'ប្រេង',
              quantity: '2 kg',
              price: 2.40,
            ),
          ],
          subtotal: 4.80,
          deliveryFee: 2.00,
          total: 6.80,
          paymentMethod: 'QR Code',
          paymentVerified: true,
          fulfillmentStage: 0,
        ),
        OrderModel(
          orderId: 'order-1002',
          productName: 'Organic Tomatoes',
          sellerName: 'Sok Chanthan',
          customerName: 'Sophea Nguon',
          phone: '0978901234',
          address: 'Siem Reap, Cambodia',
          items: [
            OrderItemModel(
              name: 'Tomatoes',
              khmerName: 'មាន់',
              quantity: '3 kg',
              price: 3.50,
            ),
          ],
          subtotal: 10.50,
          deliveryFee: 2.00,
          total: 12.50,
          paymentMethod: 'Cash',
          paymentVerified: true,
          fulfillmentStage: 1,
        ),
        OrderModel(
          orderId: 'order-1003',
          productName: 'Organic Bananas',
          sellerName: 'Sok Chanthan',
          customerName: 'Bopha Keo',
          phone: '0123456789',
          address: 'Battambang, Cambodia',
          items: [
            OrderItemModel(
              name: 'Bananas',
              khmerName: 'ក្តាម',
              quantity: '5 kg',
              price: 1.80,
            ),
          ],
          subtotal: 9.00,
          deliveryFee: 2.00,
          total: 11.00,
          paymentMethod: 'QR Code',
          paymentVerified: true,
          fulfillmentStage: 2,
        ),
        OrderModel(
          orderId: 'order-1004',
          productName: 'Organic Basil',
          sellerName: 'Sok Chanthan',
          customerName: 'Ratha Seng',
          phone: '0967890123',
          address: 'Kampong Cham, Cambodia',
          items: [
            OrderItemModel(
              name: 'Basil',
              khmerName: 'ក្តាម',
              quantity: '2 bunches',
              price: 5.00,
            ),
          ],
          subtotal: 10.00,
          deliveryFee: 2.00,
          total: 12.00,
          paymentMethod: 'QR Code',
          paymentVerified: true,
          fulfillmentStage: 3,
        ),
      ]);

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  Future<void> refreshOrders() async {
    await loadOrders();
  }

  void advanceOrder(OrderModel order) {
    final currentIndex = fulfillmentStages.indexOf(
      fulfillmentStages[order.fulfillmentStage],
    );
    if (currentIndex >= 0 && currentIndex < fulfillmentStages.length - 1) {
      order.fulfillmentStage = currentIndex + 1;
      orders.refresh();
    }
  }

  void updateOrderStatus(OrderModel order, int stage) {
    if (stage >= 0 && stage < fulfillmentStages.length) {
      order.fulfillmentStage = stage;
      orders.refresh();
    }
  }

  void cancelOrder(OrderModel order) {
    order.fulfillmentStage = -1;
    orders.refresh();
  }

  OrderModel? getOrderById(String orderId) {
    try {
      return orders.firstWhere((o) => o.orderId == orderId);
    } catch (e) {
      return null;
    }
  }

  List<OrderModel> searchOrders(String query) {
    if (query.isEmpty) {
      return orders;
    }
    final lowerQuery = query.toLowerCase();
    return orders
        .where(
          (o) =>
              o.customerName.toLowerCase().contains(lowerQuery) ||
              o.productName.toLowerCase().contains(lowerQuery) ||
              o.orderId.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }
}
