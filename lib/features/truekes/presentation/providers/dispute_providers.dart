import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../chat/data/chat_repository.dart';
import '../../../chat/providers/chat_providers.dart';
import '../../data/models/dispute_model.dart';
import '../../data/repositories/dispute_repository.dart';

class DisputeNotifier extends AsyncNotifier<List<DisputeModel>> {
  late final DisputeRepository _repository;
  late final ChatRepository _chatRepository;
  StreamSubscription<List<DisputeModel>>? _subscription;

  @override
  FutureOr<List<DisputeModel>> build() {
    _repository = ref.watch(disputeRepositoryProvider);
    _chatRepository = ref.watch(chatRepositoryProvider);

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return []; // Retorno de coleccion base inicial inmutable
  }

  void listenToTruekeDisputes(String truekeId) {
    _subscription?.cancel();
    _subscription = _repository
        .streamDisputesByTruekeId(truekeId)
        .listen(
          (disputes) {
            state = AsyncValue.data(disputes);
          },
          onError: (err, stack) {
            state = AsyncValue.error(err, stack);
          },
        );
  }

  Future<void> raiseDispute({
    required String truekeId,
    required String raisedBy,
    required String reason,
    required String chatRoomId,
  }) async {
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      await _repository.createDispute(
        truekeId: truekeId,
        raisedBy: raisedBy,
        reason: reason,
      );

      await _chatRepository.sendMessage(
        roomId: chatRoomId,
        senderId: raisedBy,
        message:
            '🚨 SE HA ABIERTO UNA DISPUTA DE ARBITRAJE.\nRazón: $reason\nEl equipo técnico revisará el caso.',
        isSystem: true,
      );
    } catch (e, stack) {
      if (previousState.hasValue) {
        state = AsyncValue.data(previousState.value!);
      } else {
        state = AsyncValue.error(e, stack);
      }
      rethrow; // Re-lanzamiento imperativo para alertar a la UI mediante SnackBar
    }
  }

  Future<void> resolveDispute({
    required String truekeId,
    required String disputeId,
    required DisputeStatus resolution,
    required String chatRoomId,
    required String adminId,
  }) async {
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      await _repository.updateDisputeStatus(
        disputeId: disputeId,
        status: resolution,
      );

      final String statusLabel = resolution == DisputeStatus.underReview
          ? 'EN REVISIÓN'
          : resolution.name.toUpperCase();

      await _chatRepository.sendMessage(
        roomId: chatRoomId,
        senderId: adminId,
        message:
            '⚖️ ACTUALIZACIÓN DE ARBITRAJE: La disputa ha cambiado a estado [$statusLabel].',
        isSystem: true,
      );
    } catch (e, stack) {
      if (previousState.hasValue) {
        state = AsyncValue.data(previousState.value!);
      } else {
        state = AsyncValue.error(e, stack);
      }
      rethrow; // Re-lanzamiento imperativo para alertar a la UI mediante SnackBar
    }
  }
}

final disputeNotifierProvider =
    AsyncNotifierProvider<DisputeNotifier, List<DisputeModel>>(
      DisputeNotifier.new,
    );
