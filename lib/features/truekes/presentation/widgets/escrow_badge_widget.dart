import '../../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/truekes/data/repositories/trueke_repository.dart';
import 'package:trueke/features/truekes/data/models/escrow_model.dart';

class EscrowBadgeWidget extends ConsumerWidget {
  final String truekeId;
  const EscrowBadgeWidget({super.key, required this.truekeId});

  Color _getEscrowColor(EscrowStatus status) {
    switch (status) {
      case EscrowStatus.released:
        return AppColors.success;
      case EscrowStatus.held:
        return AppColors.amber;
      case EscrowStatus.refunded:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escrowAsync = ref.watch(truekeEscrowProvider(truekeId));

    return escrowAsync.when(
      data: (escrow) {
        if (escrow == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: _getEscrowColor(escrow.status).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(color: _getEscrowColor(escrow.status), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 12,
                color: _getEscrowColor(escrow.status),
              ),
              const SizedBox(width: 4),
              Text(
                'GARANTÍA: ${escrow.status.name.toUpperCase()} (${escrow.amount}€)',
                style: TextStyle(
                  color: _getEscrowColor(escrow.status),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
