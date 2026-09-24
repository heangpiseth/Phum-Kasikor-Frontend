class FarmerVerificationModel {
  const FarmerVerificationModel({
    required this.id,
    required this.userId,
    required this.idNumber,
    required this.fullName,
    required this.status,
    this.frontImagePath,
    this.backImagePath,
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
  });

  final String id;
  final String userId;
  final String idNumber;
  final String fullName;
  final String status;

  final String? frontImagePath;
  final String? backImagePath;
  final String? rejectionReason;

  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  bool get isPending => status == 'pending';

  bool get isApproved => status == 'approved';

  bool get isRejected => status == 'rejected';

  factory FarmerVerificationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FarmerVerificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      idNumber: json['id_number']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      frontImagePath: json['front_image_path']?.toString(),
      backImagePath: json['back_image_path']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      submittedAt: _parseDate(json['submitted_at']),
      reviewedAt: _parseDate(json['reviewed_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'id_number': idNumber,
      'full_name': fullName,
      'status': status,
      'front_image_path': frontImagePath,
      'back_image_path': backImagePath,
      'rejection_reason': rejectionReason,
      'submitted_at': submittedAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}