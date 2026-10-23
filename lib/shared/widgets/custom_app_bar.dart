import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.titleText,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: leading,
      iconTheme: const IconThemeData(color: Colors.black87),
      title: Center(
        child: Text(
          titleText,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: actions ?? [const SizedBox(width: 48)], // Equulibrio simétrico para centrado perfecto si no hay acciones
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
