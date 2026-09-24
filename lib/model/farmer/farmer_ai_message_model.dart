class FarmerAiMessage {
  final String text;
  final bool isUser;
  final DateTime createdAt;

  FarmerAiMessage({
    required this.text,
    required this.isUser,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}