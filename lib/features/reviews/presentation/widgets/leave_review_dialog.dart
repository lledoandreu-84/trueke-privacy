import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../providers/reviews_provider.dart";
import "../../../profile/providers/profile_provider.dart";
import "../../../../models/review.dart";

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
    if (_containsBlacklistedWords(commentText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Comentario bloqueado: Contiene lenguaje prohibido."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
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
            backgroundColor: Colors.red,
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
    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Valorar intercambio",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: theme.colorScheme.onSurface,
          letterSpacing: -0.4,
        ),
      ),
      content: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "¿Cómo fue tu experiencia en el trato en mano?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
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
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 28,
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
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                filled: true,
                fillColor: Colors.grey.shade50,
                counterText: "",
                contentPadding: const EdgeInsets.all(14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: theme.colorScheme.onSurface,
                    width: 1.0,
                  ),
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black54,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _submitReview,
          style: TextButton.styleFrom(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text("Enviar"),
        ),
      ],
    );
  }
}
