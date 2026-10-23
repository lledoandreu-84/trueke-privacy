import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- 1. FAVORITOS ---
final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggleFavorite(String productId) {
    if (state.contains(productId)) {
      state = {...state}..remove(productId);
    } else {
      state = {...state}..add(productId);
    }
  }

  bool isFavorite(String productId) => state.contains(productId);
}

// --- 2. CHAT ---
class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  ChatMessage({required this.text, required this.isMe, required this.time});
}

final chatMessagesProvider = NotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);

class ChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() => [
    ChatMessage(text: '¡Hola! Me interesa este artículo.', isMe: true, time: DateTime.now().subtract(const Duration(minutes: 2))),
  ];

  void sendMessage(String text) {
    state = [...state, ChatMessage(text: text, isMe: true, time: DateTime.now())];
  }
}

// --- 3. RESEÑAS Y VALORACIONES ---
class Review {
  final int rating;
  final String comment;
  final DateTime date;

  Review({required this.rating, required this.comment, required this.date});
}

final vendorReviewsProvider = NotifierProvider<ReviewsNotifier, List<Review>>(ReviewsNotifier.new);

class ReviewsNotifier extends Notifier<List<Review>> {
  @override
  List<Review> build() => [];

  void addReview(int rating, String comment) {
    state = [...state, Review(rating: rating, comment: comment, date: DateTime.now())];
  }

  double get averageRating {
    if (state.isEmpty) return 0.0;
    final sum = state.fold(0, (acc, r) => acc + r.rating);
    return sum / state.length;
  }

  int get totalReviews => state.length;
}
