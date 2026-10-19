import 'package:trueke/models/review.dart';
import 'package:trueke/features/reviews/providers/reviews_provider.dart';
import 'package:trueke/models/transaction.dart';
import 'package:trueke/features/transactions/providers/transaction_providers.dart';
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "dart:convert";
import "package:trueke/features/chat/presentation/widgets/chat_bubble.dart";
import "package:trueke/features/chat/presentation/widgets/select_product_dialog.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:trueke/features/chat/providers/chat_providers.dart";
import "package:trueke/features/escrow/providers/escrow_notifier.dart";
import "package:trueke/features/escrow/repositories/escrow_repository.dart";
import "../../../auth/auth_service.dart";
import "../../../products/domain/product_model.dart";

class ChatScreen extends ConsumerStatefulWidget {
  final String roomId;
  const ChatScreen({super.key, required this.roomId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isReleasingFunds = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _abrirDialogoValoracionConGuardia(
    String reviewedId,
    String? currentOfferId,
  ) {
    if (!mounted || !context.mounted) return;
    int selectedStars = 5;
    final commentController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(
            "Valorar Trueke",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.4,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      index < selectedStars
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () =>
                        setDialogState(() => selectedStars = index + 1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: "Escribe un comentario breve...",
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
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
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 2,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
              ),
              child: const Text("Cancelar"),
            ),
            FilledButton(
              onPressed: () async {
                final rev = Review(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  truekeId: currentOfferId ?? '',
                  reviewerId: AuthService.currentUserId ?? '',
                  reviewedId: reviewedId,
                  comment: commentController.text.trim(),
                  rating: selectedStars,
                  createdAt: DateTime.now(),
                );
                await ref.read(reviewRepositoryProvider).createReview(rev);
                ref.invalidate(userRatingAverageProvider(reviewedId));
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              },
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 0,
              ),
              child: const Text("Enviar"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUserId = AuthService.currentUserId;
    if (currentUserId == null) return;

    _messageController.clear();

    try {
      await ref
          .read(chatRepositoryProvider)
          .sendMessage(
            roomId: widget.roomId,
            senderId: currentUserId,
            message: text,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al enviar mensaje: $e"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickAndSendImage() async {
    final currentUserId = AuthService.currentUserId;
    if (currentUserId == null) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) return;

    try {
      final bytes = await image.readAsBytes();
      final fileName = "${DateTime.now().microsecondsSinceEpoch}.jpg";
      final repo = ref.read(chatRepositoryProvider);

      final imageUrl = await repo.uploadMessageImage(
        roomId: widget.roomId,
        fileName: fileName,
        bytes: bytes,
      );

      await repo.sendMessage(
        roomId: widget.roomId,
        senderId: currentUserId,
        message: "[IMAGE]:$imageUrl",
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al subir imagen: $e")));
      }
    }
  }

  Future<void> _showTradeOfferDialog() async {
    final currentUserId = AuthService.currentUserId;
    if (currentUserId == null) return;

    final Product? selectedProduct = await showDialog<Product>(
      context: context,
      builder: (context) => const SelectProductDialog(),
    );

    if (selectedProduct == null) return;

    final generatedTime = DateTime.now();
    final String generatedOfferId = generatedTime.millisecondsSinceEpoch
        .toString();

    final offerData = {
      "id": generatedOfferId,
      "product_title": selectedProduct.title,
      "status": "pending",
      "amount": 0.0,
      "timestamp": generatedTime.toIso8601String(),
    };

    final systemMessagePayload = "[TRADE_OFFER]:${jsonEncode(offerData)}";

    try {
      await ref
          .read(chatRepositoryProvider)
          .sendTradeOffer(
            roomId: widget.roomId,
            senderId: currentUserId,
            message: systemMessagePayload,
            offerId: generatedOfferId,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al proponer trueke: $e"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildStateBanner(List<dynamic> messages) {
    final theme = Theme.of(context);
    dynamic lastOfferPayload;
    String? lastOfferSenderId;
    for (final msg in messages.reversed) {
      if (msg.message.startsWith("[TRADE_OFFER]:")) {
        try {
          final jsonStr = msg.message.substring("[TRADE_OFFER]:".length);
          lastOfferPayload = jsonDecode(jsonStr);
          lastOfferSenderId = msg.senderId;
          break;
        } catch (_) {}
      }
    }
    if (lastOfferPayload == null) return const SizedBox.shrink();
    String status = lastOfferPayload["status"] ?? "pending";
    final String? timestampStr = lastOfferPayload["timestamp"];
    final String productTitle = lastOfferPayload["product_title"] ?? "Artículo";
    final String? currentOfferId = lastOfferPayload["id"];
    final currentUserId = AuthService.currentUserId ?? '';
    if (status == "pending" && timestampStr != null) {
      try {
        final DateTime offerTime = DateTime.parse(timestampStr);
        if (DateTime.now().difference(offerTime).inHours >= 48) {
          status = "expired";
        }
      } catch (_) {}
    }
    if (status == "pending") {
      final isMyOffer = lastOfferSenderId == currentUserId;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.4),
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "PROPUESTA DE TRUEKE: $productTitle",
              style: TextStyle(
                color: theme.colorScheme.onTertiaryContainer,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (!isMyOffer) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.tonal(
                    onPressed: () async {
                      try {
                        final room = await ref.read(
                          singleChatRoomProvider(widget.roomId).future,
                        );
                        if (room == null) return;
                        final product = await ref.read(
                          chatProductProvider(room.productId).future,
                        );

                        final tx = ProductTransaction(
                          id:
                              currentOfferId ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          productId: room.productId,
                          productTitle: product?.title ?? productTitle,
                          sellerId: room.sellerId,
                          sellerName: "Vendedor",
                          buyerId: room.buyerId,
                          buyerName: "Comprador",
                          status: TransactionStatus.accepted,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );
                        await ref
                            .read(transactionRepositoryProvider)
                            .createTransaction(tx);
                        final updatedOffer = Map<String, dynamic>.from(
                          lastOfferPayload,
                        );
                        updatedOffer["status"] = "accepted";
                        await ref
                            .read(chatRepositoryProvider)
                            .sendMessage(
                              roomId: widget.roomId,
                              senderId: currentUserId,
                              message:
                                  "[TRADE_OFFER]:${jsonEncode(updatedOffer)}",
                            );
                      } catch (_) {}
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                    ),
                    child: const Text(
                      "Aceptar Trueke",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () async {
                      try {
                        final updatedOffer = Map<String, dynamic>.from(
                          lastOfferPayload,
                        );
                        updatedOffer["status"] = "cancelled";
                        await ref
                            .read(chatRepositoryProvider)
                            .sendMessage(
                              roomId: widget.roomId,
                              senderId: currentUserId,
                              message:
                                  "[TRADE_OFFER]:${jsonEncode(updatedOffer)}",
                            );
                      } catch (_) {}
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(
                        color: theme.colorScheme.error.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Text(
                      "Rechazar",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                "Esperando respuesta del otro usuario...",
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      );
    }
    if (status == "accepted" && currentOfferId != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "¡TRUEKE ACEPTADO! FONDOS EN CUSTODIA SEGURA",
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _isReleasingFunds
                  ? null
                  : () async {
                      setState(() {
                        _isReleasingFunds = true;
                      });
                      try {
                        final room = await ref.read(
                          singleChatRoomProvider(widget.roomId).future,
                        );
                        if (room != null) {
                          final escrowRepo = ref.read(escrowRepositoryProvider);
                          final escrowTx = await escrowRepo
                              .getEscrowByTradeOfferId(currentOfferId);
                          await ref
                              .read(
                                escrowNotifierProvider(currentOfferId).notifier,
                              )
                              .releaseEscrowFunds(escrowId: escrowTx.id);
                          await ref
                              .read(userTransactionsProvider.notifier)
                              .procesarCambioEstadoTrueque(
                                transactionId: currentOfferId,
                                productId: room.productId,
                                nuevoEstado: TransactionStatus.completed,
                              );
                          final updatedOffer = Map<String, dynamic>.from(
                            lastOfferPayload,
                          );
                          updatedOffer["status"] = "completed";
                          await ref
                              .read(chatRepositoryProvider)
                              .sendMessage(
                                roomId: widget.roomId,
                                senderId: currentUserId,
                                message:
                                    "[TRADE_OFFER]:${jsonEncode(updatedOffer)}",
                              );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "INFO: Escrow listo o pendiente de depósito inicial.",
                              ),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isReleasingFunds = false;
                          });
                        }
                      }
                    },
              icon: const Icon(Icons.handshake_rounded, size: 16),
              label: const Text(
                "Liberar fondos en mano",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 0,
              ),
            ),
          ],
        ),
      );
    }
    if (status == "completed") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "🤝 ¡Trueke Finalizado con éxito en mano!",
              style: TextStyle(
                color: theme.colorScheme.onSecondaryContainer,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () async {
                final room = await ref.read(
                  singleChatRoomProvider(widget.roomId).future,
                );
                if (room == null || !mounted) return;

                final reviewedId = currentUserId == room.sellerId
                    ? room.buyerId
                    : room.sellerId;

                _abrirDialogoValoracionConGuardia(reviewedId, currentOfferId);
              },
              icon: const Icon(Icons.star_rounded, size: 16),
              label: const Text(
                "Valorar Interlocutor",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                elevation: 0,
              ),
            ),
          ],
        ),
      );
    }
    if (status == "cancelled") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Center(
          child: Text(
            "Propuesta de trueke rechazada o cancelada",
            style: TextStyle(
              color: theme.colorScheme.onErrorContainer,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesStreamProvider(widget.roomId));
    final currentUserId = AuthService.currentUserId ?? '';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "Chat de Negociación",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: -0.4,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          IconButton(
            icon: Icon(Icons.handshake_outlined, color: theme.colorScheme.onSurface),
            onPressed: _showTradeOfferDialog,
            tooltip: "Proponer Trueke",
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            height: 0.5,
          ),
        ),
      ),
      body: messagesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "Error al cargar mensajes: $err",
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
        data: (messages) {
          return Column(
            children: [
              _buildStateBanner(messages),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final bool isMe = msg.senderId == currentUserId;
                    return ChatBubble(message: msg, isMe: isMe);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.attach_file_rounded,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: _pickAndSendImage,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: "Escribe un mensaje...",
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.send_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
