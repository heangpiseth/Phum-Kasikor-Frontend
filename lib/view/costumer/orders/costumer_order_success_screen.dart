import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/model/customer/costumer_order_model.dart';

class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;

    if (args is! CustomerOrderModel) {
      return const _InvalidOrderState();
    }

    final order = args;

    final orderDate = order.date ?? DateTime.now();

    final estimatedDelivery = orderDate.add(
      const Duration(days: 3),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3),
      body: SafeArea(
        child: Column(
          children: [
            // ======================================================
            // SCROLLABLE CONTENT
            // ======================================================

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  24,
                ),
                child: Column(
                  children: [
                    _buildSuccessIcon(),

                    const SizedBox(height: 18),

                    const Text(
                      'Order Placed Successfully!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF263238),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Your order has been sent to the farmer.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ORDER NUMBER
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          color: Color(0xFF1B5E20),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildOrderSummary(order),

                    const SizedBox(height: 16),

                    _buildDeliveryCard(
                      estimatedDelivery,
                    ),

                    const SizedBox(height: 16),

                    _buildPaymentCard(order),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // ======================================================
            // FIXED BOTTOM BUTTONS
            // ======================================================

            _buildBottomButtons(order),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUCCESS ICON
  // ============================================================

  Widget _buildSuccessIcon() {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFC8E6C9),
          width: 2,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(9),
        decoration: const BoxDecoration(
          color: Color(0xFF2E7D32),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: 42,
        ),
      ),
    );
  }

  // ============================================================
  // ORDER SUMMARY
  // ============================================================

  Widget _buildOrderSummary(
    CustomerOrderModel order,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE1E7DE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF2E7D32),
                size: 21,
              ),
              SizedBox(width: 8),
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF263238),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (order.items.isEmpty)
            const Text(
              'No order items found.',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            )
          else
            ...order.items.map(
              (item) => _buildOrderItem(item),
            ),

          const Divider(height: 22),

          _summaryRow(
            'Subtotal',
            '\$${order.subtotal.toStringAsFixed(2)}',
          ),

          const SizedBox(height: 8),

          _summaryRow(
            'Delivery',
            order.deliveryFee == 0
                ? 'FREE'
                : '\$${order.deliveryFee.toStringAsFixed(2)}',
            valueColor: order.deliveryFee == 0
                ? const Color(0xFF2E7D32)
                : null,
          ),

          const Divider(height: 22),

          _summaryRow(
            'Total',
            '\$${order.total.toStringAsFixed(2)}',
            bold: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ORDER ITEM
  // ============================================================

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: Color(0xFF2E7D32),
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF263238),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            '\$${item.subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF263238),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _summaryRow(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            fontWeight: bold
                ? FontWeight.w800
                : FontWeight.w500,
            color: bold
                ? const Color(0xFF263238)
                : AppColors.textSecondary,
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 17 : 13,
            fontWeight: bold
                ? FontWeight.w900
                : FontWeight.w700,
            color: valueColor ??
                (bold
                    ? const Color(0xFF1B5E20)
                    : const Color(0xFF263238)),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DELIVERY CARD
  // ============================================================

  Widget _buildDeliveryCard(
    DateTime estimatedDelivery,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFC8E6C9),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: Color(0xFF2E7D32),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated Delivery',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  _formatDate(
                    estimatedDelivery,
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT CARD
  // ============================================================

  Widget _buildPaymentCard(
    CustomerOrderModel order,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE1E7DE),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: Color(0xFF1976D2),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  order.paymentMethod.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          _statusChip(
            order.displayStatus,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFF8A6D00),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM BUTTONS
  // ============================================================

  Widget _buildBottomButtons(
    CustomerOrderModel order,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: Color(0xFFE1E7DE),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.06,
            ),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.offNamed(
                    AppRoutes.costumerOrderTrackingscreen,
                    arguments:
                        _convertToOrderModel(order),
                  );
                },
                icon: const Icon(
                  Icons.local_shipping_outlined,
                ),
                label: const Text(
                  'Track Order',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () {
                  Get.offAllNamed(
                    AppRoutes.main,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      const Color(0xFF2E7D32),
                  side: const BorderSide(
                    color: Color(0xFF2E7D32),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CONVERT TO EXISTING TRACKING MODEL
  // ============================================================

  OrderModel _convertToOrderModel(
    CustomerOrderModel customerOrder,
  ) {
    return OrderModel(
      id: customerOrder.id,
      date: customerOrder.date ??
          DateTime.now(),
      items: customerOrder.items,
      deliveryAddress:
          customerOrder.deliveryAddress,
      deliveryMethod:
          customerOrder.deliveryMethod,
      paymentMethod:
          customerOrder.paymentMethod,
      deliveryFee:
          customerOrder.deliveryFee,
      farmName:
          customerOrder.farmName,
      farmerName:
          customerOrder.farmerName,
      farmerPhone:
          customerOrder.farmerPhone,
      note:
          customerOrder.note,
      status:
          customerOrder.status,
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, '
        '${date.year}';
  }
}

// ================================================================
// INVALID ORDER STATE
// ================================================================

class _InvalidOrderState extends StatelessWidget {
  const _InvalidOrderState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8F3),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: Color(0xFFD32F2F),
                    size: 38,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Order details unavailable',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'The order was created, but its details could not be displayed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(
                      AppRoutes.main,
                    );
                  },
                  child: const Text(
                    'Continue Shopping',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}