import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_header.dart';
import 'package:vodan/core/presentation/widgets/vodan_text_form_field.dart';

import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/presentation/widgets/vodan_scaffold.dart';
import 'package:vodan/features/account/data/models/register_request_model.dart';
import '../controllers/account_controller.dart';

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

  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  void _submitRegisterForm() {
    final isLoading = ref.read(accountControllerProvider).isLoading;
    if (isLoading) return;

    if (_formKey.currentState!.validate()) {
      final registerRequestData = RegisterRequestModel(
        email: _emailController.text.trim(), 
        password: _passwordController.text.trim(), 
        displayName: _nameController.text.trim()
      );

      ref.read(accountControllerProvider.notifier).register(registerRequestData);
      
      // Redirect ke login saat register berhasil
      LoginRoute().go(context);
    }
  }

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
      accountControllerProvider,
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
          }, 
          error: (error, stackTrace) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal Mendaftar: ${error.toString()}'), backgroundColor: Theme.of(context).colorScheme.error,));
          }, 
          loading: () {}
        );
      }
    );

    final authState = ref.watch(accountControllerProvider);
    final isLoading = authState.isLoading;

    return VodanScaffold(
      title: 'Daftar Akun VoDan',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              VodanHeader(
                icon: Icons.person_add_alt_1_rounded, 
                title: 'Buat Akun',
                titleStyle: Theme.of(context).textTheme.headlineMedium,
                subtitle: 'Langkah pertama untuk membuat lapak barumu.',
                subtitleStyle: Theme.of(context).textTheme.bodyMedium,
              ),
          
              VodanTextFormField(
                labelText: 'Nama',
                hintText: 'Udin Idun',
                prefixIcon: Icons.person,
                controller: _nameController,
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
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
                prefixIcon: Icons.lock_clock_outlined,
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
                  if (value.length < 6) {
                    return 'Kata Sandi minimal 6 karakter';
                  }
                  return null;
                },
              ),
      
              VodanTextFormField(
                labelText: 'Konfirmasi Kata Sandi',
                hintText: '******', 
                prefixIcon: Icons.screen_lock_landscape_outlined,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordObscure
                    ? Icons.visibility_off
                    : Icons.visibility
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
                    });
                  },
                ),
                controller: _confirmPasswordController,
                obscureText: _isConfirmPasswordObscure,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi Kata Sandi tidak boleh kosong!';
                  }
                  if (value != _passwordController.text.trim()) {
                    return 'Kata Sandi tidak sama!';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16,),
          
              VodanActionButton(
                text: 'Daftar Sekarang', 
                isLoading: isLoading,
                onPressed: _submitRegisterForm
              ),
              VodanActionButton(
                text: 'Sudah punya akun? Masuk di sini', 
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                foregroundColor: Theme.of(context).colorScheme.primary,
                elevation: 0,
                onPressed: () => LoginRoute().go(context)
              )
            ],
          ),
        ),
      )
    );
  }
}