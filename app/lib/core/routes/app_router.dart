import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/core/providers/supabase_provider.dart';
import 'package:vodan/core/routes/error_routes.dart';
import 'package:vodan/features/pos/workspace_screen.dart';
import 'package:vodan/features/workspace_auth/enter_workspace_screen.dart';

import '../../features/onboarding/splash_screen.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/account_auth/presentation/screens/register_screen.dart';
import '../../features/account_auth/presentation/screens/login_screen.dart';
import '../../features/workspace_auth/create_workspace_screen.dart';
import '../../features/workspace_auth/workspace_created_screen.dart';
import '../../features/workspace_auth/enter_workspace_screen.dart';
import '../../features/pos/workspace_screen.dart';

part 'app_router.g.dart';

part 'account_auth_routes.dart';
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
    redirect: (context, state) {
      final session = supabase.auth.currentSession;
      final isLoggedIn = session != null;

      final isGoingToSplash = state.matchedLocation == const SplashRoute().location;
      final isGoingToLogin = state.matchedLocation == const LoginRoute().location;
      final isGoingToRegister = state.matchedLocation == const RegisterRoute().location;
      final isGoingToWelcome = state.matchedLocation == const WelcomeRoute().location;
      
      final isGoingToAuthOrWelcome = isGoingToSplash || isGoingToWelcome || isGoingToLogin || isGoingToRegister;

      final isGoingToAuth = isGoingToRegister || isGoingToLogin;

      // Belum login tapi mencoba masuk ke halaman utama
      if (!isLoggedIn && !isGoingToAuthOrWelcome) {
        final fromPath = state.uri.toString();
        return Uri(
          path: const LoginRoute().location,
          queryParameters: {'from': fromPath}
        ).toString();
      }

      // Sudah login tapi mencoba kembali ke halaman login/welcome
      if (isLoggedIn && isGoingToAuth) {
        final previousDestination = state.uri.queryParameters['from'];
        if (previousDestination != null && previousDestination.isNotEmpty) {
          return previousDestination;
        }

        return const WorkspaceRoute().location;
      }

      return null;
    }
  );
}