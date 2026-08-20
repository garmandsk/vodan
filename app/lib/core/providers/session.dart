import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vodan/features/workspace_auth/data/models/cashier_session_model.dart';

part 'session.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPrefs(Ref ref) {
  throw UnimplementedError('Gagal memuat SharedPreferences');
}

@Riverpod(keepAlive: true)
class CurrentUser extends _$CurrentUser {
  static const _sessionIdKey = 'cashier_session_id';
  static const _nameKey = 'cashier_name';

  @override
  CashierSessionModel? build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final sessionId = prefs.getString(_sessionIdKey);
    final name = prefs.getString(_nameKey);

    if (sessionId != null && name != null) {
      return CashierSessionModel(sessionId: sessionId, cashierName: name);
    }
    return null;
  }

  void setSession({required String id, required String name}) {
    final prefs = ref.read(sharedPrefsProvider);
    
    prefs.setString(_sessionIdKey, id);
    prefs.setString(_nameKey, name);
    
    state = CashierSessionModel(sessionId: id, cashierName: name);
  }

  void clearSession() {
    final prefs = ref.read(sharedPrefsProvider);
    
    prefs.remove(_sessionIdKey);
    prefs.remove(_nameKey);
    
    state = null;
  }
}

@Riverpod(keepAlive: true)
class CurrentWorkspaceId extends _$CurrentWorkspaceId {
  static const _key = 'current_workspace_id';

  @override
  String? build() {
    return ref.watch(sharedPrefsProvider).getString(_key);
  }

  void setWorkspaceId(String id) {
    state = id;
    ref.read(sharedPrefsProvider).setString(_key, id);
  }

  void clearWorkspaceId() {
    state = null;
    ref.read(sharedPrefsProvider).remove(_key);
  }
}