import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:phum_kasikors/core/constants/app_constants.dart';
import 'package:phum_kasikors/core/stroage/token_stroage.dart';

class CustomerCartService {
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
  // GET CART
  // ============================================================

  Future<Map<String, dynamic>> getCart() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/customer/cart',
    );

    final response = await http.get(
      uri,
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  // ============================================================
  // ADD ITEM
  // ============================================================

  Future<Map<String, dynamic>> addItem({
    required int productId,
    required int quantity,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/customer/cart/items',
    );

    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        'product_id': productId,
        'quantity': quantity,
      }),
    );

    return _handleResponse(response);
  }

  // ============================================================
  // UPDATE ITEM
  // ============================================================

  Future<Map<String, dynamic>> updateItem({
    required int cartItemId,
    required int quantity,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/customer/cart/items/$cartItemId',
    );

    final response = await http.put(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        'quantity': quantity,
      }),
    );

    return _handleResponse(response);
  }

  // ============================================================
  // REMOVE ITEM
  // ============================================================

  Future<void> removeItem(int cartItemId) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/customer/cart/items/$cartItemId',
    );

    final response = await http.delete(
      uri,
      headers: await _headers(),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      _handleResponse(response);
    }
  }

  // ============================================================
  // CLEAR CART
  // ============================================================

  Future<void> clearCart() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/customer/cart',
    );

    final response = await http.delete(
      uri,
      headers: await _headers(),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      _handleResponse(response);
    }
  }

  // ============================================================
  // RESPONSE HANDLER
  // ============================================================

  Map<String, dynamic> _handleResponse(
    http.Response response,
  ) {
    Map<String, dynamic> json = {};

    if (response.body.isNotEmpty) {
      try {
        json = jsonDecode(response.body)
            as Map<String, dynamic>;
      } catch (_) {
        throw Exception(
          'Invalid server response.',
        );
      }
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return json;
    }

    final message =
        json['message'] ??
        'Cart request failed.';

    throw Exception(
      '$message (${response.statusCode})',
    );
  }
}