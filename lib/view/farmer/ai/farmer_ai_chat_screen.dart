import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/controller/farmer/farmer_ai_chat_controller.dart';
import 'package:phum_kasikors/model/farmer/farmer_ai_message_model.dart';

class FarmerAiChatScreen extends StatelessWidget {
  FarmerAiChatScreen({super.key});

  final FarmerAiChatController controller =
      Get.put(
    FarmerAiChatController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,

        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFF2E7D32),
              ),
            ),

            const SizedBox(width: 12),

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phum Kasikor AI',
                  style: TextStyle(
                    color: Color(0xFF1B1B1B),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  'Agriculture Assistant',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Clear chat',
            onPressed: controller.clearChat,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ====================================================
          // CHAT MESSAGES
          // ====================================================

          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: controller.scrollController,

                padding: const EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  16,
                ),

                itemCount:
                    controller.messages.length +
                        (controller.isLoading.value
                            ? 1
                            : 0),

                itemBuilder: (context, index) {
                  // ------------------------------------------
                  // TYPING INDICATOR
                  // ------------------------------------------

                  if (
                    controller.isLoading.value &&
                    index == controller.messages.length
                  ) {
                    return const _TypingBubble();
                  }

                  // ------------------------------------------
                  // MESSAGE
                  // ------------------------------------------

                  final message =
                      controller.messages[index];

                  return _MessageBubble(
                    message: message,
                  );
                },
              ),
            ),
          ),

          // ====================================================
          // ERROR
          // ====================================================

          Obx(
            () {
              final error =
                  controller.errorMessage.value;

              if (error.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  8,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Text(
                  error,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),

          // ====================================================
          // INPUT
          // ====================================================

          _ChatInput(
            controller: controller,
          ),
        ],
      ),
    );
  }
}

// =================================================================
// MESSAGE BUBBLE
// =================================================================

class _MessageBubble extends StatelessWidget {
  final FarmerAiMessage message;

  const _MessageBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,

      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 330,
        ),

        margin: const EdgeInsets.only(
          bottom: 12,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF2E7D32)
              : Colors.white,

          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(
              isUser ? 18 : 4,
            ),
            bottomRight: Radius.circular(
              isUser ? 4 : 18,
            ),
          ),

          boxShadow: isUser
              ? null
              : [
                  BoxShadow(
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    color: Colors.black.withOpacity(0.04),
                  ),
                ],
        ),

        // ======================================================
        // USER MESSAGE
        // ======================================================

        child: isUser
            ? Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.45,
                ),
              )

            // ==================================================
            // AI MESSAGE
            // ==================================================

            : MarkdownBody(
                data: message.text,

                selectable: true,

                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 14,
                    height: 1.5,
                  ),

                  strong: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),

                  em: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),

                  h1: const TextStyle(
                    color: Color(0xFF1B1B1B),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),

                  h2: const TextStyle(
                    color: Color(0xFF1B1B1B),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),

                  h3: const TextStyle(
                    color: Color(0xFF1B1B1B),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),

                  listBullet: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 14,
                    height: 1.5,
                  ),

                  listIndent: 18,

                  blockSpacing: 8,

                  listBulletPadding:
                      const EdgeInsets.only(
                    right: 6,
                  ),
                ),
              ),
      ),
    );
  }
}

// =================================================================
// TYPING BUBBLE
// =================================================================

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,

      child: Container(
        margin: const EdgeInsets.only(
          bottom: 12,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),

        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF2E7D32),
              ),
            ),

            SizedBox(width: 10),

            Text(
              'Thinking...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// INPUT AREA
// =================================================================

class _ChatInput extends StatelessWidget {
  final FarmerAiChatController controller;

  const _ChatInput({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,

      child: Container(
        padding: const EdgeInsets.fromLTRB(
          12,
          10,
          12,
          12,
        ),

        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFEAEAEA),
            ),
          ),
        ),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,

          children: [
            // ==================================================
            // TEXT FIELD
            // ==================================================

            Expanded(
              child: TextField(
                controller:
                    controller.messageController,

                minLines: 1,
                maxLines: 4,

                textInputAction:
                    TextInputAction.newline,

                decoration: InputDecoration(
                  hintText:
                      'Ask about your crops...',

                  filled: true,

                  fillColor:
                      const Color(0xFFF5F6F2),

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),

                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // ==================================================
            // SEND BUTTON
            // ==================================================

            Obx(
              () => Container(
                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  color:
                      controller.isLoading.value
                          ? Colors.grey
                          : const Color(0xFF2E7D32),

                  shape: BoxShape.circle,
                ),

                child: IconButton(
                  onPressed:
                      controller.isLoading.value
                          ? null
                          : controller.sendMessage,

                  icon: const Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}