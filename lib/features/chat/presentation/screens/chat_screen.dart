import 'package:trueke/models/review.dart';
import 'package:trueke/features/reviews/providers/reviews_provider.dart';
import 'package:trueke/models/transaction.dart';
import 'package:trueke/features/transactions/providers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:trueke/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:trueke/features/chat/presentation/widgets/select_product_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/chat/providers/chat_providers.dart';
import 'package:trueke/features/escrow/providers/escrow_notifier.dart';
import 'package:trueke/features/escrow/repositories/escrow_repository.dart';
import 'package:trueke/core/theme/app_colors.dart';
import '../../../auth/auth_service.dart';
import '../../../products/domain/product_model.dart';

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

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            "Valorar Trueke",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
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
                      size: 30,
                    ),
                    onPressed: () =>
                        setDialogState(() => selectedStars = index + 1),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: "Escribe un comentario breve...",
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.5,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
                maxLines: 2,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceMint,
          border: Border(
            bottom: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "PROPUESTA DE TRUEKE: $productTitle",
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            if (!isMyOffer) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
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
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Aceptar Trueke",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
              const Text(
                "Esperando respuesta del otro usuario...",
                style: TextStyle(
                  color: AppColors.textSecondary,
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceMint,
          border: Border(
            bottom: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "¡TRUEKE ACEPTADO! FONDOS EN CUSTODIA SEGURA",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11.5,
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
              icon: const Icon(Icons.handshake_rounded, size: 15),
              label: const Text(
                "Liberar fondos en mano",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (status == "completed") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceMint,
          border: Border(
            bottom: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "🤝 ¡Trueke Finalizado con éxito en mano!",
              style: TextStyle(
                color: AppColors.primary,
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
              icon: const Icon(Icons.star_rounded, size: 15),
              label: const Text(
                "Valorar Interlocutor",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (status == "cancelled") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: const BoxDecoration(
          color: Color(0xFFFEF2F2),
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFFCA5A5),
              width: 0.5,
            ),
          ),
        ),
        child: const Center(
          child: Text(
            "Propuesta de trueke rechazada o cancelada",
            style: TextStyle(
              color: Color(0xFF991B1B),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "Chat de Negociación",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: -0.4,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.handshake_outlined, color: AppColors.primary),
            onPressed: _showTradeOfferDialog,
            tooltip: "Proponer Trueke",
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
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
              style: const TextStyle(color: Colors.red),
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
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 0.5,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.attach_file_rounded,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: _pickAndSendImage,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: "Escribe un mensaje...",
                            hintStyle: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13.5,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
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
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: AppColors.primary,
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
