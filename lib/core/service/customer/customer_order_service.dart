import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:phum_kasikors/core/constants/app_constants.dart';
import 'package:phum_kasikors/core/stroage/token_stroage.dart';
import 'package:phum_kasikors/model/customer/costumer_order_model.dart';

class CustomerOrderService {
  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<OrderResponse> getCustomerOrders({int page = 1}) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/customer/orders?page=$page',
    );
    final response = await http.get(uri, headers: await _headers());
    return _handleOrderResponse(response);
  }

  Future<OrderDetailResponse> getOrderDetail(String orderId) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/customer/orders/$orderId',
    );
    final response = await http.get(uri, headers: await _headers());
    return _handleOrderDetailResponse(response);
  }

  OrderResponse _handleOrderResponse(http.Response response) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return OrderResponse.fromJson(json);
    }
    throw Exception('Failed to load orders: ${response.statusCode}');
  }

  OrderDetailResponse _handleOrderDetailResponse(http.Response response) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return OrderDetailResponse.fromJson(json);
    }
    throw Exception('Failed to load order detail: ${response.statusCode}');
  }
}

class OrderResponse {
  final int currentPage;
  final List<OrderModel> data;
  final String? firstPageUrl;
  final int from;
  final int lastPage;
  final String? lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  OrderResponse({
    required this.currentPage,
    required this.data,
    this.firstPageUrl,
    required this.from,
    required this.lastPage,
    this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List? ?? [])
          .map((e) => OrderModel.fromJson(e))
          .toList(),
      firstPageUrl: json['first_page_url'],
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'],
      links: (json['links'] as List? ?? [])
          .map((e) => PaginationLink.fromJson(e))
          .toList(),
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 20,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class OrderDetailResponse {
  final OrderModel order;

  OrderDetailResponse({required this.order});

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      order: OrderModel.fromJson(json['order'] ?? json['data'] ?? {}),
    );
  }
}

class PaginationLink {
  final String? url;
  final String label;
  final int? page;
  final bool active;

  PaginationLink({
    this.url,
    required this.label,
    this.page,
    required this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'],
      label: json['label'] ?? '',
      page: json['page'],
      active: json['active'] ?? false,
    );
  }
}