enum DeliveryStatus {
  pending,
  assigned,
  pickedUp,
  onTheWay,
  delivered,
  cancelled,
}

class DeliveryModel {
  const DeliveryModel({
    required this.id,
    required this.orderId,
    required this.address,
    this.status = DeliveryStatus.pending,
    this.driverName,
    this.driverPhone,
    this.estimatedArrival,
  });
  final String id, orderId, address;
  final DeliveryStatus status;
  final String? driverName, driverPhone;
  final DateTime? estimatedArrival;
  factory DeliveryModel.fromJson(Map<String, dynamic> json) => DeliveryModel(
    id: json['id'] as String,
    orderId: json['orderId'] as String,
    address: json['address'] as String,
    status: DeliveryStatus.values.byName(
      json['status'] as String? ?? 'pending',
    ),
    driverName: json['driverName'] as String?,
    driverPhone: json['driverPhone'] as String?,
    estimatedArrival: json['estimatedArrival'] == null
        ? null
        : DateTime.parse(json['estimatedArrival'] as String),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'address': address,
    'status': status.name,
    'driverName': driverName,
    'driverPhone': driverPhone,
    'estimatedArrival': estimatedArrival?.toIso8601String(),
  };
}