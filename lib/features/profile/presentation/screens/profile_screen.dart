import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      const SnackBar(content: Text('¡Gracias por tus comentarios! Nos ayudan a mejorar.')),
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

    _reviewController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('¡Valoración de $_selectedRating estrellas enviada con éxito!')),
    );
  }

  void _showVendorProducts(BuildContext context) {
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
              const Text(
                'Productos en Venta',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  color: Colors.green[100],
                  child: const Icon(Icons.image, color: Colors.green),
                ),
                title: const Text('Artículo en venta 1'),
                subtitle: const Text('Buen estado • Madrid'),
                trailing: const Text('Trueke', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  color: Colors.blue[100],
                  child: const Icon(Icons.image, color: Colors.blue),
                ),
                title: const Text('Artículo en venta 2'),
                subtitle: const Text('Como nuevo • Madrid'),
                trailing: const Text('Trueke', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatingBadge({required double rating, required int totalReviews}) {
    if (totalReviews == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_outline_rounded, size: 16, color: Colors.grey[600]),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
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
    final bool isOwnProfile = widget.userId == null || widget.userId == 'me' || widget.userId == 'lledoandreu84';
    final String profileTitle = isOwnProfile ? 'Mi Perfil' : 'Perfil del Vendedor';
    
    // Si el userId es un hash largo, mostramos un nombre limpio y comercial
    String displayName = 'Usuario Trueke';
    if (!isOwnProfile) {
      displayName = widget.userId!.length > 15 ? 'lledoandreu84' : widget.userId!;
    }

    final String displaySubtitle = isOwnProfile ? 'Comunidad Trueke' : 'Miembro verificado';

    const publishedCount = 2;
    const historyCount = 0;
    const double userRating = 0.0;
    const int totalReviews = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(profileTitle),
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              child: Icon(Icons.person, size: 40),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              displayName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displaySubtitle,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 10),
                            _buildRatingBadge(
                              rating: userRating,
                              totalReviews: totalReviews,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isOwnProfile ? 'Actividad y Ofertas' : 'Artículos del Vendedor',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
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
                              subtitle: isOwnProfile ? 'Gestiona tus artículos expuestos' : 'Ver artículos de este vendedor',
                              badgeText: '$publishedCount',
                              onTap: () {
                                _showVendorProducts(context);
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
                    const SizedBox(height: 24),
                    Text(
                      isOwnProfile ? 'Sugerencias y Feedback' : 'Valorar al Vendedor',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: isOwnProfile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextField(
                                    controller: _commentController,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      hintText: '¿Cómo podemos mejorar tu experiencia en Trueke?',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: _submitComment,
                                    icon: const Icon(Icons.send_rounded),
                                    label: const Text('Enviar Sugerencia'),
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
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      hintText: 'Escribe tu reseña sobre el trato y el intercambio...',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: _submitReview,
                                    icon: const Icon(Icons.rate_review_rounded),
                                    label: const Text('Enviar Reseña y Valoración'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6750A4),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
      onTap: onTap,
    );
  }
}
