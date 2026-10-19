import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final String rawText = message.message;

    if (rawText.startsWith('[IMAGE]:')) {
      final imageUrl = rawText.substring('[IMAGE]:'.length);
      return _buildImageBubble(context, imageUrl);
    }

    final isSystemMessage =
        rawText.startsWith('🚨') ||
        rawText.startsWith('⚖️') ||
        rawText.startsWith('🤝') ||
        rawText.startsWith('📦');
    if (isSystemMessage) {
      return _buildSystemBubble(context);
    }

    return _buildStandardBubble(context);
  }

  Widget _buildStandardBubble(BuildContext context) {
    final theme = Theme.of(context);
    final bubbleColor = isMe
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isMe
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
    final timeColor = isMe
        ? theme.colorScheme.onPrimary.withAlpha(180)
        : theme.colorScheme.onSurfaceVariant.withAlpha(180);
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(isMe ? 20 : 6),
      bottomRight: Radius.circular(isMe ? 6 : 20),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: borderRadius,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.5,
                    height: 1.35,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(message.createdAt),
                      style: TextStyle(
                        color: timeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      _buildStatusIcon(context, timeColor),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBubble(BuildContext context, String url) {
    final theme = Theme.of(context);
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final timeColor = theme.colorScheme.onSurfaceVariant.withAlpha(180);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 140,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(120),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('HH:mm').format(message.createdAt),
                style: TextStyle(
                  color: timeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                _buildStatusIcon(context, timeColor),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemBubble(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: Text(
          message.message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, Color iconColor) {
    final theme = Theme.of(context);
    if (message.isRead) {
      return Icon(
        Icons.done_all_rounded,
        size: 13,
        color: theme.colorScheme.primary,
      );
    } else if (message.isDelivered) {
      return Icon(Icons.done_all_rounded, size: 13, color: iconColor);
    } else {
      return Icon(Icons.done_rounded, size: 13, color: iconColor);
    }
  }
}
