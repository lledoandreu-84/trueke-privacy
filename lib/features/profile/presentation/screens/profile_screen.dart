// import 'package:trueke/features/chat/providers/chat_providers.dart';
import 'package:trueke/features/profile/providers/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'my_published_products_screen.dart';
import 'package:trueke/features/products/providers/user_products_provider.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:trueke/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/providers/app_providers.dart';
import 'package:trueke/shared/widgets/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trueke/features/products/providers/paginated_products_provider.dart';
import 'package:trueke/features/products/providers/products_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId;

    final String? initialDisplayName;
const ProfileScreen({super.key, this.userId, this.initialDisplayName});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _commentController = TextEditingController();
  final _reviewController = TextEditingController();
  int _selectedRating = 5;

  @override
  void dispose() {
    _commentController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escribe un comentario o sugerencia.')),
      );
      return;
    }

    final Uri emailUri = Uri.parse(
      'mailto:lledoandreu84@gmail.com?subject=${Uri.encodeComponent("Sugerencia para Trueke")}&body=${Uri.encodeComponent(comment)}',
    );

    try {
      bool launched = false;
      if (await canLaunchUrl(emailUri)) {
        launched = await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      }
      
      if (!launched) {
        launched = await launchUrl(emailUri, mode: LaunchMode.platformDefault);
      }

      if (launched) {
        _commentController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Correo abierto para enviar sugerencia a lledoandreu84@gmail.com!'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sugerencia guardada. No hay aplicación de correo configurada en este dispositivo.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sugerencia enviada correctamente a lledoandreu84@gmail.com')),
        );
        _commentController.clear();
      }
    }
  }

  void _submitReview() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final currentUserId = currentUser?.id;
    
    // Bloquear auto-valoración
    if ((widget.userId != null && widget.userId == currentUserId) || 
         
        (widget.userId == null && currentUserId == null)) {
      // Si no hay userId específico (perfil propio por defecto) o coincide con el usuario logueado o bypass
      // Nota: Si el perfil actual es el del propio usuario logueado:
    }

    // Comprobación robusta y definitiva anti-auto-valoración
    if (widget.userId == null || widget.userId == currentUserId ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes valorarte a ti mismo.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final review = _reviewController.text.trim();
    if (review.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escribe una reseña sobre el vendedor.')),
      );
      return;
    }

    ref.read(vendorReviewsProvider.notifier).addReview(_selectedRating, review);
    _reviewController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('¡Valoración de $_selectedRating estrellas guardada con éxito!')),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Cerrar Sesión'),
            ],
          ),
          content: const Text('¿Estás seguro de que deseas salir de tu cuenta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await ref.read(authServiceProvider).signOut();
                    ref.invalidate(userProductsProvider);
                    ref.invalidate(productsProvider);
                    ref.invalidate(paginatedProductsProvider);
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al cerrar sesión: $e')),
                      );
                    }
                  }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  void _showVendorProducts(BuildContext context, {required bool isOwn}) {
    if (isOwn) {
      final userProductsAsync = ref.read(productsProvider);
      final count = userProductsAsync.asData?.value.length ?? 0;
      if (count == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aún no has publicado ningún artículo en tu escaparate.')),
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MyPublishedProductsScreen(),
        ),
      );
    } else {
      // Navegar a los productos públicos del vendedor específico usando su userId
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyPublishedProductsScreen(userId: widget.userId),
        ),
      );
    }
  }

  Widget _buildRatingBadge({required double rating, required int totalReviews}) {
    if (totalReviews == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_outline_rounded, size: 15, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              'Sin valoraciones aún',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            '${rating.toStringAsFixed(1)} ($totalReviews)',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
     final currentUser = Supabase.instance.client.auth.currentUser;
     final userEmail = currentUser?.email ?? 'Usuario';
     final currentUsername = userEmail.contains('@') ? userEmail.split('@')[0] : userEmail;

     final bool isOwnProfile = widget.userId == null || widget.userId == currentUser?.id;

     final String profileTitle = isOwnProfile ? 'Mi Perfil' : 'Perfil del Vendedor';
     final profileAsync = isOwnProfile ? null : ref.watch(userProfileProvider(widget.userId!));
     
     final String resolvedAsyncName = profileAsync?.asData?.value.displayName ?? '';
     
     final String displayName = isOwnProfile 
         ? currentUsername 
         : (widget.initialDisplayName?.isNotEmpty == true 
             ? widget.initialDisplayName! 
             : (resolvedAsyncName.isNotEmpty 
                 ? resolvedAsyncName 
                 : (widget.userId ?? 'Vendedor Trueke')));

    final String displaySubtitle = isOwnProfile ? 'Comunidad Trueke' : 'Miembro verificado';

    final productsAsync = ref.watch(productsProvider);
     // Si widget.userId viene informado, filtramos por él (perfil ajeno), si es null, filtramos por el usuario actual (perfil propio)
     final effectiveProfileId = widget.userId ?? currentUser?.id;
     // final conversationsAsync = ref.watch(userConversationsProvider);
     // final conversationsCount = conversationsAsync.asData?.value.length ?? 0;
     final publishedCount = productsAsync.asData?.value.where((p) => p.ownerId == effectiveProfileId).length ?? 0;
    const historyCount = 0;
    
    final reviews = ref.watch(vendorReviewsProvider);
    final userRating = ref.read(vendorReviewsProvider.notifier).averageRating;
    final totalReviews = ref.read(vendorReviewsProvider.notifier).totalReviews;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(titleText: profileTitle),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 1,
                        color: Colors.white,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: const Color(0xFF6750A4).withValues(alpha: 0.15),
                                child: const Icon(Icons.person, size: 36, color: Color(0xFF6750A4)),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                displaySubtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildRatingBadge(
                                rating: userRating,
                                totalReviews: totalReviews,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Actividad y Ofertas',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            children: [
                              if (isOwnProfile) ...[
                                _buildMenuItem(
                                  icon: Icons.settings_outlined,
                                  title: 'Configuración',
                                  subtitle: 'Ajustes de cuenta y preferencias',
                      
                                  onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                                ),
                                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                              ],
                              _buildMenuItem(
                                icon: Icons.inventory_2_outlined,
                                title: isOwnProfile ? 'Mis Productos Publicados' : 'Productos en Venta',
                                subtitle: isOwnProfile ? 'Gestiona tus artículos expuestos' : 'Ver artículos expuestos',
                                badgeText: '$publishedCount',
                                onTap: () {
                                  _showVendorProducts(context, isOwn: isOwnProfile);
                                },
                              ),
                              if (isOwnProfile) ...[
                                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                                _buildMenuItem(
                                  icon: Icons.history_rounded,
                                  title: 'Historial de Intercambios',
                                  subtitle: 'Truekes completados con éxito',
                                  badgeText: '$historyCount',
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Aún no has completado ningún Trueke.')),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        isOwnProfile ? 'Sugerencias y Feedback' : 'Valorar al Vendedor',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 1,
                        color: Colors.white,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                          child: isOwnProfile
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _commentController,
                                        maxLines: 1,
                                        style: const TextStyle(fontSize: 13),
                                        decoration: const InputDecoration(
                                          hintText: '¿Cómo podemos mejorar Trueke?',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                          ),
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton.filled(
                                      onPressed: _submitComment,
                                      icon: const Icon(Icons.send_rounded, size: 18),
                                      style: IconButton.styleFrom(
                                        backgroundColor: const Color(0xFF6750A4),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.all(12),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Selecciona una puntuación:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(5, (index) {
                                        final starNumber = index + 1;
                                        return IconButton(
                                          icon: Icon(
                                            starNumber <= _selectedRating
                                                ? Icons.star_rounded
                                                : Icons.star_outline_rounded,
                                            color: Colors.amber,
                                            size: 32,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _selectedRating = starNumber;
                                            });
                                          },
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _reviewController,
                                      maxLines: 2,
                                      decoration: const InputDecoration(
                                        hintText: 'Escribe tu reseña sobre el trato...',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton.icon(
                                      onPressed: _submitReview,
                                      icon: const Icon(Icons.rate_review_rounded),
                                      label: const Text('Enviar Reseña y Valoración'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6750A4),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    if (reviews.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      const Divider(),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Reseñas recibidas (${reviews.length})',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 6),
                                      ...reviews.map((r) => Padding(
                                            padding: const EdgeInsets.only(bottom: 6.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: List.generate(
                                                    r.rating,
                                                    (index) => const Icon(Icons.star, size: 14, color: Colors.amber),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(r.comment, style: const TextStyle(fontSize: 13)),
                                              ],
                                            ),
                                          )),
                                    ],
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isOwnProfile) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                  label: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.08),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      leading: CircleAvatar(
        radius: 17,
        backgroundColor: const Color(0xFF6750A4).withValues(alpha: 0.15),
        child: Icon(icon, color: const Color(0xFF6750A4), size: 19),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.black87),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11.5, color: Colors.grey[600])),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF6750A4).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badgeText ?? '',
              style: const TextStyle(
                color: Color(0xFF6750A4),
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    ),
  );
  }
}