import 'package:get/get.dart';
import 'package:phum_kasikors/model/ai_assistant_message_model.dart';

/// Local conversation state for the customer and farmer assistant.
/// Replace [_replyFor] with an API call when an AI backend is available.
class AiAssistantController extends GetxController {
  final _customerMessages = <AiAssistantMessage>[].obs;
  final _farmerMessages = <AiAssistantMessage>[].obs;
  final isTyping = false.obs;

  RxList<AiAssistantMessage> messagesFor({required bool isFarmer}) =>
      isFarmer ? _farmerMessages : _customerMessages;

  void ensureWelcome({required bool isFarmer}) {
    final messages = messagesFor(isFarmer: isFarmer);
    if (messages.isNotEmpty) return;

    messages.add(_assistantMessage(
      isFarmer
          ? 'Hi! I can help with crops, orders, inventory, and farm tasks. What would you like to work on?'
          : 'Hi! I can help you find fresh produce, farms, and answer questions about your orders.',
    ));
  }

  Future<void> sendMessage(String text, {required bool isFarmer}) async {
    final value = text.trim();
    if (value.isEmpty || isTyping.value) return;

    final messages = messagesFor(isFarmer: isFarmer);
    messages.add(AiAssistantMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: value,
      sender: AiMessageSender.user,
      createdAt: DateTime.now(),
    ));
    isTyping.value = true;

    await Future<void>.delayed(const Duration(milliseconds: 650));
    messages.add(_assistantMessage(_replyFor(value, isFarmer: isFarmer)));
    isTyping.value = false;
  }

  void clearConversation({required bool isFarmer}) {
    messagesFor(isFarmer: isFarmer).clear();
    ensureWelcome(isFarmer: isFarmer);
  }

  AiAssistantMessage _assistantMessage(String text) => AiAssistantMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: text,
        sender: AiMessageSender.assistant,
        createdAt: DateTime.now(),
      );

  String _replyFor(String prompt, {required bool isFarmer}) {
    final question = prompt.toLowerCase();
    if (isFarmer && (question.contains('crop') || question.contains('water'))) {
      return 'For healthier crops, check soil moisture before watering, water early in the day, and inspect leaves for pests.';
    }
    if (isFarmer && question.contains('order')) {
      return 'Open Orders to review new requests, update their status, and keep customers informed about fulfilment.';
    }
    if (!isFarmer && question.contains('order')) {
      return 'You can review the latest delivery status from the Orders tab. I can also help explain each order status.';
    }
    if (!isFarmer && (question.contains('product') || question.contains('farm'))) {
      return 'Try Explore to browse nearby farms and produce. You can filter by category to find what you need faster.';
    }
    return isFarmer
        ? 'I can help you plan farm work, manage products, and respond to orders. Tell me a little more about your task.'
        : 'I can help you discover farms, choose produce, and understand your orders. What would you like to know?';
  }
}
