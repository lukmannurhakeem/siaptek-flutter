import 'dart:async';

import 'package:base_app/providers/authenticate_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget with RouteAware {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      _checkLoginStatus();
    });

    // 🔥 SAFETY TIMEOUT: Force navigation after 10 seconds if stuck
    Timer(const Duration(seconds: 10), () {
      if (!_hasNavigated && mounted) {
        debugPrint('⚠️ TIMEOUT: Splash screen stuck, forcing navigation to login');
        _navigateToLogin();
      }
    });
  }

  Future<void> _checkLoginStatus() async {
    if (_hasNavigated) return;

    try {
      debugPrint('🚀 Checking login status from splash...');
      final provider = context.read<AuthenticateProvider>();

      // Add timeout to verifyToken call
      await provider
          .verifyToken(context)
          .timeout(
            const Duration(seconds: 7),
            onTimeout: () {
              debugPrint('⏰ Token verification timed out, navigating to login');
              if (!_hasNavigated && mounted) {
                _navigateToLogin();
              }
            },
          );

      debugPrint('✅ Login check completed');
    } catch (e) {
      debugPrint('❌ Login check error: $e');
      if (!_hasNavigated && mounted) {
        _navigateToLogin();
      }
    }
  }

  void _navigateToLogin() {
    if (_hasNavigated) return;

    _hasNavigated = true;
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Stack(
          children: [
            // 🔄 Logo animation
            Positioned.fill(
              child: Center(
                child: FadeTransition(
                  opacity: _animation,
                  child: ScaleTransition(
                    scale: _animation,
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: FadeTransition(
                opacity: _animation,
                child: Image.asset(
                  'assets/images/bg.png',
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
