import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (context.isTablet)
        ? Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/bg.png',
                fit: BoxFit.contain,
                // Covers the screen while keeping aspect ratio
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.bottomCenter,
              ),

              Align(
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  padding: context.paddingAll,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                      0.85,
                    ), // Optional: slightly transparent background
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.contain,
                        width: MediaQuery.of(context).size.width * 0.5,
                      ),
                      context.vXxl,
                      Text(
                        'Enter your registered email address below and we will send you a link to reset your password.',
                        style: context.topology.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      context.vL,
                      CommonTextField(
                        labelText: 'Email',
                        style: context.topology.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                      context.vL,
                      CommonButton(text: 'Submit', onPressed: () {}),
                      context.vS,
                      CommonButton(
                        text: 'Cancel',
                        backgroundColor: context.colors.secondary,
                        onPressed: () {
                          NavigationService().goBack();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
        : //Mobile Apps
        Scaffold(
          body: SafeArea(
            top: true,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/bg.png',
                    fit: BoxFit.contain,
                    // Covers the screen while keeping aspect ratio
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
                Padding(
                  padding: context.paddingAll,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.contain,
                        width: MediaQuery.of(context).size.width * 0.5,
                      ),
                      context.vXxl,
                      Text(
                        'Enter your registered email address below and we will send you a link to reset your password.',
                        style: context.topology.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      context.vL,
                      CommonTextField(
                        labelText: 'Email',
                        style: context.topology.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                      context.vL,
                      CommonButton(text: 'Submit', onPressed: () {}),
                      context.vS,
                      CommonButton(
                        text: 'Cancel',
                        backgroundColor: context.colors.secondary,
                        onPressed: () {
                          NavigationService().goBack();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
