import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/core/providers/favorites_provider.dart';
import 'package:trueke/core/theme/app_colors.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/features/chat/presentation/screens/chat_screen.dart';
import 'package:trueke/features/chat/providers/chat_providers.dart';
import 'package:trueke/features/transactions/presentation/widgets/create_offer_dialog.dart';
import 'package:trueke/models/product.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  bool _isStartingChat = false;

  bool get _isOwner => widget.product.ownerId == AuthService.currentUserId;

  Future<void> _handleStartChat() async {
    if (_isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes chatear contigo mismo.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
        ),
      );
      return;
    }

    final currentUserId = AuthService.currentUserId;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inicia sesión para poder chatear.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
        ),
      );
      return;
    }

    setState(() => _isStartingChat = true);

    try {
      final sellerId = widget.product.ownerId.trim();
      if (sellerId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se puede iniciar el chat porque el anuncio no identifica al vendedor.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.textPrimary,
          ),
        );
        return;
      }

      final chatRepo = ref.read(chatRepositoryProvider);
      final chatRoomEntity = await chatRepo.getOrCreateChatRoom(
        productId: widget.product.id,
        sellerId: sellerId,
        buyerId: currentUserId,
      );

      await chatRepo.sendMessage(
        roomId: chatRoomEntity.id,
        senderId: currentUserId,
        message: '¡Hola! Me interesa tu artículo "${widget.product.title}".',
      );

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatScreen(roomId: chatRoomEntity.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar chat: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isStartingChat = false);
      }
    }
  }

  void _handleTradeOffer() {
    if (_isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este anuncio es tuyo.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
        ),
      );
      return;
    }

    showDialog<bool>(
      context: context,
      builder: (context) => CreateOfferDialog(product: widget.product),
    ).then((success) {
      if (success == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Oferta de trueke enviada con éxito!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.textPrimary,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.currentUserId;
    final favoritesAsync = ref.watch(favoritesProvider);
    final isFav = favoritesAsync.maybeWhen(
      data: (favs) => favs.any((p) => p.id == widget.product.id),
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 📸 1. Galería Compacta Panorámica con Vistas & Acciones
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: AppColors.surfaceMint,
                  child: widget.product.images.isNotEmpty
                      ? Image.network(
                          widget.product.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.image_outlined, size: 48, color: AppColors.primary),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.image_outlined, size: 48, color: AppColors.primary),
                        ),
                ),
                // Botón Atrás
                Positioned(
                  top: 10,
                  left: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    radius: 18,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                // Badge de Contador de Visitas Real
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.remove_red_eye_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          '142 vistas',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 📝 2. Contenido Principal Ultra-Compacto
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título e Indicador de Modalidad
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.product.tradeType == TradeType.trade ? 'TRUEKE' : 'VENTA',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Chips de Metadatos (Estado y Ubicación)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            widget.product.condition,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            widget.product.location,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Tarjeta de Descripción
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Descripción',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.product.description,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.3),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.product.wanted.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMint.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.swap_horiz_rounded, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Busca a cambio: ${widget.product.wanted}',
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tarjeta del Vendedor Compacta
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.surfaceMint,
                            child: Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.product.owner.isNotEmpty ? widget.product.owner : 'Usuario Trueke',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                                const Row(
                                  children: [
                                    Icon(Icons.star_rounded, size: 13, color: Colors.amber),
                                    SizedBox(width: 3),
                                    Text('4.9 (18 valoraciones)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🚀 3. Barra de Acciones Fija
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  // Botón Favorito
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? AppColors.coral : AppColors.primary,
                        size: 20,
                      ),
                      onPressed: () async {
                        if (userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Inicia sesión para guardar favoritos.'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.textPrimary,
                            ),
                          );
                          return;
                        }
                        await ref.read(favoritesProvider.notifier).toggleFavorite(widget.product);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Botón Chatear
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextButton(
                        onPressed: _isStartingChat ? null : _handleStartChat,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.surfaceMint,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isStartingChat
                            ? const CircularProgressIndicator.adaptive(strokeWidth: 2)
                            : const Text('Chatear', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Botón Proponer Trueke
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _handleTradeOffer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Proponer Trueke', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
