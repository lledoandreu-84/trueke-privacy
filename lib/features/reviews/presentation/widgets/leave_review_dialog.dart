import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reviews_provider.dart';
import '../../../profile/providers/profile_provider.dart';
import '../../../../models/review.dart';

class LeaveReviewDialog extends ConsumerStatefulWidget {
  final String truekeId;
  final String reviewedId;
  final String reviewerId;
  const LeaveReviewDialog({
    super.key,
    required this.truekeId,
    required this.reviewedId,
    required this.reviewerId,
  });
  @override
  ConsumerState<LeaveReviewDialog> createState() => _LeaveReviewDialogState();
}

class _LeaveReviewDialogState extends ConsumerState<LeaveReviewDialog> {
  int _currentRating = 5;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  bool _containsBlacklistedWords(String text) {
    final cleanText = text.toLowerCase().trim();
    final blacklist = ["arma", "droga", "estafa", "ilegal", "falso"];
    for (var word in blacklist) {
      final regex = RegExp(word);
      if (regex.hasMatch(cleanText)) return true;
    }
    return false;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final String commentText = _commentController.text.trim();
    final theme = Theme.of(context);
    if (_containsBlacklistedWords(commentText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Comentario bloqueado: Contiene lenguaje prohibido."),
          backgroundColor: theme.colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    setState(() {
      _isSubmitting = true;
    });

    final currentId = "mock_rev_${DateTime.now().millisecondsSinceEpoch}";
    final review = Review(
      id: currentId,
      truekeId: widget.truekeId,
      reviewerId: widget.reviewerId,
      reviewedId: widget.reviewedId,
      rating: _currentRating,
      comment: commentText,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(reviewRepositoryProvider).createReview(review);

      ref.invalidate(userReviewsProvider(widget.reviewedId));
      ref.invalidate(userRatingAverageProvider(widget.reviewedId));
      ref.invalidate(userProfileProvider(widget.reviewedId));

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error al publicar la reseña: ${e.toString().replaceAll('Exception: ', '')}",
            ),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(
        "Valorar intercambio",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: theme.colorScheme.onSurface,
          letterSpacing: -0.4,
        ),
      ),
      content: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "¿Cómo fue tu experiencia en el trato en mano?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return IconButton(
                  icon: Icon(
                    starValue <= _currentRating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: starValue <= _currentRating
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    size: 32,
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _currentRating = starValue;
                          });
                        },
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              maxLength: 200,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                hintText: "Escribe un comentario opcional...",
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 13),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                counterText: "",
                contentPadding: const EdgeInsets.all(16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text("Cancelar"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Text("Enviar"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
