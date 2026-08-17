import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vodan/core/presentation/widgets/vodan_main_scaffold.dart';
import 'package:vodan/core/providers/supabase_provider.dart';
import 'package:vodan/core/routes/error_routes.dart';
import 'package:vodan/features/account/presentation/screens/profile_screen.dart';
import 'package:vodan/features/workspace/presentation/screens/admin_gate_screen.dart';
import 'package:vodan/features/workspace/presentation/screens/history_screen.dart';
import 'package:vodan/features/workspace/presentation/screens/pos_screen.dart';
import 'package:vodan/features/workspace/presentation/screens/workspace_list_screen.dart';
import 'package:vodan/features/workspace_auth/presentation/controllers/waiting_room_controller.dart';
import 'package:vodan/features/workspace_auth/presentation/screens/enter_workspace_screen.dart';
import 'package:vodan/features/workspace_auth/presentation/screens/waiting_room_screen.dart';

import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/account/presentation/screens/register_screen.dart';
import '../../features/account/presentation/screens/login_screen.dart';
import '../../features/workspace_auth/presentation/screens/create_workspace_screen.dart';
import '../../features/workspace_auth/presentation/screens/workspace_created_screen.dart';

part 'app_router.g.dart';

part 'account_routes.dart';
part 'onboarding_routes.dart';
part 'workspace_auth_routes.dart';
part 'workspace_routes.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

@riverpod
GoRouter appRouter(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);

  return GoRouter(
    initialLocation: SplashRoute().location,
    debugLogDiagnostics: true,
    routes: $appRoutes,
    errorBuilder: (context, state) {
      final error = state.error ?? Exception('Halaman tidak ditemukan (404)');

      return ErrorRoute(error: error).build(context, state);
    },
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
  );
}