import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chat/data/chat_repository.dart';
import '../../chat/providers/chat_providers.dart';
import '../repositories/escrow_repository.dart';
import 'escrow_state.dart';

class EscrowNotifier extends Notifier<EscrowState> {
  final String tradeOfferId;
  late final EscrowRepository _repository;
  late final ChatRepository _chatRepository;

  EscrowNotifier(this.tradeOfferId);

  @override
  EscrowState build() {
    _repository = ref.watch(escrowRepositoryProvider);
    _chatRepository = ref.watch(chatRepositoryProvider);
    return const EscrowInitial();
  }

  Future<void> fetchEscrowByTradeOfferId() async {
    state = const EscrowLoading();
    try {
      final transaction = await _repository.getEscrowByTradeOfferId(
        tradeOfferId,
      );
      state = EscrowLoaded(transaction);
    } catch (e) {
      state = const EscrowError('Error al cargar la transacción en custodia');
    }
  }

  Future<void> initializeEscrow({
    required double amount,
    required String currency,
  }) async {
    state = const EscrowLoading();
    try {
      final transaction = await _repository.createEscrow(
        tradeOfferId: tradeOfferId,
        amount: amount,
        currency: currency,
      );
      state = EscrowLoaded(transaction);
    } catch (e) {
      state = const EscrowError('Error al inicializar el depósito seguro');
    }
  }

  Future<void> addTrackingLogistics({
    required String escrowId,
    required String trackingNumber,
    required String carrier,
  }) async {
    state = const EscrowLoading();
    try {
      final transaction = await _repository.updateTrackingInfo(
        escrowId: escrowId,
        trackingNumber: trackingNumber,
        carrier: carrier,
      );

      state = EscrowLoaded(transaction);

      // AUTOMATIZACIÓN CONVERSACIONAL: Intentar notificar en el chat de los usuarios
      try {
        final chatRooms = await ref
            .read(chatRepositoryProvider)
            .getOrCreateChatRoom(
              productId: '',
              buyerId: transaction.buyerId,
              sellerId: transaction.sellerId,
            );

        await _chatRepository.sendMessage(
          roomId: chatRooms.id,
          senderId: transaction.sellerId,
          message:
              '📦 ¡Paquete enviado! Transportista: $carrier | Localizador: $trackingNumber',
          isSystem: true,
        );
      } catch (_) {
        // Fallback silencioso para no romper el flujo principal de tracking
      }
    } catch (e) {
      state = const EscrowError('Error al actualizar la información de envío');
    }
  }

  Future<void> cancelAndRefundEscrow({required String escrowId}) async {
    state = const EscrowLoading();
    try {
      final transaction = await _repository.cancelAndRefundEscrow(
        escrowId: escrowId,
      );

      state = EscrowLoaded(transaction);

      // AUTOMATIZACIÓN CONVERSACIONAL: Notificación de cancelación y reembolso en el chat
      try {
        final chatRooms = await ref
            .read(chatRepositoryProvider)
            .getOrCreateChatRoom(
              productId: '',
              buyerId: transaction.buyerId,
              sellerId: transaction.sellerId,
            );

        await _chatRepository.sendMessage(
          roomId: chatRooms.id,
          senderId: transaction.sellerId,
          message:
              '🚨 El trueque ha sido cancelado. Depósito reembolsado automáticamente al comprador.',
          isSystem: true,
        );
      } catch (_) {
        // Fallback silencioso para no comprometer el estado del Notifier
      }
    } catch (e) {
      state = const EscrowError(
        'Error al procesar la cancelación y el reembolso',
      );
    }
  }

  Future<void> releaseEscrowFunds({required String escrowId}) async {
    state = const EscrowLoading();
    try {
      final transaction = await _repository.releaseEscrowFunds(
        escrowId: escrowId,
      );
      state = EscrowLoaded(transaction);
      try {
        final chatRooms = await ref
            .read(chatRepositoryProvider)
            .getOrCreateChatRoom(
              productId: '',
              buyerId: transaction.buyerId,
              sellerId: transaction.sellerId,
            );
        await _chatRepository.sendMessage(
          roomId: chatRooms.id,
          senderId: transaction.buyerId,
          message:
              '🤝 ¡Fondos liberados con éxito! El trueque se ha completado e intercambiado en mano.',
          isSystem: true,
        );
      } catch (_) {}
    } catch (e) {
      state = const EscrowError(
        'Error al procesar la liberación de los fondos',
      );
    }
  }
}

final escrowNotifierProvider =
    NotifierProvider.family<EscrowNotifier, EscrowState, String>(
      EscrowNotifier.new,
    );
