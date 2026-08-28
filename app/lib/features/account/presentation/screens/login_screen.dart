import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_header.dart';
import 'package:vodan/core/presentation/widgets/vodan_text_form_field.dart';

import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/presentation/widgets/vodan_scaffold.dart';
import 'package:vodan/features/account/data/models/login_request__model.dart';
import '../controllers/account_controller.dart';

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
    final isLoading = ref.read(accountControllerProvider).isLoading;
    if (isLoading) return;

    if (_formKey.currentState?.validate() ?? false) {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      // print('email: $email');
      // print('password: $password');

      final loginRequestData = LoginRequestModel(
        email: email, 
        password: password
      );

      // jalankan proses login
      ref.read(accountControllerProvider.notifier).login(loginRequestData);

      final destination = widget.from;
      if (destination != null && destination.isNotEmpty) {
        context.go(destination);
      } else {
        const LoginRoute().go(context);
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
      accountControllerProvider,
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

    final isLoading = ref.watch(accountControllerProvider).isLoading;

    return VodanScaffold(
      title: 'Masuk ke VoDan',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.
            stretch,
            spacing: 16,
            children: [
              VodanHeader(
                icon: Icons.login_rounded, 
                title: 'Selamat Datang Kembali!',
                titleStyle: Theme.of(context).textTheme.headlineMedium,
              ),
          
              VodanTextFormField(
                labelText: 'Email',
                hintText: 'udin@email.com',
                prefixIcon: Icons.email_outlined,
                controller: _emailController,
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
      
              VodanTextFormField(
                labelText: 'Kata Sandi',
                hintText: '******',
                prefixIcon: Icons.lock_outline,
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
                  ),
                controller: _passwordController,
                obscureText: _isPasswordObscure,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kata Sandi tidak boleh kosong!';
                  } 
                  return null;
                },
              ),
              const SizedBox(height: 16,),
      
          
              VodanActionButton(
                text: 'Masuk', 
                isLoading: isLoading,
                onPressed: _submitLoginForm
              ),
      
              VodanActionButton(
                text: 'Belum punya akun? Daftar di sini', 
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                foregroundColor: Theme.of(context).colorScheme.primary,
                elevation: 0,
                onPressed: () => const RegisterRoute().go(context)
              )
            ],
          ),
        ),
      )
    );
  }
}