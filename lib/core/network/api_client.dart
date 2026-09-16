import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:phum_kasikors/core/constants/app_constants.dart';
import 'package:phum_kasikors/core/stroage/token_stroage.dart';

import 'api_exception.dart';

class ApiClient {
  // ============================================================
  // HEADERS
  // ============================================================

  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',

      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // GET
  // ============================================================

  static Future<dynamic> get(String path) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}/$path',
      );

      final response = await http.get(
        url,
        headers: await _headers(),
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
        0,
        'Unable to connect to the server. '
        'Please check your internet connection and make sure Laravel is running.',
      );
    }
  }

  // ============================================================
  // POST
  // ============================================================

  static Future<dynamic> post(
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}/$path',
      );

      final response = await http.post(
        url,
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
        0,
        'Unable to connect to the server. '
        'Please check Laravel is running.',
      );
    }
  }

  // ============================================================
  // PUT
  // ============================================================

  static Future<dynamic> put(
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}/$path',
      );

      final response = await http.put(
        url,
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
        0,
        'Unable to connect to the server. '
        'Please check Laravel is running.',
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  static Future<dynamic> delete(String path) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}/$path',
      );

      final response = await http.delete(
        url,
        headers: await _headers(),
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
        0,
        'Unable to connect to the server. '
        'Please check Laravel is running.',
      );
    }
  }

  // ============================================================
  // RESPONSE HANDLER
  // ============================================================

  static dynamic _handleResponse(
    http.Response response,
  ) {
    // ----------------------------------------------------------
    // 204 No Content
    // ----------------------------------------------------------

    if (response.statusCode == 204) {
      return null;
    }

    dynamic decoded;

    // ----------------------------------------------------------
    // Decode JSON
    // ----------------------------------------------------------

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

    // ----------------------------------------------------------
    // SUCCESS: 200 - 299
    // ----------------------------------------------------------

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return decoded;
    }

    // ----------------------------------------------------------
    // DEFAULT ERROR
    // ----------------------------------------------------------

    String message =
        'Something went wrong (${response.statusCode}).';

    Map<String, dynamic>? errors;

    // ----------------------------------------------------------
    // Laravel JSON ERROR
    // ----------------------------------------------------------

    if (decoded is Map) {
      final data = Map<String, dynamic>.from(decoded);

      // Laravel:
      // {
      //   "message": "Unauthenticated."
      // }

      if (data['message'] != null) {
        message = data['message'].toString();
      }

      // Laravel validation:
      //
      // {
      //   "message": "The given data was invalid.",
      //   "errors": {
      //      "phone": [
      //         "The phone field is required."
      //      ]
      //   }
      // }

      if (data['errors'] is Map) {
        errors = Map<String, dynamic>.from(
          data['errors'] as Map,
        );
      }

      // --------------------------------------------------------
      // If message missing, use first validation error
      // --------------------------------------------------------

      if ((data['message'] == null ||
              data['message'].toString().isEmpty) &&
          errors != null &&
          errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List &&
            firstError.isNotEmpty) {
          message = firstError.first.toString();
        } else {
          message = firstError.toString();
        }
      }

      // --------------------------------------------------------
      // Some APIs return "error"
      // --------------------------------------------------------

      if ((data['message'] == null ||
              data['message'].toString().isEmpty) &&
          data['error'] != null) {
        message = data['error'].toString();
      }
    }

    // ----------------------------------------------------------
    // Throw ApiException
    // ----------------------------------------------------------

    throw ApiException(
      response.statusCode,
      message,
      errors: errors,
    );
  }
}