import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:phum_kasikors/core/constants/app_constants.dart';
import 'package:phum_kasikors/core/stroage/token_stroage.dart';
import 'package:phum_kasikors/model/customer/costumer_order_model.dart';

class CustomerCheckoutService {
  // ============================================================
  // HEADERS
  // ============================================================

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // CREATE ORDER
  // ============================================================

  Future<OrderCreateResponse> createOrder({
    required List<OrderItem> items,
    required String deliveryAddress,
    required DeliveryMethod deliveryMethod,
    required PaymentMethod paymentMethod,
    required double deliveryFee,
    String? note,
  }) async {
    final body = {
      'delivery_address': deliveryAddress,
      'delivery_method': deliveryMethod.apiValue,
      'payment_method': paymentMethod.apiValue,

      // Laravel calculates the real delivery fee.
      // Kept here only for compatibility with the Flutter flow.
      'delivery_fee': deliveryFee,

      if (note != null && note.trim().isNotEmpty)
        'notes': note.trim(),
    };

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/customer/orders',
    );

    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(body),
    );

    return _handleOrderCreateResponse(response);
  }

  // ============================================================
  // HANDLE RESPONSE
  // ============================================================

  OrderCreateResponse _handleOrderCreateResponse(
    http.Response response,
  ) {
    Map<String, dynamic>? json;

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        json = decoded;
      }
    } catch (_) {
      // Response was not valid JSON.
    }

    // ----------------------------------------------------------
    // SUCCESS
    // ----------------------------------------------------------

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      if (json == null) {
        throw Exception(
          'Server returned an invalid order response.',
        );
      }

      return OrderCreateResponse.fromJson(json);
    }

    // ----------------------------------------------------------
    // ERROR
    // ----------------------------------------------------------

    if (json != null) {
      final message = json['message'];

      if (message != null &&
          message.toString().trim().isNotEmpty) {
        throw Exception(
          '$message (${response.statusCode})',
        );
      }

      // Laravel validation errors
      final errors = json['errors'];

      if (errors is Map) {
        final messages = <String>[];

        errors.forEach((key, value) {
          if (value is List) {
            messages.addAll(
              value.map((e) => e.toString()),
            );
          } else {
            messages.add(value.toString());
          }
        });

        if (messages.isNotEmpty) {
          throw Exception(
            '${messages.join('\n')} (${response.statusCode})',
          );
        }
      }
    }

    throw Exception(
      'Failed to create order: '
      '${response.statusCode} - ${response.body}',
    );
  }
}

// ============================================================
// ORDER CREATE RESPONSE
// ============================================================

class OrderCreateResponse {
  final OrderModel order;
  final String? paymentUrl;
  final String? message;

  OrderCreateResponse({
    required this.order,
    this.paymentUrl,
    this.message,
  });

  factory OrderCreateResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final orderJson =
        json['order'] ??
        json['data'];

    if (orderJson is! Map<String, dynamic>) {
      throw Exception(
        'Order was created, but the server returned no order data.',
      );
    }

    return OrderCreateResponse(
      order: OrderModel.fromJson(orderJson),
      paymentUrl:
          json['payment_url'] ??
          json['paymentUrl'],
      message: json['message']?.toString(),
    );
  }
}