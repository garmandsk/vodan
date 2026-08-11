part of 'app_router.dart';

@TypedGoRoute<WorkspaceEmptyRoute>(path: '/workspace')
class WorkspaceEmptyRoute extends GoRouteData with $WorkspaceEmptyRoute {
  const WorkspaceEmptyRoute();
  
  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    return EnterWorkspaceRoute().location;
  }
}

@TypedGoRoute<WorkspaceRoute>(path: '/workspace/:workspaceId')
class WorkspaceRoute extends GoRouteData with $WorkspaceRoute {
  const WorkspaceRoute({required this.workspaceId});

  final String workspaceId;
  
  @override
  Widget build(BuildContext context, GoRouterState state) => WorkspaceScreen(workspaceId: workspaceId);

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    final supabase = ProviderScope.containerOf(context).read(supabaseClientProvider); 
    final session = supabase.auth.currentSession;
    final isLoggedIn = session != null;

    if (!isLoggedIn) return const LoginRoute().location;

    final previousDestination = state.uri.queryParameters['from'];
    if (previousDestination != null && previousDestination.isNotEmpty) {
      return previousDestination;
    }

    return null;
  }
}