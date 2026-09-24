import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/controller/farmer/order_controller.dart';
import 'package:phum_kasikors/model/farmer/order_model.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';
import 'package:phum_kasikors/view/farmer/orders/farmer_order_detail_screen.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({
    super.key,
  });

  @override
  State<FarmerOrdersScreen> createState() =>
      _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState
    extends State<FarmerOrdersScreen> {
  late final OrderController controller;

  int selectedFilter = 0;

  // ============================================================
  // FILTERS
  // ============================================================

  static const List<String> filters = [
    'All',
    'Pending',
    'Confirmed',
    'Packed',
    'Dispatched',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<OrderController>()) {
      controller = Get.find<OrderController>();
    } else {
      controller = Get.put(OrderController());
    }
  }

  // ============================================================
  // FILTERED ORDERS
  // ============================================================

  List<OrderModel> get filteredOrders {
    final allOrders = controller.orders.toList();

    switch (selectedFilter) {
      case 1:
        return allOrders
            .where(
              (order) => order.status == 'pending',
            )
            .toList();

      case 2:
        return allOrders
            .where(
              (order) => order.status == 'confirmed',
            )
            .toList();

      case 3:
        return allOrders
            .where(
              (order) => order.status == 'packed',
            )
            .toList();

      case 4:
        return allOrders
            .where(
              (order) =>
                  order.status == 'dispatched' ||
                  order.status == 'out_for_delivery',
            )
            .toList();

      case 5:
        return allOrders
            .where(
              (order) =>
                  order.status == 'delivered' ||
                  order.status == 'completed',
            )
            .toList();

      case 6:
        return allOrders
            .where(
              (order) => order.status == 'cancelled',
            )
            .toList();

      default:
        return allOrders;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshOrders() async {
    await controller.refreshOrders();
  }

  // ============================================================
  // OPEN ORDER
  // ============================================================

  void openOrder(OrderModel order) {
    Get.to(
      () => FarmerOrderDetailScreen(
        orderId: order.orderId,
      ),
    );
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
        title: const Text(
          'Orders',
          style: FarmerDesign.heading2,
        ),
        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.isLoading.value
                  ? null
                  : refreshOrders,
              tooltip: 'Refresh orders',
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: FarmerDesign.primary,
                      ),
                    )
                  : const Icon(
                      Icons.refresh_rounded,
                      color: FarmerDesign.primary,
                    ),
            ),
          ),
        ],
      ),
      body: Obx(
        () {
          // ======================================================
          // INITIAL LOADING
          // ======================================================

          if (controller.isLoading.value &&
              controller.orders.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: FarmerDesign.primary,
              ),
            );
          }

          // ======================================================
          // INITIAL ERROR
          // ======================================================

          if (controller.errorMessage.value.isNotEmpty &&
              controller.orders.isEmpty) {
            return _ErrorState(
              message: controller.errorMessage.value,
              onRetry: controller.loadOrders,
            );
          }

          // ======================================================
          // CONTENT
          // ======================================================

          return RefreshIndicator(
            color: FarmerDesign.primary,
            onRefresh: refreshOrders,
            child: CustomScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ==================================================
                // HEADER
                // ==================================================

                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),

                // ==================================================
                // FILTERS
                // ==================================================

                SliverToBoxAdapter(
                  child: _buildFilters(),
                ),

                // ==================================================
                // INLINE ERROR
                // ==================================================

                if (controller
                    .errorMessage
                    .value
                    .isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildInlineError(),
                  ),

                // ==================================================
                // ORDERS
                // ==================================================

                if (filteredOrders.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyOrdersState(
                      filter: filters[selectedFilter],
                    ),
                  )
                else
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      32,
                    ),
                    sliver: SliverList(
                      delegate:
                          SliverChildBuilderDelegate(
                        (context, index) {
                          final order =
                              filteredOrders[index];

                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child: _OrderCard(
                              order: order,
                              onTap: () =>
                                  openOrder(order),
                            ),
                          );
                        },
                        childCount:
                            filteredOrders.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage your orders',
                  style: FarmerDesign.heading2,
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    '${controller.orders.length} total orders',
                    style:
                        FarmerDesign.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: FarmerDesign.primaryLight,
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: FarmerDesign.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (
          context,
          index,
        ) {
          final selected =
              selectedFilter == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = index;
              });
            },
            child: AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 200,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              decoration:
                  BoxDecoration(
                color: selected
                    ? FarmerDesign.primary
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(24),
                border: Border.all(
                  color: selected
                      ? FarmerDesign.primary
                      : FarmerDesign.border,
                ),
              ),
              child: Text(
                filters[index],
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : FarmerDesign.primary,
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // INLINE ERROR
  // ============================================================

  Widget _buildInlineError() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        4,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            Colors.red.withValues(alpha: 0.08),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.errorMessage.value,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            onPressed:
                controller.clearError,
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.red,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ORDER CARD
// ================================================================

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onTap,
  });

  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(18),
        child: Container(
          padding:
              const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: FarmerDesign.border,
            ),
            boxShadow:
                FarmerDesign.cardShadow,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // TOP
              // ==================================================

              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration:
                        BoxDecoration(
                      color:
                          FarmerDesign.primaryLight,
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color:
                          FarmerDesign.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.orderId}',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                FarmerDesign.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _customerName(
                            order,
                          ),
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              FarmerDesign.body,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(
                    status:
                        order.status,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Divider(
                height: 1,
                color:
                    FarmerDesign.border,
              ),

              const SizedBox(height: 14),

              // ==================================================
              // INFO
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon:
                          Icons.inventory_2_outlined,
                      label: 'Items',
                      value:
                          '${order.itemCount}',
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      icon:
                          Icons.payments_outlined,
                      label: 'Total',
                      value:
                          _formatRiel(
                        order.total,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ==================================================
              // PAYMENT
              // ==================================================

              Row(
                children: [
                  Icon(
                    order.paymentVerified
                        ? Icons
                            .check_circle_rounded
                        : Icons
                            .pending_rounded,
                    size: 16,
                    color:
                        order.paymentVerified
                            ? FarmerDesign.primary
                            : Colors.orange.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    order.paymentVerified
                        ? 'Payment received'
                        : 'Payment pending',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          order.paymentVerified
                              ? FarmerDesign.primary
                              : Colors.orange.shade700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    order.paymentMethod
                        .trim()
                        .isEmpty
                        ? 'Payment'
                        : order.paymentMethod,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color:
                          FarmerDesign.secondaryText,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ==================================================
              // VIEW
              // ==================================================

              Row(
                children: [
                  const Spacer(),
                  const Text(
                    'View order',
                    style: TextStyle(
                      color:
                          FarmerDesign.primary,
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color:
                        FarmerDesign.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _customerName(
    OrderModel order,
  ) {
    final name =
        order.customerName.trim();

    if (name.isEmpty) {
      return 'Customer';
    }

    return name;
  }

  String _formatRiel(
    double value,
  ) {
    final rounded =
        value.round().toString();

    final formatted =
        rounded.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return '៛$formatted';
  }
}

// ================================================================
// INFO ITEM
// ================================================================

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration:
              BoxDecoration(
            color:
                FarmerDesign.background,
            borderRadius:
                BorderRadius.circular(
              10,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color:
                FarmerDesign.primary,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    const TextStyle(
                  fontSize: 11,
                  color:
                      FarmerDesign.secondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      FarmerDesign.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ================================================================
// STATUS BADGE
// ================================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(
    BuildContext context,
  ) {
    final normalized =
        status.trim().toLowerCase();

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color:
            _backgroundColor(normalized),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        _displayStatus(normalized),
        style: TextStyle(
          color:
              _foregroundColor(
            normalized,
          ),
          fontSize: 11,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }

  Color _backgroundColor(
    String status,
  ) {
    switch (status) {
      case 'pending':
        return Colors.orange
            .withValues(alpha: 0.12);

      case 'confirmed':
        return Colors.blue
            .withValues(alpha: 0.12);

      case 'packed':
        return Colors.indigo
            .withValues(alpha: 0.12);

      case 'dispatched':
      case 'out_for_delivery':
        return Colors.purple
            .withValues(alpha: 0.12);

      case 'delivered':
      case 'completed':
        return FarmerDesign
            .primaryLight;

      case 'cancelled':
      case 'canceled':
        return Colors.red
            .withValues(alpha: 0.10);

      default:
        return FarmerDesign
            .background;
    }
  }

  Color _foregroundColor(
    String status,
  ) {
    switch (status) {
      case 'pending':
        return Colors.orange.shade800;

      case 'confirmed':
        return Colors.blue.shade700;

      case 'packed':
        return Colors.indigo.shade700;

      case 'dispatched':
      case 'out_for_delivery':
        return Colors.purple.shade700;

      case 'delivered':
      case 'completed':
        return FarmerDesign.primary;

      case 'cancelled':
      case 'canceled':
        return Colors.red.shade700;

      default:
        return FarmerDesign
            .secondaryText;
    }
  }

  String _displayStatus(
    String status,
  ) {
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
// EMPTY STATE
// ================================================================

class _EmptyOrdersState
    extends StatelessWidget {
  const _EmptyOrdersState({
    required this.filter,
  });

  final String filter;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration:
                  const BoxDecoration(
                color:
                    FarmerDesign.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 42,
                color:
                    FarmerDesign.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              filter == 'All'
                  ? 'No orders yet'
                  : 'No $filter orders',
              style:
                  FarmerDesign.heading2,
              textAlign:
                  TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              filter == 'All'
                  ? 'Customer orders will appear here when they purchase your products.'
                  : 'There are currently no orders in this status.',
              style:
                  FarmerDesign.body,
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ERROR STATE
// ================================================================

class _ErrorState
    extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration:
                  BoxDecoration(
                color: Colors.red
                    .withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 34,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Could not load orders',
              style:
                  FarmerDesign.heading2,
              textAlign:
                  TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style:
                  FarmerDesign.bodySmall,
              textAlign:
                  TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Try Again',
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    FarmerDesign.primary,
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}