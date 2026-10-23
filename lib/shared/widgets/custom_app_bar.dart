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
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      iconTheme: const IconThemeData(color: Colors.black87),
      title: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              titleText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (leading != null || Navigator.canPop(context))
            Positioned(
              left: 0,
              child: leading ??
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
            ),
          if (actions != null && actions!.isNotEmpty)
            Positioned(
              right: 0,
              child: Row(mainAxisSize: MainAxisSize.min, children: actions!),
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
