import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/view/ai_assistant/ai_assistant_chat_screen.dart';

class AiAssistantFloatingButton extends StatelessWidget {
  const AiAssistantFloatingButton({super.key, required this.isFarmer});

  final bool isFarmer;

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
        heroTag: 'ai-assistant-${isFarmer ? 'farmer' : 'customer'}',
        onPressed: () => Get.to(() => AiAssistantChatScreen(isFarmer: isFarmer)),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('AI Assistant'),
      );
}
