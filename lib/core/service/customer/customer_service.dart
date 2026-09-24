import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:phum_kasikors/core/constants/app_constants.dart';
import 'package:phum_kasikors/core/stroage/token_stroage.dart';
import 'package:phum_kasikors/model/customer/costumer_product_model.dart';
import 'package:phum_kasikors/model/customer/costumer_review_model.dart';

class CustomerService {
  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<ProductResponse> getCustomerProducts({
    int page = 1,
    String? search,
    int? farmId,
  }) async {
    final queryParams = <String, String>{'page': page.toString()};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (farmId != null) {
      queryParams['farm_id'] = farmId.toString();
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.customerProducts}',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await _headers());
    return _handleProductResponse(response);
  }

  Future<List<ReviewModel>> getProductReviews(int productId) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.customerProducts}/$productId/reviews',
    );
    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Failed to load reviews: ${response.statusCode}');
    }

    final dynamic decoded = jsonDecode(response.body);
    final dynamic data = decoded is List
        ? decoded
        : decoded['data'] ?? decoded['reviews'] ?? <dynamic>[];
    if (data is! List) {
      return const <ReviewModel>[];
    }

    return data
        .whereType<Map<dynamic, dynamic>>()
        .map((item) => ReviewModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<CategoryResponse> getCategories() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.customerProducts}',
    );
    final response = await http.get(uri, headers: await _headers());
    return _handleCategoryResponse(response);
  }

  ProductResponse _handleProductResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('Failed to load products: ${response.statusCode}');
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    return ProductResponse.fromJson(json);
  }

  CategoryResponse _handleCategoryResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }

    final dynamic json = jsonDecode(response.body);
    return CategoryResponse.fromJson(json);
  }
}

class CategoryResponse {
  final List<CategoryModel> categories;

  CategoryResponse({required this.categories});

  factory CategoryResponse.fromJson(dynamic json) {
    final dynamic data = json is List
        ? json
        : json is Map
        ? json['data'] ?? json['categories'] ?? <dynamic>[]
        : <dynamic>[];
    if (data is! List) {
      return CategoryResponse(categories: const <CategoryModel>[]);
    }

    return CategoryResponse(
      categories: data
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }
}
