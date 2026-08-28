import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vodan/core/providers/supabase_provider.dart';

part 'broadcast_service.g.dart';

class BroadcastService {
  BroadcastService(this._supabase);

  final SupabaseClient _supabase;
  RealtimeChannel? _channel;

  void subscribeToWorkspace({
    required String workspaceId,
    required Function(Map<String, dynamic>) onNewSale,
  }) {
    if (_channel != null) return;

    _channel = _supabase.channel('workspace-$workspaceId');
    _channel!
        .onBroadcast(
          event: 'new_sale', 
          callback: (payload) {
            onNewSale(payload);
          }
        )
        .subscribe();
  }

  void unsubscribe() {
    if (_channel != null) {
      _supabase.removeChannel(_channel!);
      _channel = null;
    }
  }

  Future<void> sendSaleBroadcast({
    required String workspaceId,
    required String cashierName,
    required double totalPrice,
  }) async {
    // print('broadcast penjualan');

    final channel = _channel ?? _supabase.channel('workspace-$workspaceId');
    await channel.sendBroadcastMessage(
      event: 'new_sale', 
      payload: {
        'cashier_name': cashierName,
        'total_price': totalPrice
      }
    );
  }
}

@Riverpod(keepAlive: true)
BroadcastService broadcastService(Ref ref) {
  return BroadcastService(ref.watch(supabaseClientProvider));
}