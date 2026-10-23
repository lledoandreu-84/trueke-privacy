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
    final bool canPop = Navigator.canPop(context);
    final Widget? computedLeading = leading ?? 
        (canPop 
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                onPressed: () => Navigator.of(context).pop(),
              ) 
            : null);

    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Título con centrado geométrico absoluto en el ancho total de la pantalla
              Positioned.fill(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64.0),
                    child: Text(
                      titleText,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // 2. Botón izquierdo (Leading o flecha de retroceso)
              if (computedLeading != null)
                Positioned(
                  left: 4,
                  child: computedLeading,
                ),
              // 3. Acciones derechas
              if (actions != null && actions!.isNotEmpty)
                Positioned(
                  right: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
