enum AiMessageSender { user, assistant }

class AiAssistantMessage {
  const AiAssistantMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.createdAt,
  });

  final String id;
  final String text;
  final AiMessageSender sender;
  final DateTime createdAt;
}
