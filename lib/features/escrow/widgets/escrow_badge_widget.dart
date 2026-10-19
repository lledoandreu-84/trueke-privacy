import 'package:flutter/material.dart';

class EscrowBadgeWidget extends StatelessWidget {
  final String statusText;
  final bool isSecure;

  const EscrowBadgeWidget({
    super.key,
    required this.statusText,
    this.isSecure = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = isSecure
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.errorContainer;

    final foregroundColor = isSecure
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onErrorContainer;

    final iconData = isSecure ? Icons.verified_rounded : Icons.warning_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 16,
            color: foregroundColor,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
