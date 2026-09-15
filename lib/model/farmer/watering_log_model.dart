class WateringLogModel {
  final String id;
  final String cropId;
  final String fieldName;
  final DateTime date;
  final double amount; // liters
  final String? notes;

  WateringLogModel({
    required this.id,
    required this.cropId,
    required this.fieldName,
    required this.date,
    required this.amount,
    this.notes,
  });

  WateringLogModel copyWith({
    String? id,
    String? cropId,
    String? fieldName,
    DateTime? date,
    double? amount,
    String? notes,
  }) {
    return WateringLogModel(
      id: id ?? this.id,
      cropId: cropId ?? this.cropId,
      fieldName: fieldName ?? this.fieldName,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'crop_id': cropId,
    'field_name': fieldName,
    'date': date.toIso8601String(),
    'amount': amount,
    'notes': notes,
  };

  factory WateringLogModel.fromJson(Map<String, dynamic> json) => WateringLogModel(
    id: json['id'] as String? ?? '',
    cropId: json['crop_id'] as String? ?? '',
    fieldName: json['field_name'] as String? ?? '',
    date: json['date'] != null ? DateTime.tryParse(json['date'] as String) ?? DateTime.now() : DateTime.now(),
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    notes: json['notes'] as String?,
  );
}