import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_header.dart';

import 'package:vodan/core/presentation/widgets/vodan_scaffold.dart';
import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/features/workspace_auth/presentation/controllers/workspace_auth_controller.dart';
import '../../data/models/create_workspace_request_model.dart';

class _AiKeyFormRow {
  String provider = 'Gemini';
  final TextEditingController keyController = TextEditingController();
  bool isObscure = true;

  void dispose() {
    keyController.dispose();
  }
}
class CreateWorkspaceScreen extends ConsumerStatefulWidget {
  const CreateWorkspaceScreen({super.key});

  @override
  ConsumerState<CreateWorkspaceScreen> createState() => _CreateWorkspaceScreenState();
}

class _CreateWorkspaceScreenState extends ConsumerState<CreateWorkspaceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _adminPinController = TextEditingController();

  final List<_AiKeyFormRow> _aiKeyRows = [_AiKeyFormRow()];

  bool _isAdminPinObscure = true;

  void _submitCreateWorkspaceForm() async {
    final isLoading = ref.read(workspaceAuthControllerProvider).isLoading;
    if (isLoading) return;

    if (_formKey.currentState!.validate()) {
      final List<AiCredential> aiCredential = _aiKeyRows
          .where((row) => row.keyController.text.trim().isNotEmpty)
          .map((row) => AiCredential(
            provider: row.provider,
            key: row.keyController.text.trim(),
          ))
          .toList();

      final requestData = CreateWorkspaceRequestModel(
        name: _nameController.text.trim(), 
        adminPin: _adminPinController.text.trim(), 
        aiKeys: aiCredential
      );

      final String? newWorkspaceId = await ref.read(workspaceAuthControllerProvider.notifier).createWorkspace(requestData);
      print('Workspace iD Baru: $newWorkspaceId');
      
      // redirect ke halaman sukses pembuatan lapak
      if (newWorkspaceId != null && mounted) {
        WorkspaceCreatedRoute(workspaceId: newWorkspaceId).go(context);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _adminPinController.dispose();

    for (var row in _aiKeyRows) {
      row.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      workspaceAuthControllerProvider,
      (_, state) {
        if (state.isLoading) return;

        state.when(
          data: (_) {
            // Jika sukses membuat lapak
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pembuatan Lapak Berhasil 🎉')),
            );
          }, 
          error: ((error, stackTrace) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal Membuat Lapak: ${error.toString()}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              )
            );
          }), 
          loading: () {}
        );
      }
    );

    final isLoading = ref.watch(workspaceAuthControllerProvider).isLoading;

    return VodanScaffold(
      title: 'Buat Lapak Baru',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              VodanHeader(
                icon: Icons.rocket_launch_rounded, 
                title: 'Siapkan Lapak Pintarmu',
                subtitle: 'Ayo siapkan!',
                subtitleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              ),
      
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lapak / Toko', prefixIcon: Icon(Icons.store_outlined)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Lapak tidak boleh kosong!';
                  }
                  return null;
                },
              ),
      
              TextFormField(
                controller: _adminPinController,
                obscureText: _isAdminPinObscure,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Pin Admin Lapak', 
                  prefixIcon: Icon(Icons.dialpad),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isAdminPinObscure 
                      ? Icons.visibility_off 
                      : Icons.visibility
                    ),
                    onPressed: () {
                      setState(() {
                        _isAdminPinObscure = !_isAdminPinObscure;
                      });
                    }
                  )
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6)
                ],
                validator: (value) {
                  if (value!.length < 6 || value.length > 6) {
                    return 'Pin Harus berjumlah 6 angka';
                  }
                  return null;
                },
              ),
      
              Text(
                'Konfigurasi AI API Key',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              ..._aiKeyRows.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;
      
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: row.provider,
                          decoration: const InputDecoration(
                            labelText: 'Provider',
                            prefixIcon: Icon(Icons.assistant)
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Gemini', child: Text('Gemini')),
                            DropdownMenuItem(value: 'OpenAI', child: Text('OpenAI (Segera)')),
                            DropdownMenuItem(value: 'Claude', child: Text('Claude (Segera)')),
                          ],
                          onChanged: isLoading ? null: (value) {
                            if (value != 'Gemini') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Provider ${value?.replaceAll(' (Segera)', 'replace')} belum tersedia. Nantikan segera! 🚀'),
                                  backgroundColor: Colors.blueGrey,
                                  duration: const Duration(seconds: 2),
                                )
                              );
      
                              setState(() {
                                row.provider = 'Gemini';
                              });
                              return;
                            }
      
                            setState(() {
                              row.provider = value!;
                            });
                          }
                        )
                      ),
                      const SizedBox(width: 12,),
      
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: row.keyController,
                          obscureText: row.isObscure,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            labelText: 'API Key',
                            prefixIcon: Icon(Icons.key_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                row.isObscure 
                                ? Icons.visibility_off
                                : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  row.isObscure = !row.isObscure;
                                });
                              },
                            )
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'API Key wajib diisi';
                            }
                            return null;
                          },
                        ),
                      ),
      
                      if (_aiKeyRows.length > 1) ...[
                        const SizedBox(width: 8,),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: isLoading ? null : () {
                            setState(() {
                              _aiKeyRows[index].dispose();
                              _aiKeyRows.removeAt(index);
                            });
                          },
                        )
                      ]
                    ],
                  ),
                );
              }),
      
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Key'),
                  onPressed: isLoading ? null : () {
                    setState(() {
                      _aiKeyRows.add(_AiKeyFormRow());
                    });
                  },
                ),
              ),
              const SizedBox(height: 32,),
      
              VodanActionButton(
                text: 'Buka Lapak Sekarang', 
                onPressed: isLoading ? null : _submitCreateWorkspaceForm
              ),
            ],
          ),
        ),
      ),
    );
  }
}