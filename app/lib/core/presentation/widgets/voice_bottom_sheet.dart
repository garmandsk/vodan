import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_text_form_field.dart';
import 'package:vodan/features/workspace/presentation/controllers/stt_service_controller.dart';
import 'package:vodan/features/workspace/presentation/controllers/tts_service_controller.dart';
import 'package:vodan/features/workspace/presentation/controllers/voice_transaction_controller.dart';

class VoiceBottomSheet extends ConsumerStatefulWidget {
  final String workspaceId;

  const VoiceBottomSheet({
    super.key,
    required this.workspaceId,
  });

  @override
  ConsumerState<VoiceBottomSheet> createState() => _VoiceBottomSheetState();
}

class _VoiceBottomSheetState extends ConsumerState<VoiceBottomSheet> {
  late TextEditingController _userController;
  late TextEditingController _aiController;

  List<String> _availableLanguages = ['id-ID', 'en-US'];

  bool _isAdvancedMode = false;

  Future<void> _fetchLanguages() async {
    final availableLanguages = await ref.read(ttsServiceControllerProvider.notifier).getAvailableLanguages();
    if (mounted) {
      setState(() {
        _availableLanguages = availableLanguages;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _userController = TextEditingController();
    _aiController = TextEditingController();
    _fetchLanguages();
  }

  @override
  void dispose(){
    print('controller dihapus');

    _userController.dispose();
    _aiController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final voiceState = ref.watch(voiceTransactionControllerProvider);
    final speechText = ref.watch(sttServiceControllerProvider).recognizedText;
    final ttsConfig = ref.watch(ttsServiceControllerProvider);
    final isSpeaking = ref.watch(ttsServiceControllerProvider).isSpeaking;
    final availableLanguages = ref.watch(ttsServiceControllerProvider.notifier).getAvailableLanguages();

    String titleText = 'Asisten Suara Siap';
    Widget centerIcon = Icon(Icons.mic_none_rounded, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5));
    String subText = 'Silahkan bicara...';

    if (voiceState == VoiceState.listening) {
      titleText = 'Mendengarkan...';
      centerIcon = Icon(Icons.mic_rounded, size: 64, color: theme.colorScheme.primary);
      subText = speechText.isEmpty ? 'Mendengarkan suara Anda...' : speechText;
    } else if (voiceState == VoiceState.processing && !isSpeaking) {
      titleText = 'Memproses Pesanan...';
      centerIcon = const CircularProgressIndicator();
      subText = speechText.isEmpty ? 'Menunggu respons...' : speechText;
    } else if (isSpeaking) {
      titleText = 'AI Berbicara...';
      centerIcon = Icon(Icons.record_voice_over_rounded, size: 64, color: theme.colorScheme.primary);
      subText = speechText; 
    } else if (voiceState == VoiceState.successTransaction) {
      titleText = 'Berhasil!';
      centerIcon = const Icon(Icons.check_circle_rounded, size: 64, color: Colors.green);
      subText = 'Pesanan tercatat di keranjang.';
    } else if (voiceState == VoiceState.successChat) {
      titleText = 'Obrolan Selesai';
      centerIcon = Icon(Icons.chat_bubble_rounded, size: 64, color: theme.colorScheme.primary);
      subText = speechText;
    } else if (voiceState == VoiceState.error) {
      titleText = 'Gagal Memproses';
      centerIcon = Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error);
      subText = 'Silakan coba lagi.';
    }

    final canReplay = voiceState == VoiceState.successTransaction || 
                      voiceState == VoiceState.successChat || 
                      voiceState == VoiceState.error; 

    ref.listen<VoiceState>(voiceTransactionControllerProvider, (_, state) {
      if (state == VoiceState.successTransaction) {
        if (context.mounted) {
          Navigator.pop(context); 
        }
      }
    });

    ref.listen(sttServiceControllerProvider, ((previous, next) {
      if (next.recognizedText != _userController.text) {
        _userController.text = next.recognizedText;
        _userController.selection = TextSelection.fromPosition(
          TextPosition(offset: _userController.text.length)
        );
      }
    }));

    ref.listen(ttsServiceControllerProvider, ((previous, next) {
      if (next.text != _aiController.text) {
        _aiController.text = next.text;
        _aiController.selection = TextSelection.fromPosition(
          TextPosition(offset: _aiController.text.length)
        );
      }
    }));


    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 48),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: _isAdvancedMode 
          ? _buildAdvance(theme, ttsConfig, availableLanguages, titleText, centerIcon, _userController, _aiController, canReplay) 
          : _buildBasic(theme, titleText, subText, centerIcon, canReplay)
    );
  }

  Widget _buildBasic(ThemeData theme, String titleText, String subText, Widget centerIcon, bool canReplay) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        _buildHeader(theme, titleText),
        
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: centerIcon,
        ),
        
        Text(
          subText,
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    alignment: Alignment.center, 
                    child: child,
                  ),
                );
              },
              child: canReplay
                  ? Padding(
                      key: const ValueKey('btn_replay_show'),
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: VodanActionButton(
                        text: 'Putar Ulang Suara',
                        prefixIcon: Icons.replay_circle_filled_rounded,
                        onPressed: () => ref.read(ttsServiceControllerProvider.notifier).replay(),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('btn_replay_hide')),
            ),
          ],
        ),
        
        _buildFooter(theme)
      ],
    );
  } 

  Widget _buildAdvance(ThemeData theme, TtsConfig ttsConfig, availableLanguage, String titleText, Widget centerIcon, TextEditingController userController, TextEditingController aiController, bool canReplay) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          DropdownButton<String>(
            value: _availableLanguages.contains(ttsConfig.languageCode)
                ? ttsConfig.languageCode
                : _availableLanguages.first,
            items: _availableLanguages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
            onChanged: (val) {
              if (val != null) {
                ref.read(ttsServiceControllerProvider.notifier).setLanguageCode(val);
              }
            }
          ),
          _buildHeader(theme, titleText),

          // AnimatedSwitcher(
          //   duration: const Duration(milliseconds: 300),
          //   child: centerIcon,
          // ),
          
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom Pengguna (Kiri)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VodanTextFormField(
                      controller: userController,
                      labelText: 'Suara Anda / Ketik:',
                      hintText: 'Ucap / Ketik pesanan...',
                      prefixIcon: Icons.person,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send_rounded),
                        onPressed: () {
                          final text = userController.text;
                          if (text.trim().isNotEmpty) {
                            ref.read(voiceTransactionControllerProvider.notifier)
                                .processManualText(text, widget.workspaceId);
                          }
                        },
                      ),
                      maxLines: 3,
                      onSubmitted: (text) async => await ref.read(voiceTransactionControllerProvider.notifier)
                          .processManualText(text, widget.workspaceId),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Kolom AI (Kanan)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VodanTextFormField(
                      controller: aiController,
                      labelText: 'Respons AI',
                      hintText: 'Respons AI......',
                      prefixIcon: Icons.smart_toy,
                      maxLines: 3,
                      onChanged: (text) => ref.read(ttsServiceControllerProvider.notifier).setText(text),
                    ),
                  ],
                ),
              ),
            ],
          ),

          _buildTtsControls(theme),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16,
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        alignment: Alignment.center, 
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    key: const ValueKey('btn_replay_show'),
                    padding: const EdgeInsets.only(bottom: 0.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: VodanActionButton(
                        text: canReplay 
                            ? 'Putar Ulang' 
                            : 'Putar',
                        prefixIcon: canReplay 
                            ? Icons.replay_circle_filled_rounded
                            : Icons.play_arrow_rounded,
                        onPressed: () => ref.read(ttsServiceControllerProvider.notifier).replay(),
                      ),
                    ),
                  )
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: VodanActionButton(
                      text: 'AI Default', 
                      prefixIcon: Icons.settings_backup_restore_rounded,
                      onPressed: () => ref.read(ttsServiceControllerProvider.notifier).defaultAiTts()
                    ),
                  ),
                ),
              )
            ],
          ),
          
          _buildFooter(theme)
        ],
    );
  }

  Widget _buildTtsControls(ThemeData theme) {
    final ttsConfig = ref.watch(ttsServiceControllerProvider);

    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Text('Kecepatan Suara: ${ttsConfig.rate.toStringAsFixed(1)}x', 
            style: theme.textTheme.bodySmall),
        Slider(
          value: ttsConfig.rate,
          min: 0.5,
          max: 2.0,
          divisions: 15,
          onChanged: (val) {
            print('ngubah rate ke $val');
            // Update konfigurasi secara real-time
            ref.read(ttsServiceControllerProvider.notifier).setRate(val);
          },
        ),
        Text('Nada Suara (Pitch): ${ttsConfig.pitch.toStringAsFixed(1)}', 
            style: theme.textTheme.bodySmall),
        Slider(
          value: ttsConfig.pitch,
          min: 0.5,
          max: 2.0,
          divisions: 15,
          onChanged: (val)  {
            ref.read(ttsServiceControllerProvider.notifier).setPitch(val);
          },
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, String titleText){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titleText, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Text('Advance', style: theme.textTheme.bodySmall),
            const SizedBox(width: 4),
            Switch(
              value: _isAdvancedMode,
              onChanged: (val) {
                // if (_isAdvancedMode) dispose();
                setState(() {
                  _isAdvancedMode = val;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Text(
      'Lepas tombol di bawah untuk memproses',
      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
    );
  }
}