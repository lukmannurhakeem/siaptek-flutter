import 'dart:html' as html;

import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  html.BeforeInstallPromptEvent? _installEvent;
  bool _canInstall = false;

  @override
  void initState() {
    super.initState();

    // Detect if the app can be installed (PWA install prompt)
    html.window.addEventListener('beforeinstallprompt', (event) {
      event.preventDefault();
      _installEvent = event as html.BeforeInstallPromptEvent;
      setState(() => _canInstall = true);
    });
  }

  void _installPwa() {
    _installEvent?.prompt();
    _installEvent = null;
    setState(() => _canInstall = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flutter_dash, size: 100, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Base App PWA!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Install this app to use it offline or from your home screen.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _canInstall ? _installPwa : null,
                icon: const Icon(Icons.download),
                label: Text(_canInstall ? 'Install App' : 'Installed / Not Available'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Continue to App →'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
