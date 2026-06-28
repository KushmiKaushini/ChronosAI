// ============================================================================
// ChronosAI — API Key Screen (Onboarding Step 2)
// Author: K K K Ekanayake
// Task: TASK-005 — Wire Up Onboarding Flow
//
// Validates Gemini API key format, saves to secure storage, and navigates
// to permissions. Skip allows demo mode.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/secure_storage_service.dart';

class ApiKeyScreen extends ConsumerStatefulWidget {
  const ApiKeyScreen({super.key});

  @override
  ConsumerState<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends ConsumerState<ApiKeyScreen> {
  final TextEditingController _controller = TextEditingController();
  final SecureStorageService _secureStorage = SecureStorageService();
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final key = _controller.text.trim();

    if (!SecureStorageService.isValidApiKeyFormat(key)) {
      setState(() {
        _errorMessage = 'Invalid API key format. Gemini keys start with "AIza".';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    // Save to secure storage
    await _secureStorage.saveApiKey(key);

    if (mounted) {
      context.go('/onboarding/permissions');
    }
  }

  void _onSkip() {
    // Demo mode — no API key saved
    context.go('/onboarding/permissions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('API Key'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Enter Gemini API Key',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your API key is stored securely on your device. Skip for demo mode.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'AIza...',
                  labelText: 'API Key',
                  errorText: _errorMessage,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _onContinue,
                child: const Text('Continue'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _onSkip,
                child: const Text('Skip (Demo Mode)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
