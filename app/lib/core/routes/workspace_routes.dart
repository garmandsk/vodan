part of 'app_router.dart';

@TypedGoRoute<WorkspaceListRoute>(path: '/workspace-list')
class WorkspaceListRoute extends GoRouteData with $WorkspaceListRoute {
  const WorkspaceListRoute();

  @override  
  Widget build(BuildContext context, GoRouterState state) => WorkspaceListScreen();

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;

    if (!isLoggedIn) {
      final fromPath = state.uri.toString();
      // print('fromPath: $fromPath');
      return LoginRoute(from: fromPath).location;
    }

    return null;
  }
}

@TypedGoRoute<TransactionRoute>(path: '/transaction')
class TransactionRoute extends GoRouteData with $TransactionRoute {
  const TransactionRoute();

  @override  
  Widget build(BuildContext context, GoRouterState state) => TransactionScreen();

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    final workspaceId = ProviderScope.containerOf(context).read(currentWorkspaceIdProvider);
    final cashierSessionId = ProviderScope.containerOf(context).read(currentUserProvider)?.sessionId;
    
    if (workspaceId == null || cashierSessionId == null) {
      // print('cashier: $cashierSessionId');
      return const EnterWorkspaceRoute().location; 
    }
    return null;
  }
}

@TypedStatefulShellRoute<CashierShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<PosBranch>(routes: [
      TypedGoRoute<PosRoute>(path: '/pos')
    ]),
    TypedStatefulShellBranch<HistoryBranch>(routes: [
      TypedGoRoute<HistoryRoute>(path: '/history')
    ]),
    TypedStatefulShellBranch<AccessBranch>(routes: [
      TypedGoRoute<AccessRoute>(path: '/access')
    ]),
    TypedStatefulShellBranch<SettingBranch>(routes: [
      TypedGoRoute<SettingRoute>(path: '/setting')
    ])
  ],
)
class CashierShellRouteData extends StatefulShellRouteData {
  const CashierShellRouteData();

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    final workspaceId = ProviderScope.containerOf(context).read(currentWorkspaceIdProvider);
    final cashierSessionId = ProviderScope.containerOf(context).read(currentUserProvider)?.sessionId;
    
    if (workspaceId == null || cashierSessionId == null) {
      // print('cashier: $cashierSessionId');
      return const EnterWorkspaceRoute().location; 
    }
    return null;
  }

  @override
  Widget builder(BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
    return VodanMainScaffold(navigationShell: navigationShell);
  }
}

class PosBranch extends StatefulShellBranchData { const PosBranch(); }
class HistoryBranch extends StatefulShellBranchData { const HistoryBranch(); }
class AccessBranch extends StatefulShellBranchData { const AccessBranch(); }
class SettingBranch extends StatefulShellBranchData { const SettingBranch(); }

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

class AccessRoute extends GoRouteData with $AccessRoute {
  const AccessRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => AccessScreen();
}

class SettingRoute extends GoRouteData with $SettingRoute {
  const SettingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => SettingScreen();
}