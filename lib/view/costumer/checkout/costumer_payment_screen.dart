import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/costumer/costumer_payment_controller.dart';

class CostumerPaymentScreen extends GetView<PaymentController> {
  const CostumerPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = controller.order;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(),
        title: const Text(
          'Direct Payment',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            120,
          ),
          children: [
            // ======================================================
            // PAYMENT STATUS CARD
            // ======================================================

            _paymentStatusCard(),

            const SizedBox(height: 18),

            // ======================================================
            // PAYMENT DETAILS
            // ======================================================

            _sectionTitle('Payment Details'),

            const SizedBox(height: 10),

            _detailsCard(
              order: order,
            ),

            const SizedBox(height: 18),

            // ======================================================
            // PAYMENT QR
            // ======================================================

            _sectionTitle('Scan to Pay'),

            const SizedBox(height: 10),

            _qrCard(),

            const SizedBox(height: 18),

            // ======================================================
            // BANK TRANSFER
            // ======================================================

            _bankTransferCard(),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // ==========================================================
      // PAYMENT ACTIONS
      // ==========================================================

      bottomNavigationBar: _paymentActions(),
    );
  }

  // ==============================================================
  // PAYMENT STATUS
  // ==============================================================

  Widget _paymentStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Direct Farm Payment',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Pay the farmer directly. No escrow or platform fee.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // PAYMENT DETAILS CARD
  // ==============================================================

  Widget _detailsCard({
    required dynamic order,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _row(
            'Farmer',
            order.farmerName,
          ),

          const Divider(height: 20),

          _row(
            'Farm',
            order.farmName,
          ),

          const Divider(height: 20),

          _row(
            'Payment Reference',
            '#${order.id}',
            valueColor: AppColors.accentOrange,
          ),

          const Divider(height: 20),

          _row(
            'Amount Due',
            '\$${order.total.toStringAsFixed(2)}',
            valueColor: AppColors.primary,
            valueBold: true,
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // QR CARD
  // ==============================================================

  Widget _qrCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // QR container
          Container(
            width: 190,
            height: 190,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.divider,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code_2_rounded,
                  color: Colors.white,
                  size: 125,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Scan the farmer\'s payment QR',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Use your banking app to complete the payment.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          // Payment timer
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${controller.formattedTime} left',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  // ==============================================================
  // BANK TRANSFER
  // ==============================================================

  Widget _bankTransferCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_outlined,
                  color: AppColors.primary,
                  size: 19,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'Bank Transfer',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _bankRow(
            'ABA Account',
            '000 123 456',
          ),

          const SizedBox(height: 8),

          _bankRow(
            'Account Name',
            'Sokha Vann',
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Include your payment reference when making a bank transfer.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // BANK ROW
  // ==============================================================

  Widget _bankRow(
    String label,
    String value,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // PAYMENT ACTIONS
  // ==============================================================

  Widget _paymentActions() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed:
                    controller.confirmPaymentCompleted,
                icon: const Icon(
                  Icons.check_circle_outline,
                  size: 19,
                ),
                label: const Text(
                  'I\'ve Completed Payment',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 2),

            TextButton(
              onPressed: controller.cancelOrder,
              child: const Text(
                'Cancel Order',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // SECTION TITLE
  // ==============================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }

  // ==============================================================
  // DETAIL ROW
  // ==============================================================

  Widget _row(
    String label,
    String value, {
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.end,
            softWrap: true,
            style: TextStyle(
              color:
                  valueColor ?? AppColors.textPrimary,
              fontWeight:
                  valueBold
                      ? FontWeight.w800
                      : FontWeight.w600,
              fontSize:
                  valueBold ? 18 : 13,
            ),
          ),
        ),
      ],
    );
  }
}