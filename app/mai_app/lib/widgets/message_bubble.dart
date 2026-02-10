// lib/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import '../theme/mai_theme.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? timestamp;

  const MessageBubble({
    super.key,
    required this.message,
    this.isUser = false,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor:
                isUser ? ClaudeColors.accentBlue : ClaudeColors.accentPurple,
            radius: 16,
            child: Icon(
              isUser ? Icons.person : Icons.auto_awesome,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'Вы' : 'МАИ',
                  style: const TextStyle(
                    color: ClaudeColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser
                        ? ClaudeColors.userMessageBg
                        : ClaudeColors.aiMessageBg,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: ClaudeColors.borderColor, width: 0.5),
                  ),
                  child: SelectableText(
                    message,
                    style: TextStyle(
                      color: ClaudeColors.textPrimary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
                if (timestamp != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    timestamp!,
                    style: const TextStyle(
                      color: ClaudeColors.textHint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
