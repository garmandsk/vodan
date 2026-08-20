import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_bottom_sheet.dart';
import 'package:vodan/features/workspace/presentation/controllers/stt_service_controller.dart';
import 'package:vodan/features/workspace/presentation/controllers/tts_service_controller.dart';
import 'package:vodan/features/workspace/presentation/controllers/voice_transaction_controller.dart';

class VoiceBottomSheet extends ConsumerStatefulWidget {
  final String workspaceId;

  const VoiceBottomSheet({
    super.key,
    required this.workspaceId,
  });

  static Future<bool> show(BuildContext context, WidgetRef ref, String workspaceId) async {
    
    await VodanBottomSheet.show(
      context: context,
      child: VoiceBottomSheet(workspaceId: workspaceId),
    );

    final currentState = ref.read(voiceTransactionControllerProvider);
    final isTransactionSuccess = currentState == VoiceState.successTransaction;

    if (currentState == VoiceState.listening) {
      ref.read(sttServiceControllerProvider.notifier).stopListening();
    }
    ref.read(ttsServiceControllerProvider.notifier).stop();
    ref.read(voiceTransactionControllerProvider.notifier).resetToIdle();

    return isTransactionSuccess;
  }

  @override
  ConsumerState<VoiceBottomSheet> createState() => _VoiceBottomSheetState();
}

class _VoiceBottomSheetState extends ConsumerState<VoiceBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceTransactionControllerProvider);
    final speechText = ref.watch(sttServiceControllerProvider).recognizedText;
    final isSpeaking = ref.watch(ttsServiceControllerProvider);
    final theme = Theme.of(context);

    String titleText = 'Asisten Suara Siap';
    Widget centerIcon = Icon(Icons.mic_none_rounded, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5));
    String subText = 'Tekan & tahan tombol di bawah untuk bicara';

    if (voiceState == VoiceState.listening) {
      titleText = 'Mendengarkan...';
      centerIcon = Icon(Icons.mic_rounded, size: 64, color: theme.colorScheme.primary);
      subText = speechText.isEmpty ? 'Silahkan bicara...' : speechText;
    }  else if (voiceState == VoiceState.processing && !isSpeaking) {
      titleText = 'Memproses Pesanan...';
      centerIcon = const CircularProgressIndicator();
      subText = speechText;
    } else if (isSpeaking) {
      titleText = 'AI Berbicara...';
      centerIcon = Icon(Icons.record_voice_over_rounded, size: 64, color: theme.colorScheme.primary);
      subText = speechText; 
    } else if (voiceState == VoiceState.successTransaction) {
      titleText = 'Berhasil!';
      centerIcon = const Icon(Icons.check_circle_rounded, size: 64, color: Colors.green);
      subText = 'Pesanan tercatat di keranjang.';
    } else if (voiceState == VoiceState.successChat) {
      titleText = 'Mengobrol...';
      centerIcon = Icon(Icons.chat, size: 64, color: theme.colorScheme.primary);
      subText = speechText;
    } else if (voiceState == VoiceState.error) {
      titleText = 'Gagal Memproses';
      centerIcon = Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error);
      subText = 'Silakan coba lagi.';
    }

    final isIdle = voiceState == VoiceState.idle || 
        voiceState == VoiceState.successTransaction || 
        voiceState == VoiceState.successChat || 
        voiceState == VoiceState.error;

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(titleText, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: centerIcon,
        ),
        
        const SizedBox(height: 32),
        
        Text(
          subText,
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16),
        ),
        
        const SizedBox(height: 48),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            GestureDetector(
              onTapDown: isIdle && !isSpeaking ? (_) {
                ref.read(voiceTransactionControllerProvider.notifier).startRecording();
              } : null,
              
              onTapUp: (_) => _stopAndProcess(),
              onTapCancel: () => _stopAndProcess(),
              
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: voiceState == VoiceState.listening 
                      ? theme.colorScheme.error 
                      : (isSpeaking ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.primaryContainer),
                  boxShadow: voiceState == VoiceState.listening
                      ? [BoxShadow(color: theme.colorScheme.error.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 5)]
                      : [],
                ),
                child: Icon(
                  Icons.mic_rounded,
                  size: 40,
                  color: voiceState == VoiceState.listening 
                      ? theme.colorScheme.onError 
                      : (isSpeaking ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onPrimaryContainer),
                ),
              ),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    alignment: Alignment.centerRight,
                    child: child,
                  ),
                );
              },
              child: canReplay
                  ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: VodanActionButton(
                      text: 'Putar Ulang Suara',
                      prefixIcon: Icons.replay_circle_filled_rounded,
                      onPressed: canReplay
                          ? () => ref.read(ttsServiceControllerProvider.notifier).replay()
                          : null
                    ),
                  )
                  : const SizedBox.shrink(
                    key: ValueKey('btn_replay_hide'),
                  )
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        Text(
          'Tahan untuk bicara',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }

  void _stopAndProcess() {
    final currentState = ref.read(voiceTransactionControllerProvider);
    if (currentState == VoiceState.listening) {
      ref.read(voiceTransactionControllerProvider.notifier).stopAndProcess(widget.workspaceId);
    }
  }
}