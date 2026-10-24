import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Image.asset(
            'assets/images/logo.png',
            width: 170,
            height: 170,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
