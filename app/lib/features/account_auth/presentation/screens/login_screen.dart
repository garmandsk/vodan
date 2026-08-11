import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/presentation/vodan_scaffold.dart';
import 'package:vodan/features/account_auth/data/models/login_request__model.dart';
import '../controllers/account_auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.from,
  });

  final String? from;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscure = true;

  void _submitLoginForm() {
    final isLoading = ref.read(accountAuthControllerProvider).isLoading;
    if (isLoading) return;

    if (_formKey.currentState!.validate()) {
      final loginRequestData = LoginRequestModel(
        email: _emailController.text.trim(), 
        password: _passwordController.text.trim()
      );

      // jalankan proses login
      ref.read(accountAuthControllerProvider.notifier).login(loginRequestData);

      final destination = widget.from;
      if (destination != null || destination!.isNotEmpty) {
        context.go(destination);
      } else {
        const EnterWorkspaceRoute().go(context);
      }
    }
  }

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

    final isLoading = ref.watch(accountAuthControllerProvider).isLoading;

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
                  obscureText: _isPasswordObscure,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: 'Password', 
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscure
                        ? Icons.visibility_off
                        : Icons.visibility
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscure = !_isPasswordObscure;
                        });
                      },
                    )
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong!';
                    } 
                    return null;
                  },
                ),
                const SizedBox(height: 32,),
            
                ElevatedButton(
                  onPressed: isLoading ? null : _submitLoginForm, 
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