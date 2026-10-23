import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/models/product.dart';
import 'package:trueke/features/products/product_detail_page.dart';
import 'package:trueke/providers/app_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId;

  const ProfileScreen({
    super.key,
    this.userId,
  });

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

  void _submitComment() {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escribe un comentario o sugerencia.')),
      );
      return;
    }

    _commentController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Sugerencia enviada a davidlledoandreu@gmail.com! Gracias por ayudarnos a mejorar.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _submitReview() {
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
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sesión cerrada correctamente.')),
                );
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
    const String imgUrl1 = 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=300';
    const String imgUrl2 = 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=300';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOwn ? 'Mis Productos Publicados' : 'Productos en Venta',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: Image.network(
                      imgUrl1,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.purple[100],
                        child: Icon(Icons.image_rounded, color: Theme.of(context).primaryColor, size: 28),
                      ),
                    ),
                  ),
                ),
                title: const Text('Artículo en venta 1', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Buen estado • Madrid'),
                trailing: Text('Trueke', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(
                        hideVendorCard: true,
                        product: Product(
                          id: 'prod_1',
                          title: 'Artículo en venta 1',
                          description: 'Descripción detallada del artículo en venta 1',
                          condition: 'Buen estado',
                          location: 'Madrid, España',
                          category: 'General',
                          createdAt: DateTime.now(),
                          images: const [imgUrl1],
                          owner: isOwn ? 'pruebatrueke' : 'lledoandreu84',
                          ownerId: isOwn ? 'user_me' : 'lledoandreu84',
                          tradeType: TradeType.trade,
                          wanted: 'Cualquier cosa',
                        ),
                      ),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: Image.network(
                      imgUrl2,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.purple[100],
                        child: Icon(Icons.devices_rounded, color: Theme.of(context).primaryColor, size: 28),
                      ),
                    ),
                  ),
                ),
                title: const Text('Artículo en venta 2', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Como nuevo • Madrid'),
                trailing: Text('Trueke', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(
                        hideVendorCard: true,
                        product: Product(
                          id: 'prod_2',
                          title: 'Artículo en venta 2',
                          description: 'Descripción detallada del artículo en venta 2',
                          condition: 'Como nuevo',
                          location: 'Madrid, España',
                          category: 'General',
                          createdAt: DateTime.now(),
                          images: const [imgUrl2],
                          owner: isOwn ? 'pruebatrueke' : 'lledoandreu84',
                          ownerId: isOwn ? 'user_me' : 'lledoandreu84',
                          tradeType: TradeType.trade,
                          wanted: 'Cualquier cosa',
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
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
    final bool isOwnProfile = widget.userId != 'lledoandreu84' && widget.userId != 'user_vendor';

    final String profileTitle = isOwnProfile ? 'Mi Perfil' : 'Perfil del Vendedor';
    final String displayName = isOwnProfile ? 'pruebatrueke' : 'lledoandreu84';
    final String displaySubtitle = isOwnProfile ? 'Comunidad Trueke' : 'Miembro verificado';

    const publishedCount = 2;
    const historyCount = 0;
    
    final reviews = ref.watch(vendorReviewsProvider);
    final userRating = ref.read(vendorReviewsProvider.notifier).averageRating;
    final totalReviews = ref.read(vendorReviewsProvider.notifier).totalReviews;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          profileTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
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
                        elevation: 1.5,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                                child: Icon(Icons.person, size: 36, color: Theme.of(context).primaryColor),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                displayName,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                displaySubtitle,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                      Text(
                        isOwnProfile ? 'Actividad y Ofertas' : 'Artículos del Vendedor',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              if (isOwnProfile) ...[
                                _buildMenuItem(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  title: 'Mis Conversaciones',
                                  subtitle: 'Negociaciones activas por productos',
                                  badgeText: 'Chat',
                                  onTap: () {
                                    Navigator.pushNamed(context, '/notifications');
                                  },
                                ),
                                const Divider(height: 1),
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
                                const Divider(height: 1),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 1,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
                                        backgroundColor: Theme.of(context).primaryColor,
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
                                        backgroundColor: Theme.of(context).primaryColor,
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
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      leading: CircleAvatar(
        radius: 17,
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 19),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11.5)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}
