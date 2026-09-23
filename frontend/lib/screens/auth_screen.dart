import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override State<AuthScreen> createState() => _AuthScreenState();
}
class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController(), password = TextEditingController();
  final auth = AuthService();
  bool register = false, busy = false;
  String? error;
  @override void dispose() { email.dispose(); password.dispose(); super.dispose(); }
  Future<void> submit() async {
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.text.trim()) || password.text.length < 6) {
      setState(() => error = 'Enter a valid email and a password of at least 6 characters.'); return;
    }
    setState(() { busy = true; error = null; });
    try {
      if (register) {
        await auth.register(email.text.trim(), password.text);
      } else {
        await auth.login(email.text.trim(), password.text);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => error = switch (e.code) {
        'email-already-in-use' => 'This email is already registered.',
        'invalid-email' => 'Enter a valid email address.',
        'weak-password' => 'Choose a stronger password.',
        _ => 'Sign-in failed. Check your email, password, and connection.',
      });
    } catch (_) { if (mounted) setState(() => error = 'Authentication unavailable. Check your connection.'); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(body: Center(child: SingleChildScrollView(
    padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Icon(Icons.account_balance_wallet_outlined, size: 52), const SizedBox(height: 16),
      Text(register ? 'Create account' : 'Welcome back', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 20), TextField(controller: email, keyboardType: TextInputType.emailAddress, autocorrect: false, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
      const SizedBox(height: 12), TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), onSubmitted: (_) => busy ? null : submit()),
      if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
      const SizedBox(height: 20), FilledButton(onPressed: busy ? null : submit, child: Text(busy ? 'Please wait…' : (register ? 'Register' : 'Log in'))),
      TextButton(onPressed: busy ? null : () => setState(() { register = !register; error = null; }), child: Text(register ? 'Already have an account? Log in' : 'New here? Register')),
    ])),
  )));
}

