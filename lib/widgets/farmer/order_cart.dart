import 'package:flutter/material.dart';
import 'package:phum_kasikors/model/farmer/order_model.dart';

class FarmerOrderCard extends StatelessWidget {
  const FarmerOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(
          order.customerName,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${order.orderId} • ${order.items.length} items • ${order.status}',
        ),
        trailing: Text(
          '\$${order.total.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}