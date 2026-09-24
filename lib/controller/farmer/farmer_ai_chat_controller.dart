import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/model/farmer/farmer_ai_message_model.dart';

class FarmerAiChatController extends GetxController {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  // ============================================================
  // STATE
  // ============================================================

  final RxList<FarmerAiMessage> messages =
      <FarmerAiMessage>[].obs;

  final RxBool isLoading = false.obs;

  final RxString errorMessage = ''.obs;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    _addWelcomeMessage();
  }

  // ============================================================
  // WELCOME MESSAGE
  // ============================================================

  void _addWelcomeMessage() {
    messages.add(
      FarmerAiMessage(
        text:
            'Hello! I’m Phum Kasikor AI 🌱\n\n'
            'I can help you with:\n'
            '• Crop problems\n'
            '• Plant diseases\n'
            '• Pests\n'
            '• Watering\n'
            '• Fertilizer\n'
            '• Soil\n'
            '• Harvesting\n\n'
            'What would you like help with today?',
        isUser: false,
      ),
    );
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> sendMessage() async {
  final text = messageController.text.trim();

  if (text.isEmpty || isLoading.value) {
    return;
  }

  errorMessage.value = '';

  // Save the current message for the UI.
  messages.add(
    FarmerAiMessage(
      text: text,
      isUser: true,
    ),
  );

  messageController.clear();

  await _scrollToBottom();

  isLoading.value = true;

  try {
    // Build ONLY previous conversation turns.
    //
    // messages:
    // [welcome, old user, old AI, current user]
    //
    // We want:
    // [old user, old AI]
    //
    // The current user message is sent separately.
    final conversationMessages = messages
        .skip(1)
        .toList();

    if (conversationMessages.isNotEmpty) {
      conversationMessages.removeLast();
    }

    final history = conversationMessages
        .map(
          (message) => {
            'role': message.isUser
                ? 'user'
                : 'assistant',
            'text': message.text,
          },
        )
        .toList();

    debugPrint(
      'AI HISTORY: $history',
    );

    debugPrint(
      'AI MESSAGE: $text',
    );

    final response = await ApiClient.post(
      'farmer/ai/chat',
      {
        'message': text,
        'history': history,
      },
    );

    debugPrint(
      'AI RESPONSE: $response',
    );

    if (response is! Map) {
      throw Exception(
        'Invalid AI response.',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message'] ??
            'Unable to get AI response.',
      );
    }

    final reply =
        response['message']?.toString().trim();

    if (reply == null || reply.isEmpty) {
      throw Exception(
        'AI returned an empty response.',
      );
    }

    messages.add(
      FarmerAiMessage(
        text: reply,
        isUser: false,
      ),
    );

    await _scrollToBottom();
  } catch (e) {
    debugPrint(
      'FARMER AI ERROR: $e',
    );

    errorMessage.value = _getErrorMessage(e);

    messages.add(
      FarmerAiMessage(
        text:
            'Sorry, I couldn’t connect to the phum kasikor ai assistant right now.\n\n'
            'Please try again.',
        isUser: false,
      ),
    );

    await _scrollToBottom();
  } finally {
    isLoading.value = false;
  }
}
  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  String _getErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains('401')) {
      return 'Your farmer session has expired. Please log in again.';
    }

    if (message.contains('403')) {
      return 'Only farmer accounts can use the agriculture assistant.';
    }

    if (message.contains('404')) {
      return 'The AI chat endpoint was not found.';
    }

    if (message.contains('422')) {
      return 'Please enter a valid farming question.';
    }

    if (message.contains('503')) {
      return 'The agriculture assistant is temporarily unavailable.';
    }

    return 'Unable to connect to the agriculture assistant.';
  }

  // ============================================================
  // CLEAR CHAT
  // ============================================================

  void clearChat() {
    messages.clear();

    errorMessage.value = '';

    _addWelcomeMessage();
  }

  // ============================================================
  // SCROLL
  // ============================================================

  Future<void> _scrollToBottom() async {
    await Future.delayed(
      const Duration(milliseconds: 100),
    );

    if (!scrollController.hasClients) {
      return;
    }

    await scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration:
          const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();

    super.onClose();
  }
}