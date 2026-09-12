import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _S();
}

class _S extends ConsumerState<AuthScreen> {
  final login = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController();
  bool register = false;
  @override
  Widget build(BuildContext c) {
    final a = ref.watch(authProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.sports_esports,
                    size: 64,
                    color: Theme.of(c).colorScheme.primary,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Checkpoint',
                    textAlign: TextAlign.center,
                    style: Theme.of(c).textTheme.displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    register
                        ? 'Create your player profile'
                        : 'Welcome back to your backlog',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: login,
                    decoration: InputDecoration(
                      labelText: register ? 'Username' : 'Username or email',
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  if (register) ...[
                    const SizedBox(height: 14),
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  if (a.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        a.error!,
                        style: TextStyle(color: Theme.of(c).colorScheme.error),
                      ),
                    ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: a.loading
                        ? null
                        : () {
                            if (register) {
                              ref
                                  .read(authProvider.notifier)
                                  .register(
                                    login.text.trim(),
                                    email.text.trim(),
                                    password.text,
                                  );
                            } else {
                              ref
                                  .read(authProvider.notifier)
                                  .login(login.text.trim(), password.text);
                            }
                          },
                    child: a.loading
                        ? const CircularProgressIndicator()
                        : Text(register ? 'Create account' : 'Log in'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => register = !register),
                    child: Text(
                      register
                          ? 'Already have an account? Log in'
                          : 'New player? Create account',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
