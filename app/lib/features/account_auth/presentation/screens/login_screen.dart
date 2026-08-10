import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/presentation/vodan_scaffold.dart';
import '../controllers/account_auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      accountAuthControllerProvider,
      (_, state) {
        if (state.isLoading) return;

        state.when(
          data: (_) {
            // Jika sukses login
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login Berhasil 🎉')),
            );
          }, 
          error: ((error, stackTrace) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal login: ${error.toString()}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              )
            );
          }), 
          loading: () {}
        );
      }
    );

    final authState = ref.watch(accountAuthControllerProvider);
    final isLoading = authState.isLoading;

    return VodanScaffold(
      title: 'Masuk ke VoDan',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.login_rounded, size: 64, color: Theme.of(context).primaryColor,),
                const SizedBox(height: 24,),
                Text(
                  'Selemat Datang Kembali!', 
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32,),
            
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Format tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16,),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong!';
                    } 
                    return null;
                  },
                ),
                const SizedBox(height: 32,),
            
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                        ref.read(accountAuthControllerProvider.notifier).login(
                          _emailController.text.trim(),
                          _passwordController.text.trim()
                        );
                      }, 
                  child: isLoading 
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2,),
                      )
                      : const Text('Masuk')
                ),
                
                const SizedBox(height: 16,),
                TextButton(
                  onPressed: () => const RegisterRoute().go(context), 
                  child: const Text('Belum punya akun? Daftar di sini') 
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}