class CropModel {
  const CropModel({
    required this.id,
    required this.farmId,
    required this.name,
    required this.plantedAt,
    this.expectedHarvestAt,
    this.status = 'Growing',
    this.imageUrl,
  });
  final String id, farmId, name, status;
  final DateTime plantedAt;
  final DateTime? expectedHarvestAt;
  final String? imageUrl;
  factory CropModel.fromJson(Map<String, dynamic> json) => CropModel(
    id: json['id'] as String,
    farmId: json['farmId'] as String,
    name: json['name'] as String,
    plantedAt: DateTime.parse(json['plantedAt'] as String),
    expectedHarvestAt: json['expectedHarvestAt'] == null
        ? null
        : DateTime.parse(json['expectedHarvestAt'] as String),
    status: json['status'] as String? ?? 'Growing',
    imageUrl: json['imageUrl'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'farmId': farmId,
    'name': name,
    'plantedAt': plantedAt.toIso8601String(),
    'expectedHarvestAt': expectedHarvestAt?.toIso8601String(),
    'status': status,
    'imageUrl': imageUrl,
  };
}