import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vodan/features/workspace_auth/data/repositories/waiting_room_repository.dart';

// Wajib tambahkan part file untuk generator
part 'waiting_room_controller.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPrefs(Ref ref) {
  throw UnimplementedError('Gagal memuat SharedPreferences');
}

@Riverpod(keepAlive: true)
class CurrentSessionId extends _$CurrentSessionId {
  static const _key = 'cashier_session_id';

  @override
  String? build() {
    return ref.watch(sharedPrefsProvider).getString(_key);
  } // Nilai awal null

  void setSessionId(String id) {
    state = id;
    ref.read(sharedPrefsProvider).setString(_key, id);
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
}

@Riverpod(keepAlive: true)
Stream<Map<String, dynamic>> myStatusStream(Ref ref) {
  final sessionId = ref.watch(currentSessionIdProvider);
  if (sessionId == null) return const Stream.empty();
  
  final repo = ref.watch(waitingRoomRepoProvider);
  return repo.watchMyStatus(sessionId);
}

@Riverpod(keepAlive: true)
Stream<List<String>> otherCashiersStream(Ref ref, {required String workspaceId}) {
  final sessionId = ref.watch(currentSessionIdProvider);
  if (sessionId == null) {
    print('🚨 STREAM BERHENTI: sessionId masih null!');
    
    return Stream.value([]);
  }

  final repo = ref.watch(waitingRoomRepoProvider);
  
  return repo.watchOtherCashiers(workspaceId, sessionId).map((list) {
    print('📦 Data mentah dari Supabase: $list');

    return list.map((e) => e['cashier_name'] as String).toList();
  });
}

@Riverpod(keepAlive: true)
class WaitingRoomController extends _$WaitingRoomController {
  @override
  void build() {} 

  Future<void> join(String workspaceId, String cashierName) async {
    final repo = ref.read(waitingRoomRepoProvider);
    final sessionId = await repo.joinWaitingRoom(workspaceId: workspaceId, cashierName: cashierName);
    
    // Simpan ID Sesi ke provider notifier
    ref.read(currentSessionIdProvider.notifier).setSessionId(sessionId);
  }

  Future<void> editData(String newName, String newWorkspaceId) async {
    final sessionId = ref.read(currentSessionIdProvider);
    if (sessionId == null) return;
    
    await ref.read(waitingRoomRepoProvider).updateCredentials(sessionId, newName, newWorkspaceId);
  }

  Future<bool> scanTicket(String passCode, String workspaceId) async {
    final sessionId = ref.read(currentSessionIdProvider);
    if (sessionId == null) return false;
    
    return await ref.read(waitingRoomRepoProvider).validateShiftPass(passCode, workspaceId, sessionId);
  }
}