import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vodan/features/workspace_auth/data/models/cashier_session_model.dart';
import 'package:vodan/features/workspace_auth/data/models/workspace_session_model.dart';

part 'session.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPrefs(Ref ref) {
  throw UnimplementedError('Gagal memuat SharedPreferences');
}

@Riverpod(keepAlive: true)
class CurrentUser extends _$CurrentUser {
  static const _sessionIdKey = 'cashier_session_id';
  static const _userNameKey = 'cashier_name';

  @override
  CashierSessionModel? build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final sessionId = prefs.getString(_sessionIdKey);
    final name = prefs.getString(_userNameKey);

    if (sessionId != null && name != null) {
      return CashierSessionModel(sessionId: sessionId, cashierName: name);
    }
    return null;
  }

  void setSession({required String id, required String name}) {
    final prefs = ref.read(sharedPrefsProvider);
    
    prefs.setString(_sessionIdKey, id);
    prefs.setString(_userNameKey, name);
    
    state = CashierSessionModel(sessionId: id, cashierName: name);
  }

  void clearSession() {
    final prefs = ref.read(sharedPrefsProvider);
    
    prefs.remove(_sessionIdKey);
    prefs.remove(_userNameKey);
    
    state = null;
  }
}

@Riverpod(keepAlive: true)
class CurrentWorkspace extends _$CurrentWorkspace {
  static const _workspaceIdKey = 'current_workspace_id';
  static const _workspaceNameKey = 'current_workspace_name';

  @override
  WorkspaceSessionModel? build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final workspaceId = prefs.getString(_workspaceIdKey);
    final workspaceName = prefs.getString(_workspaceNameKey);

    if (workspaceId != null && workspaceName != null) {
      return WorkspaceSessionModel(id: workspaceId, name: workspaceName);
    }
  }

  void setWorkspaceSession({
    required String workspaceId,
    String? workspaceName
  }) {
    final prefs = ref.read(sharedPrefsProvider);

    prefs.setString(_workspaceIdKey, workspaceId);
    if (workspaceName != null && workspaceName.isNotEmpty) prefs.setString(_workspaceNameKey, workspaceName);

    state = WorkspaceSessionModel(id: workspaceId, name: workspaceName);
  }

  void clearWorkspaceSession() {
    final prefs = ref.read(sharedPrefsProvider);

    prefs.remove(_workspaceIdKey);
    prefs.remove(_workspaceNameKey);

    state = null;
  }
}