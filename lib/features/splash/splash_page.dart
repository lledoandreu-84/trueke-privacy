import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double logoSize = screenSize.width * 0.70;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Center(
          child: SizedBox(
            width: logoSize,
            height: logoSize,
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
