import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/core/providers/favorites_provider.dart';
import '../../models/product.dart';
import '../auth/auth_service.dart';
import 'package:trueke/features/chat/presentation/screens/chat_screen.dart';
import 'package:trueke/features/chat/providers/chat_providers.dart';
import 'package:trueke/features/transactions/presentation/widgets/create_offer_dialog.dart';
import 'widgets/product_description.dart';
import 'widgets/product_gallery.dart';
import 'widgets/product_info.dart';
import 'widgets/seller_card.dart';
import 'widgets/trade_info.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  bool _isStartingChat = false;

  bool get _isOwner {
    return widget.product.ownerId == AuthService.currentUserId;
  }

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
            content: Text(
              'No se puede iniciar el chat porque el anuncio no identifica al vendedor.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.textPrimary,
          ),
        );
        if (mounted) {
          setState(() => _isStartingChat = false);
        }
        return;
      }

      final chatRepo = ref.read(chatRepositoryProvider);

      if (sellerId == currentUserId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No puedes chatear con tu propio anuncio.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.textPrimary,
          ),
        );
        setState(() => _isStartingChat = false);
        return;
      }

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

      if (!mounted) {
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatScreen(roomId: chatRoomEntity.id),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
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
      builder: (context) {
        return CreateOfferDialog(product: widget.product);
      },
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
      data: (favs) {
        return favs.any((p) => p.id == widget.product.id);
      },
      orElse: () {
        return false;
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          ProductGallery(product: widget.product),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductInfo(product: widget.product),
                  const Divider(
                    height: 32,
                    thickness: 0.5,
                    color: AppColors.border,
                  ),
                  ProductDescription(product: widget.product),
                  if (widget.product.wanted.isNotEmpty) ...[
                    const Divider(
                      height: 32,
                      thickness: 0.5,
                      color: AppColors.border,
                    ),
                    TradeInfo(product: widget.product),
                  ],
                  const Divider(
                    height: 32,
                    thickness: 0.5,
                    color: AppColors.border,
                  ),
                  SellerCard(product: widget.product),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border, width: 0.8),
            ),
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMint,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: favoritesAsync.when(
                  data: (_) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        if (userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Inicia sesión para guardar favoritos.',
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.textPrimary,
                            ),
                          );
                          return;
                        }
                        final notifier = ref.read(favoritesProvider.notifier);
                        await notifier.toggleFavorite(widget.product);
                      },
                      child: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? AppColors.coral : AppColors.primary,
                        size: 20,
                      ),
                    );
                  },
                  loading: () {
                    return const Center(
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  error: (_, stackTrace) {
                    return const Icon(
                      Icons.favorite_border_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    );
                  },
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: _isStartingChat ? null : _handleStartChat,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.surfaceMint,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isStartingChat
                      ? const CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        )
                      : const Text(
                          'Chatear',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: -0.1,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: _handleTradeOffer,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Proponer Trueke',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
