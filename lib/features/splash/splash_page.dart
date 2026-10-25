import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Center(
          child: Image.asset(
            'assets/images/logo.png',
            width: screenSize.width * 0.65,
            height: screenSize.width * 0.65,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
