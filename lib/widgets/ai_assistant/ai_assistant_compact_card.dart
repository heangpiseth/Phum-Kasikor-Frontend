import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/view/ai_assistant/ai_assistant_chat_screen.dart';

class AiAssistantCompactCard extends StatelessWidget {
  const AiAssistantCompactCard({super.key, required this.isFarmer});

  final bool isFarmer;

  @override
  Widget build(BuildContext context) {
    final title = isFarmer ? 'Farm AI Assistant' : 'Fresh help, anytime';
    final subtitle = isFarmer
        ? 'Get help with crops, orders, and planning.'
        : 'Ask about farms, produce, or your orders.';

    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(() => AiAssistantChatScreen(isFarmer: isFarmer)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
