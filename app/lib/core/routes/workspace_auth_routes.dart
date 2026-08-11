part of 'app_router.dart';

@TypedGoRoute<CreateWorkspaceRoute>(path: '/create-workspace')
class CreateWorkspaceRoute extends GoRouteData with $CreateWorkspaceRoute {
  const CreateWorkspaceRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => CreateWorkspaceScreen();

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    final supabase = ProviderScope.containerOf(context).read(supabaseClientProvider);
    final session = supabase.auth.currentSession;
    final bool isLoggedIn = session != null;

    if (!isLoggedIn) {
      final fromPath = state.uri.toString();
      return LoginRoute(from: fromPath).location;
    }
    return null;
  }
}

@TypedGoRoute<WorkspaceCreatedEmptyRoute>(path: '/workspace-created')
class WorkspaceCreatedEmptyRoute extends GoRouteData with $WorkspaceCreatedEmptyRoute{
  const WorkspaceCreatedEmptyRoute();

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    return const CreateWorkspaceRoute().location;
  }
}

@TypedGoRoute<WorkspaceCreatedRoute>(path: '/workspace-created/:workspaceId')
class WorkspaceCreatedRoute extends GoRouteData with $WorkspaceCreatedRoute{
  const WorkspaceCreatedRoute({required this.workspaceId});

  final String workspaceId;

  @override
  Widget build(BuildContext context, GoRouterState state) => WorkspaceCreatedScreen(workspaceId: workspaceId);

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    if (workspaceId.isEmpty) return CreateWorkspaceRoute().location;
    return null;
  }
}

@TypedGoRoute<EnterWorkspaceRoute>(path: '/enter-workspace')
class EnterWorkspaceRoute extends GoRouteData with $EnterWorkspaceRoute {
  const EnterWorkspaceRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => EnterWorkspaceScreen();
}