import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/controller/costumer/customer_order_controller.dart';
import 'package:phum_kasikors/model/customer/costumer_order_model.dart';

class CustomerOrderDetailScreen extends StatefulWidget {
  const CustomerOrderDetailScreen({
    super.key,
  });

  @override
  State<CustomerOrderDetailScreen> createState() =>
      _CustomerOrderDetailScreenState();
}

class _CustomerOrderDetailScreenState
    extends State<CustomerOrderDetailScreen> {
  late final CustomerOrderController controller;
  late final String orderId;

  @override
  void initState() {
    super.initState();

    controller = Get.find<CustomerOrderController>();
    orderId = Get.arguments.toString();

    controller.loadOrder(orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value &&
            controller.selectedOrder.value == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final order = controller.selectedOrder.value;

        if (order == null) {
          return Center(
            child: Text(
              controller.errorMessage.value.isEmpty
                  ? 'Order not found.'
                  : controller.errorMessage.value,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadOrder(orderId);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _OrderHeader(order: order),
              const SizedBox(height: 16),
              _OrderStatusCard(order: order),
              const SizedBox(height: 16),
              _ItemsCard(order: order),
              const SizedBox(height: 16),
              _DeliveryCard(order: order),
              const SizedBox(height: 16),
              _PaymentCard(order: order),
              const SizedBox(height: 16),
              _ReceiptCard(order: order),
              if (order.canCancel) ...[
                const SizedBox(height: 20),
                _CancelButton(
                  controller: controller,
                  orderId: order.id,
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({
    required this.order,
  });

  final CustomerOrderModel order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order #${order.id}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        if (order.createdAt != null)
          Text(
            _formatDate(order.createdAt!),
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _OrderStatusCard extends StatelessWidget {
  const _OrderStatusCard({
    required this.order,
  });

  final CustomerOrderModel order;

  @override
  Widget build(BuildContext context) {
    const statuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.packed,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];

    final currentIndex = statuses.indexOf(order.status);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          if (order.status == OrderStatus.cancelled)
            const Row(
              children: [
                Icon(Icons.cancel_outlined),
                SizedBox(width: 10),
                Text(
                  'Order Cancelled',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          else
            ...List.generate(
              statuses.length,
              (index) {
                final completed = currentIndex >= index;
                final isCurrent = currentIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        completed
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        statuses[index].label,
                        style: TextStyle(
                          fontWeight: isCurrent
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({
    required this.order,
  });

  final CustomerOrderModel order;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Items',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.eco_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({
    required this.order,
  });

  final CustomerOrderModel order;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.local_shipping_outlined,
            title: 'Method',
            value: order.deliveryMethod.label,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.location_on_outlined,
            title: 'Address',
            value: order.deliveryAddress.isEmpty
                ? 'Not specified'
                : order.deliveryAddress,
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.order,
  });

  final CustomerOrderModel order;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.payment_outlined,
            title: 'Method',
            value: order.paymentMethod.label,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.verified_outlined,
            title: 'Status',
            value: order.paymentMethod.displayStatus,
          ),
        ],
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({
    required this.order,
  });

  final CustomerOrderModel order;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined),
              SizedBox(width: 8),
              Text(
                'Receipt',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _TotalRow(
            title: 'Subtotal',
            value: order.subtotal,
          ),
          if (order.deliveryFee > 0) ...[
            const SizedBox(height: 8),
            _TotalRow(
              title: 'Delivery Fee',
              value: order.deliveryFee,
            ),
          ],
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _TotalRow(
            title: 'Total',
            value: order.totalAmount,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({
    required this.controller,
    required this.orderId,
  });

  final CustomerOrderController controller;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: controller.isCancelling.value
              ? null
              : () => _cancel(context),
          child: controller.isCancelling.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Cancel Order',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _cancel(BuildContext context) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel order?'),
        content: const Text(
          'Are you sure you want to cancel this order?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Keep Order'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await controller.cancelOrder(orderId);

    if (success) {
      Get.snackbar(
        'Order cancelled',
        'Your order has been cancelled.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Unable to cancel',
        controller.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.title,
    required this.value,
    this.bold = false,
  });

  final String title;
  final double value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight:
                bold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight:
                bold ? FontWeight.w900 : FontWeight.w600,
            fontSize: bold ? 17 : 14,
          ),
        ),
      ],
    );
  }
}