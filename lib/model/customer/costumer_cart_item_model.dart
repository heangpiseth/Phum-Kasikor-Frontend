// cart_item_model.dart

import 'package:phum_kasikors/model/customer/costumer_product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({required this.product, this.quantity = 1});

  double get lineTotal => product.price * quantity;
}