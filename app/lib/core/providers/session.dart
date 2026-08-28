import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:vodan/features/workspace/data/repositories/workspace_repository.dart';
import 'package:vodan/features/workspace_auth/data/models/cashier_session_model.dart';
import 'package:vodan/features/workspace_auth/data/models/workspace_session_model.dart';

part 'session.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPrefs(Ref ref) {
  throw UnimplementedError('Gagal memuat SharedPreferences');
}

@Riverpod(keepAlive: true)
class CurrentCashier extends _$CurrentCashier {
  static const _sessionIdKey = 'cashier_session_id';
  static const _deviceIdKey = 'cashier_device_id';
  static const _cashierNameKey = 'cashier_name';
  static const _isAdminKey = 'cashier_is_admin';

  Timer? _autoLockTimer;
  static const _timeoutDuration = Duration(minutes: 5);

  String get deviceId {
    final prefs = ref.read(sharedPrefsProvider);
    String? deviceId = prefs.getString(_deviceIdKey);


    if (deviceId == null) {
      deviceId = const Uuid().v4();
      prefs.setString(_deviceIdKey, deviceId);
    }

    return deviceId;
  }

  @override
  CashierSessionModel? build() {
    ref.onDispose(() => _autoLockTimer?.cancel());

    final prefs = ref.watch(sharedPrefsProvider);
    final sessionId = prefs.getString(_sessionIdKey);
    final currentDeviceId = deviceId;
    final name = prefs.getString(_cashierNameKey);
    final isAdmin = prefs.getBool(_isAdminKey) ?? false;

    if (sessionId != null && name != null) {
      return CashierSessionModel(
        sessionId: sessionId, 
        deviceId: currentDeviceId,
        cashierName: name,
        isAdmin: isAdmin,
        isPinVerified: false
      );
    }
    return null;
  }

  void setSession({
    required String id, 
    required String name,
    required bool isAdmin
  }) {
    final prefs = ref.read(sharedPrefsProvider);
    
    prefs.setString(_sessionIdKey, id);
    prefs.setString(_cashierNameKey, name);
    prefs.setBool(_isAdminKey, isAdmin);
    
    state = CashierSessionModel(
      sessionId: id, 
      deviceId: deviceId,
      cashierName: name,
      isAdmin: isAdmin,
      isPinVerified: false
    );
  }

  void clearSession() {
    final prefs = ref.read(sharedPrefsProvider);
    
    prefs.remove(_sessionIdKey);
    prefs.remove(_cashierNameKey);
    prefs.remove(_isAdminKey);
    
    _autoLockTimer?.cancel();

    state = null;
  }

  Future<String?> verifyPin(String workspaceId, String pin) async {
    if (state == null) return 'Sesi tidak valid';
    if (state!.isAdmin == false) return ' Akses ditolak! Anda bukan pemilik lapak ini.';

    try {
      final repo = ref.read(workspaceRepositoryProvider);
      final errorMessage = await repo.verifyPin(
        workspaceId: workspaceId, 
        deviceId: deviceId, 
        pin: pin
      );

      if (errorMessage == null) {
        state = state!.copyWith(isPinVerified: true);
        _startAutoLockTimer();
        return null;
      }
      return errorMessage;
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  void _startAutoLockTimer() {
    _autoLockTimer?.cancel();
    _autoLockTimer = Timer(_timeoutDuration, () {
      if (state != null) {
        state = state!.copyWith(isPinVerified: false);
        // print("🔒 Auto-Lock Aktif: Sesi sensitif dikunci.");
      }
    });
  }

  void refreshSession() {
    if (state?.isPinVerified == true) {
      _startAutoLockTimer();
    }
  }

  void activateLock() {
    _autoLockTimer?.cancel();
    if (state != null) {
      state = state!.copyWith(isPinVerified: false);
    }
  }
}

@Riverpod(keepAlive: true)
class CurrentWorkspace extends _$CurrentWorkspace {
  static const _workspaceIdKey = 'current_workspace_id';
  static const _workspaceNameKey = 'current_workspace_name';
  static const _saleBroadcastKey = 'current_workspace_broadcast';

  @override
  WorkspaceSessionModel? build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final workspaceId = prefs.getString(_workspaceIdKey);
    final workspaceName = prefs.getString(_workspaceNameKey);
    final isSaleBroadcastOn = prefs.getBool(_saleBroadcastKey) ?? true;

    if (workspaceId != null && workspaceName != null) {
      return WorkspaceSessionModel(
        id: workspaceId, 
        name: workspaceName,
        isSaleBroadcastOn: isSaleBroadcastOn
      );
    }

    return null;
  }

  void setWorkspaceSession({
    required String workspaceId,
    String? workspaceName,
    bool isSaleBroadcastOn = false
  }) {
    final prefs = ref.read(sharedPrefsProvider);

    prefs.setString(_workspaceIdKey, workspaceId);
    prefs.setBool(_saleBroadcastKey, isSaleBroadcastOn);
    if (workspaceName != null && workspaceName.isNotEmpty) prefs.setString(_workspaceNameKey, workspaceName);

    state = WorkspaceSessionModel(
      id: workspaceId, 
      name: workspaceName,
      isSaleBroadcastOn: isSaleBroadcastOn
    );
  }

  void clearWorkspaceSession() {
    final prefs = ref.read(sharedPrefsProvider);

    prefs.remove(_workspaceIdKey);
    prefs.remove(_workspaceNameKey);
    prefs.remove(_saleBroadcastKey);

    state = null;
  }

  void updateSaleBroadcastStatus(bool newValue) {
    if (state == null) return;

    final prefs = ref.read(sharedPrefsProvider);
    prefs.setBool(_saleBroadcastKey, newValue);

    state = state!.copyWith(isSaleBroadcastOn: newValue);
  }
}