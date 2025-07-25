import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/authenticate_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
          body: Align(
            alignment: Alignment.center,
            child: Container(
              width: MediaQuery.of(context).size.width / 3,
              padding: context.paddingAll,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo-uthm.png',
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                  context.vXxl,
                  CommonTextField(
                    labelText: 'Username',
                    controller: _usernameController,
                    style: context.topology.textTheme.bodyMedium?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  context.vM,
                  CommonTextField(
                    labelText: 'Password',
                    controller: _passwordController,
                    style: context.topology.textTheme.bodyMedium?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  context.vL,
                  Consumer<AuthenticateProvider>(
                    builder: (context, provider, child) {
                      return CommonButton(
                        text: 'Login',
                        onPressed: () {
                          provider.login(
                            context,
                            _usernameController.text,
                            _passwordController.text,
                          );
                        },
                      );
                    },
                  ),
                  context.vS,
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        NavigationService().navigateTo(AppRoutes.forgotPassword);
                      },
                      child: Text(
                        'Forgot Password?',
                        style: context.topology.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        : //Mobile Apps
        Scaffold(
          body: SafeArea(
            top: true,
            child: Stack(
              children: [
                Positioned.fill(
                  child: SvgPicture.asset(
                    'assets/images/blob-background.svg',
                    fit: BoxFit.contain,
                    // Covers the screen while keeping aspect ratio
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.topCenter,
                  ),
                ),
                Positioned.fill(
                  child: SvgPicture.asset(
                    'assets/images/circle-background.svg',
                    fit: BoxFit.contain,
                    // Covers the screen while keeping aspect ratio
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.bottomLeft,
                  ),
                ),
                Positioned.fill(
                  child: SvgPicture.asset(
                    'assets/images/circle-background-secondary.svg',
                    fit: BoxFit.contain,
                    // Covers the screen while keeping aspect ratio
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.bottomLeft,
                  ),
                ),
                Padding(
                  padding: context.paddingAll,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo-uthm.png',
                        fit: BoxFit.contain,
                        width: MediaQuery.of(context).size.width * 0.5,
                      ),
                      context.vXxl,
                      CommonTextField(
                        labelText: 'Email',
                        controller: _usernameController,
                        style: context.topology.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                        suffixIcon: Icon(Icons.email, color: context.colors.primary),
                      ),
                      context.vM,
                      CommonTextField(
                        labelText: 'Password',
                        controller: _passwordController,
                        style: context.topology.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                        suffixIcon: Icon(Icons.lock, color: context.colors.primary),
                      ),
                      context.vL,
                      Consumer<AuthenticateProvider>(
                        builder: (context, provider, child) {
                          return CommonButton(
                            text: 'Login',
                            onPressed: () {
                              provider.login(
                                context,
                                _usernameController.text,
                                _passwordController.text,
                              );
                            },
                          );
                        },
                      ),
                      context.vS,
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            NavigationService().navigateTo(AppRoutes.forgotPassword);
                          },
                          child: Text(
                            'Forgot Password?',
                            style: context.topology.textTheme.bodyMedium?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
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
