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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Padding(
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
              CommonButton(
                text: 'Submit',
                onPressed: () {},
              ),
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
    );
  }
}
