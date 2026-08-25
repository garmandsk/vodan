import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/core/providers/admin_session.dart';

part 'setting_controller.g.dart';

class SettingState {
  SettingState({
    this.isLoading = false,
    this.isBroadcastEnabled = true
  });

  final bool isLoading;
  final bool isBroadcastEnabled;

  SettingState copyWith({
    bool? isLoading,
    bool? isBroadcastEnabled,
  }) {
    return SettingState(
      isLoading: isLoading ?? this.isLoading,
      isBroadcastEnabled: isBroadcastEnabled ?? this.isBroadcastEnabled
    );
  }
}

@riverpod
class SettingController extends _$SettingController {
  @override
  SettingState build() {
    return SettingState();
  }

  void _pingSession() => ref.read(adminSessionProvider.notifier).refreshSession();

  Future<void> toggleBroadcast(bool value) async {
    // TODO: Update ke database tabel workspaces (kolom broadcast_sales misalnya)
    state = state.copyWith(isBroadcastEnabled: value);
    _pingSession();
  }

  Future<String?> changePin(String workspaceId, String newPin) async {
    // TODO: Panggil fungsi update PIN di workspaceRepository
    _pingSession();
    return null;
  }
}