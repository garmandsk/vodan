part of 'app_router.dart';

@TypedGoRoute<WorkspaceListRoute>(path: '/workspace-list')
class WorkspaceListRoute extends GoRouteData with $WorkspaceListRoute {
  const WorkspaceListRoute();

  @override  
  Widget build(BuildContext context, GoRouterState state) => WorkspaceListScreen();

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    // final supabase = ProviderScope.containerOf(context).read(supabaseClientProvider); 
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;

    if (!isLoggedIn) {
      final fromPath = state.uri.toString();
      print('fromPath: $fromPath');
      return LoginRoute(from: fromPath).location;
    }

    return null;
  }
}

// 🌟 1. CANGKANG UTAMA (SHELL ROUTE) BERISI TIGA TAB
@TypedStatefulShellRoute<CashierShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    // Tab 0: POS
    TypedStatefulShellBranch<PosBranch>(routes: [
      TypedGoRoute<PosRoute>(path: '/pos')
    ]),
    // Tab 1: Riwayat
    TypedStatefulShellBranch<HistoryBranch>(routes: [
      TypedGoRoute<HistoryRoute>(path: '/history')
    ]),
    // Tab 2: Admin Gate
    TypedStatefulShellBranch<AdminGateBranch>(routes: [
      TypedGoRoute<AdminGateRoute>(path: '/admin-gate')
    ]),
  ],
)
class CashierShellRouteData extends StatefulShellRouteData {
  const CashierShellRouteData();

  // "Satpam" penjaga tab (Opsional, tapi disarankan)
  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    final sessionId = ProviderScope.containerOf(context).read(currentSessionIdProvider);
    
    // Jika tidak punya sesi (mencoba tebak URL), tendang ke halaman awal
    if (sessionId == null) {
      return const EnterWorkspaceRoute().location; 
    }
    return null;
  }

  @override
  Widget builder(BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
    // Memanggil widget cangkang pintar yang kita buat sebelumnya!
    return VodanScaffoldNavbar(navigationShell: navigationShell);
  }
}

// 🌟 2. KELAS DEFINISI CABANG (BRANCHES)
class PosBranch extends StatefulShellBranchData { const PosBranch(); }
class HistoryBranch extends StatefulShellBranchData { const HistoryBranch(); }
class AdminGateBranch extends StatefulShellBranchData { const AdminGateBranch(); }

// 🌟 3. KELAS AKAR RUTE (ROUTES)
class PosRoute extends GoRouteData with $PosRoute {
  const PosRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => PosScreen();
}

class HistoryRoute extends GoRouteData with $HistoryRoute {
  const HistoryRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => HistoryScreen();
}

class AdminGateRoute extends GoRouteData with $AdminGateRoute {
  const AdminGateRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => AdminGateScreen();
}