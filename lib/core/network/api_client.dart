import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:phum_kasikors/core/constants/app_constants.dart';
import 'package:phum_kasikors/core/stroage/token_stroage.dart';


import 'api_exception.dart';

class ApiClient {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String path) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/$path'),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> post(
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse(response);
  }

  static Future<dynamic> put(
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse(response);
  }

  static Future<dynamic> delete(String path) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/$path'),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    // No content
    if (response.statusCode == 204) {
      return null;
    }

    dynamic decoded;

    // Decode JSON safely
    try {
      decoded = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : null;
    } catch (_) {
      throw ApiException(
        response.statusCode,
        'The server returned an invalid response.',
      );
    }

    // Success: 200-299
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return decoded;
    }

    String message =
        'Something went wrong (${response.statusCode})';

    Map<String, dynamic>? errors;

    if (decoded is Map) {
      // Laravel normally sends:
      //
      // {
      //   "message": "...",
      //   "errors": {...}
      // }
      //
      // But message might be missing/null.

      if (decoded['message'] != null) {
        message = decoded['message'].toString();
      }

      if (decoded['errors'] is Map) {
        errors = Map<String, dynamic>.from(
          decoded['errors'] as Map,
        );
      }

      // If Laravel only gave us validation errors,
      // show the first validation message.
      if (decoded['message'] == null &&
          errors != null &&
          errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          message = firstError.first.toString();
        } else {
          message = firstError.toString();
        }
      }

      // Some APIs return "error" instead of "message".
      if (decoded['message'] == null &&
          decoded['error'] != null) {
        message = decoded['error'].toString();
      }
    }

    throw ApiException(
      response.statusCode,
      message,
      errors: errors,
    );
  }
}