import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/presentation/vodan_scaffold.dart';
import '../controllers/account_auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registrasi Berhasil! Silahkan cek email verifikasi atau langsung login. 🎉'), 
                backgroundColor: Colors.green,
              )
            );

            // Redirect ke login saat register berhasil
            LoginRoute().go(context);
          }, 
          error: (error, stackTrace) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal Mendaftar: ${error.toString()}'), backgroundColor: Theme.of(context).colorScheme.error,));
          }, 
          loading: () {}
        );
      }
    );

    final authState = ref.watch(accountAuthControllerProvider);
    final isLoading = authState.isLoading;

    return VodanScaffold(
      title: 'Daftar Akun VoDan',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.person_add_alt_1_rounded, size: 64, color: Theme.of(context).primaryColor,),
                Text('Buat Akun', style: Theme.of(context).textTheme.headlineMedium,),
                const SizedBox(height: 8,),
                Text('Langkah pertama untuk membuat lapak barumu.', style: Theme.of(context).textTheme.bodyMedium,),
                const SizedBox(height: 32,),
            
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama', prefixIcon: Icon(Icons.person_outline)),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16,),
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
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_clock_outlined)),
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong!';
                    } 
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16,),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Konfirmasi Password', prefixIcon: Icon(Icons.screen_lock_landscape_outlined)),
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi Password tidak boleh kosong!';
                    }
                    if (value != _passwordController.text.trim()) {
                      return 'Password tidak sama!';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32,),
            
                ElevatedButton(
                  onPressed: isLoading
                      ? null  
                      : () {
                        if (_formKey.currentState!.validate()) {
                          ref.read(accountAuthControllerProvider.notifier).register(
                            _nameController.text.trim(),
                            _emailController.text.trim(),
                            _passwordController.text.trim()
                          );
                        }
                      },             
                  child: isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2,),
                      )
                      : const Text('Daftar Sekarang'),
                ),
                const SizedBox(height: 16,),
                TextButton(
                  onPressed: () {
                    LoginRoute().go(context);
                  },
                  child: const Text('Sudah punya akun? Masuk di sini')
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}