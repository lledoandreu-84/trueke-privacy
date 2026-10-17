import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/core/providers/shell_index_provider.dart';
import 'package:trueke/features/home/home_page.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/features/favorites/favorites_page.dart';
import 'package:trueke/features/profile/presentation/screens/profile_screen.dart';
import 'package:trueke/features/products/publish_product_page.dart';
import 'package:trueke/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:trueke/features/chat/providers/chat_unread_provider.dart';

class MainShell extends ConsumerWidget {
  final Widget? child;

  const MainShell({super.key, this.child});

  void _navigateToPublish(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return const PublishProductPage();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(shellIndexProvider);
    final user = ref.watch(currentUserProvider);
    final userId = user?.id ?? '';
    final unreadChats = ref.watch(chatUnreadCountProvider);

    final List<Widget> screens = [
      const HomePage(),
      const ChatListScreen(),
      const FavoritesPage(),
      ProfileScreen(userId: userId),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    currentIndex == 0
                        ? Icons.home_rounded
                        : Icons.home_outlined,
                    size: 24,
                  ),
                  color: currentIndex == 0 ? Colors.black87 : Colors.black45,
                  onPressed: () {
                    ref.read(shellIndexProvider.notifier).setIndex(0);
                  },
                  tooltip: 'Inicio',
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(
                        currentIndex == 1
                            ? Icons.chat_bubble_rounded
                            : Icons.chat_bubble_outline_rounded,
                        size: 22,
                      ),
                      color: currentIndex == 1
                          ? Colors.black87
                          : Colors.black45,
                      onPressed: () {
                        ref.read(shellIndexProvider.notifier).setIndex(1);
                      },
                      tooltip: 'Chats',
                    ),
                    if (unreadChats > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '$unreadChats',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                // Botón central de publicar premium: minimalista, negro plano y ergonómico
                GestureDetector(
                  onTap: () {
                    _navigateToPublish(context);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    currentIndex == 2
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 23,
                  ),
                  color: currentIndex == 2 ? Colors.black87 : Colors.black45,
                  onPressed: () {
                    ref.read(shellIndexProvider.notifier).setIndex(2);
                  },
                  tooltip: 'Favoritos',
                ),
                IconButton(
                  icon: Icon(
                    currentIndex == 3
                        ? Icons.person_rounded
                        : Icons.person_outline_rounded,
                    size: 24,
                  ),
                  color: currentIndex == 3 ? Colors.black87 : Colors.black45,
                  onPressed: () {
                    ref.read(shellIndexProvider.notifier).setIndex(3);
                  },
                  tooltip: 'Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
