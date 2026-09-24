import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/controller/farmer/order_controller.dart';
import 'package:phum_kasikors/model/farmer/order_model.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';

class FarmerOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const FarmerOrderDetailScreen({super.key, required this.orderId});

  @override
  State<FarmerOrderDetailScreen> createState() =>
      _FarmerOrderDetailScreenState();
}

class _FarmerOrderDetailScreenState extends State<FarmerOrderDetailScreen> {
  late final OrderController controller;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<OrderController>()) {
      controller = Get.find<OrderController>();
    } else {
      controller = Get.put(OrderController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      controller.loadOrderDetail(widget.orderId);
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerDesign.background,
      appBar: AppBar(
        backgroundColor: FarmerDesign.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_rounded, color: FarmerDesign.text),
        ),
        title: const Text('Order Details', style: FarmerDesign.heading3),
      ),
      body: Obx(() {
        final order = controller.selectedOrder.value;

        // ======================================================
        // LOADING
        // ======================================================

        if (controller.isUpdating.value && order == null) {
          return const Center(
            child: CircularProgressIndicator(color: FarmerDesign.primary),
          );
        }

        // ======================================================
        // ERROR / NO ORDER
        // ======================================================

        if (order == null) {
          return _buildError();
        }

        // ======================================================
        // CONTENT
        // ======================================================

        return RefreshIndicator(
          color: FarmerDesign.primary,
          onRefresh: () async {
            await controller.loadOrderDetail(widget.orderId);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _buildOrderHeader(order),

              const SizedBox(height: 14),

              _buildCustomerSection(order),

              const SizedBox(height: 14),

              _buildItemsSection(order),

              const SizedBox(height: 14),

              _buildSummary(order),

              const SizedBox(height: 14),

              _buildPaymentSection(order),

              const SizedBox(height: 14),

              _buildStatusTimeline(order),

              const SizedBox(height: 18),

              _buildActionSection(order),
            ],
          ),
        );
      }),
    );
  }

  // ============================================================
  // RIEL FORMATTER
  // ============================================================

  String _formatRiel(double amount) {
    final value = amount.round().toString();

    final formatted = value.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return '៛$formatted';
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildOrderHeader(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [FarmerDesign.primary, FarmerDesign.primaryDark],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: FarmerDesign.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Order',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '#${order.orderId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              _StatusBadge(status: order.status),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 18,
                  color: Colors.white,
                ),

                const SizedBox(width: 8),

                Text(
                  '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                Text(
                  _formatRiel(order.total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
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
  // CUSTOMER
  // ============================================================

  Widget _buildCustomerSection(OrderModel order) {
    return _SectionCard(
      title: 'Customer Information',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Customer',
            value: _safeValue(order.customerName, 'Customer'),
          ),

          const SizedBox(height: 13),

          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: _safeValue(order.phone, 'No phone number'),
          ),

          const SizedBox(height: 13),

          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Delivery address',
            value: _safeValue(order.address, 'No delivery address'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ITEMS
  // ============================================================

  Widget _buildItemsSection(OrderModel order) {
    return _SectionCard(
      title: 'Order Items',
      icon: Icons.shopping_bag_outlined,
      child: Column(
        children: [
          if (order.items.isEmpty)
            const Text('No order items found.', style: FarmerDesign.bodySmall)
          else
            for (int i = 0; i < order.items.length; i++) ...[
              _ItemRow(item: order.items[i]),

              if (i < order.items.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(color: FarmerDesign.divider),
                ),
            ],
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(OrderModel order) {
    return _SectionCard(
      title: 'Order Summary',
      icon: Icons.receipt_outlined,
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: _formatRiel(order.subtotal)),

          const SizedBox(height: 11),

          _SummaryRow(
            label: 'Delivery fee',
            value: _formatRiel(order.deliveryFee),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Divider(color: FarmerDesign.divider),
          ),

          _SummaryRow(
            label: 'Total',
            value: _formatRiel(order.total),
            bold: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT
  // ============================================================

  Widget _buildPaymentSection(OrderModel order) {
    final verified = order.paymentVerified;

    final paymentMethod = order.paymentMethod.trim().isEmpty
        ? 'Payment method'
        : order.paymentMethod;

    return _SectionCard(
      title: 'Payment',
      icon: Icons.payments_outlined,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: verified
                  ? FarmerDesign.successLight
                  : FarmerDesign.warningLight,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: verified
                        ? FarmerDesign.success
                        : FarmerDesign.warning,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    verified ? Icons.check_rounded : Icons.schedule_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(paymentMethod, style: FarmerDesign.bodyMedium),

                      const SizedBox(height: 3),

                      Text(
                        verified ? 'Payment verified' : 'Payment pending',
                        style: FarmerDesign.caption.copyWith(
                          color: verified
                              ? FarmerDesign.success
                              : FarmerDesign.warning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (!verified) ...[
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The farmer can mark the payment as received after confirming the customer payment.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: FarmerDesign.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // TIMELINE
  // ============================================================

  Widget _buildStatusTimeline(OrderModel order) {
    const statuses = [
      'pending',
      'confirmed',
      'packed',
      'dispatched',
      'out_for_delivery',
      'delivered',
      'completed',
    ];

    final currentStage = order.fulfillmentStage;

    return _SectionCard(
      title: 'Order Progress',
      icon: Icons.timeline_rounded,
      child: Column(
        children: [
          for (int i = 0; i < statuses.length; i++)
            _TimelineItem(
              title: _displayStatus(statuses[i]),
              active: currentStage >= i,
              current: order.status == statuses[i],
              last: i == statuses.length - 1,
            ),

          if (order.isCancelled)
            const _TimelineItem(
              title: 'Cancelled',
              active: true,
              current: true,
              last: true,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION SECTION
  // ============================================================

  Widget _buildActionSection(OrderModel order) {
    if (order.isCancelled) {
      return const _InfoBanner(
        icon: Icons.cancel_outlined,
        color: FarmerDesign.error,
        background: FarmerDesign.errorLight,
        message: 'This order has been cancelled.',
      );
    }

    if (order.isCompleted) {
      return const _InfoBanner(
        icon: Icons.check_circle_outline_rounded,
        color: FarmerDesign.success,
        background: FarmerDesign.successLight,
        message: 'This order has been completed.',
      );
    }

    return Column(
      children: [
        _buildMainAction(order),

        if (!order.paymentVerified) ...[
          const SizedBox(height: 10),
          _buildPaymentAction(order),
        ],
      ],
    );
  }

  // ============================================================
  // MAIN ORDER ACTION
  // ============================================================

  Widget _buildMainAction(OrderModel order) {
    String? label;
    String? nextStatus;
    bool confirm = false;

    switch (order.status) {
      case 'pending':
        label = 'Confirm Order';
        confirm = true;
        break;

      case 'confirmed':
        label = 'Pack Order';
        nextStatus = 'packed';
        break;

      case 'packed':
        label = 'Dispatch Order';
        nextStatus = 'dispatched';
        break;

      case 'dispatched':
        label = 'Mark Out for Delivery';
        nextStatus = 'out_for_delivery';
        break;

      case 'out_for_delivery':
        label = 'Mark Delivered';
        nextStatus = 'delivered';
        break;

      case 'delivered':
        label = 'Complete Order';
        nextStatus = 'completed';
        break;

      default:
        return const SizedBox.shrink();
    }

    return Obx(() {
      final updating = controller.isUpdating.value;

      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: updating
              ? null
              : () async {
                  bool success;

                  if (confirm) {
                    success = await controller.confirmOrder(order.orderId);
                  } else {
                    success = await controller.updateOrderStatus(
                      order.orderId,
                      nextStatus!,
                    );
                  }

                  if (!mounted) {
                    return;
                  }

                  if (success) {
                    Get.snackbar(
                      'Order Updated',
                      'Order status changed successfully.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: FarmerDesign.primary,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                    );
                  } else {
                    Get.snackbar(
                      'Update Failed',
                      controller.errorMessage.value.isEmpty
                          ? 'Could not update the order.'
                          : controller.errorMessage.value,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: FarmerDesign.error,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                    );
                  }
                },
          icon: updating
              ? const SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  confirm ? Icons.check_rounded : Icons.arrow_forward_rounded,
                ),
          label: Text(updating ? 'Updating...' : (label ?? 'Update Order')),
          style: ElevatedButton.styleFrom(
            backgroundColor: FarmerDesign.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      );
    });
  }

  // ============================================================
  // PAYMENT ACTION
  // ============================================================

  Widget _buildPaymentAction(OrderModel order) {
    return Obx(() {
      final updating = controller.isUpdating.value;

      return SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: updating
              ? null
              : () async {
                  final success = await controller.markPaymentPaid(
                    order.orderId,
                  );

                  if (!mounted) {
                    return;
                  }

                  if (success) {
                    Get.snackbar(
                      'Payment Updated',
                      'Payment has been marked as paid.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: FarmerDesign.success,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                    );
                  } else {
                    Get.snackbar(
                      'Payment Update Failed',
                      controller.errorMessage.value.isEmpty
                          ? 'Could not update payment.'
                          : controller.errorMessage.value,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: FarmerDesign.error,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                    );
                  }
                },
          icon: updating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_circle_outline_rounded),
          label: Text(updating ? 'Updating...' : 'Mark Payment as Paid'),
          style: OutlinedButton.styleFrom(
            foregroundColor: FarmerDesign.primary,
            side: const BorderSide(color: FarmerDesign.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      );
    });
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: FarmerDesign.errorLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 38,
                color: FarmerDesign.error,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Could not load order',
              style: FarmerDesign.heading3,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Obx(
              () => Text(
                controller.errorMessage.value.isEmpty
                    ? 'Order information could not be loaded.'
                    : controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: FarmerDesign.bodySmall,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                controller.loadOrderDetail(widget.orderId);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FarmerDesign.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _safeValue(String value, String fallback) {
    final cleaned = value.trim();

    return cleaned.isEmpty ? fallback : cleaned;
  }

  String _displayStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';

      case 'confirmed':
        return 'Confirmed';

      case 'packed':
        return 'Packed';

      case 'dispatched':
        return 'Dispatched';

      case 'out_for_delivery':
        return 'Out for Delivery';

      case 'delivered':
        return 'Delivered';

      case 'completed':
        return 'Completed';

      case 'cancelled':
      case 'canceled':
        return 'Cancelled';

      default:
        return status;
    }
  }
}

// ================================================================
// SECTION CARD
// ================================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: FarmerDesign.cardDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: FarmerDesign.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 19, color: FarmerDesign.primary),
              ),

              const SizedBox(width: 9),

              Text(title, style: FarmerDesign.heading4),
            ],
          ),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }
}

// ================================================================
// INFO ROW
// ================================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: FarmerDesign.primaryLight,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: FarmerDesign.primaryDark),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: FarmerDesign.caption),

              const SizedBox(height: 3),

              Text(value, style: FarmerDesign.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

// ================================================================
// ITEM ROW
// ================================================================

class _ItemRow extends StatelessWidget {
  final OrderItemModel item;

  const _ItemRow({required this.item});

  String _formatRiel(double amount) {
    final value = amount.round().toString();

    final formatted = value.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return '៛$formatted';
  }

  @override
  Widget build(BuildContext context) {
    final quantity = item.quantity;

    final lineTotal = item.price * quantity;

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: FarmerDesign.leafLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.eco_rounded,
            color: FarmerDesign.leaf,
            size: 25,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FarmerDesign.bodyMedium,
              ),

              const SizedBox(height: 4),

              Text(
                'Qty ${item.displayQuantity} × ${_formatRiel(item.price)}',
                style: FarmerDesign.caption,
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Text(
          _formatRiel(lineTotal),
          style: FarmerDesign.bodyMedium.copyWith(
            color: FarmerDesign.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// SUMMARY ROW
// ================================================================

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: bold ? FarmerDesign.bodyMedium : FarmerDesign.body),

        const Spacer(),

        Text(
          value,
          style: bold
              ? FarmerDesign.heading3.copyWith(color: FarmerDesign.primaryDark)
              : FarmerDesign.bodyMedium,
        ),
      ],
    );
  }
}

// ================================================================
// STATUS BADGE
// ================================================================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _displayStatus(normalized),
        style: const TextStyle(
          color: FarmerDesign.primaryDark,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _displayStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';

      case 'confirmed':
        return 'Confirmed';

      case 'packed':
        return 'Packed';

      case 'dispatched':
        return 'Dispatched';

      case 'out_for_delivery':
        return 'Out for Delivery';

      case 'delivered':
        return 'Delivered';

      case 'completed':
        return 'Completed';

      case 'cancelled':
      case 'canceled':
        return 'Cancelled';

      default:
        return status;
    }
  }
}

// ================================================================
// TIMELINE
// ================================================================

class _TimelineItem extends StatelessWidget {
  final String title;
  final bool active;
  final bool current;
  final bool last;

  const _TimelineItem({
    required this.title,
    required this.active,
    required this.current,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 21,
                height: 21,
                decoration: BoxDecoration(
                  color: active ? FarmerDesign.primary : FarmerDesign.border,
                  shape: BoxShape.circle,
                  boxShadow: current ? FarmerDesign.cardShadow : null,
                ),
                child: active
                    ? const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Colors.white,
                      )
                    : null,
              ),

              if (!last)
                Container(
                  width: 2,
                  height: 28,
                  color: active ? FarmerDesign.primary : FarmerDesign.border,
                ),
            ],
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Text(
              title,
              style: TextStyle(
                color: active
                    ? FarmerDesign.primaryDark
                    : FarmerDesign.mutedText,
                fontSize: 14,
                fontWeight: current ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// INFO BANNER
// ================================================================

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String message;

  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.background,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),

          const SizedBox(width: 10),

          Expanded(child: Text(message, style: FarmerDesign.bodyMedium)),
        ],
      ),
    );
  }
}
