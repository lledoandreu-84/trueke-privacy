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
    // Determinamos si hay un botón de retroceso (explícito o automático por la navegación)
    final bool hasLeading = leading != null || Navigator.canPop(context);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: leading ??
          (Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
      // Añadimos un actions invisible o simétrico si no hay acciones, 
      // para forzar que el título quede geométricamente centrado al 100%
      actions: actions ?? (hasLeading ? [const SizedBox(width: 48)] : null),
      title: Text(
        titleText,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
