import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/features/workspace/data/repositories/workspace_repository.dart';

part 'admin_session.g.dart';

class AdminSessionState {
  AdminSessionState({
    this.isLoading = false,
    this.isPinVerified = false,
  });

  final bool isLoading;
  final bool isPinVerified;

  AdminSessionState copyWith({
    bool? isLoading,
    bool? isPinVerified
  }) {
    return AdminSessionState(
      isLoading: isLoading ?? this.isLoading,
      isPinVerified: isPinVerified ?? this.isPinVerified
    );
  }
}

@Riverpod(keepAlive: true) 
class AdminSession extends _$AdminSession {
  Timer? _autoLockTimer;
  static const _timeoutDuration = Duration(minutes: 5);

  @override
  AdminSessionState build() {
    ref.onDispose(() => _autoLockTimer?.cancel());
    return AdminSessionState(); 
  }

  Future<String?> verifyPin(String workspaceId, String pin) async {
    try {
      state = state.copyWith(isLoading: true);

      final repo = ref.read(workspaceRepositoryProvider);
      final isMatch = await repo.verifyPin(workspaceId, pin);
      
      if (isMatch) {
        state = state.copyWith(
          isLoading: false,
          isPinVerified: true
        ); 

        _startAutoLockTimer();
        return null; // Sukses
      }

      state = state.copyWith(isLoading: false);
      return 'PIN Salah! Silakan coba lagi.';
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 'Terjadi kesalahan koneksi: $e';
    }
  }

  void _startAutoLockTimer() {
    _autoLockTimer?.cancel();
    _autoLockTimer = Timer(_timeoutDuration, () {
      state = state.copyWith(isPinVerified: false);
      print("🔒 Auto-Lock Global Aktif: Sesi admin kadaluarsa.");
    });
  }

  void refreshSession() {
    if (state.isPinVerified == true) {
      _startAutoLockTimer();
    }
  }

  void lockScreen() {
    _autoLockTimer?.cancel();
    state = state.copyWith(isPinVerified: false);
  }
}