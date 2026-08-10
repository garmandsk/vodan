part of 'app_router.dart';

@TypedGoRoute<CreateWorkspaceRoute>(path: '/create-workspace')
class CreateWorkspaceRoute extends GoRouteData with $CreateWorkspaceRoute {
  const CreateWorkspaceRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => CreateWorkspaceScreen();

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    // TODO: implement redirect
    return null;
  }
}

@TypedGoRoute<WorkspaceCreatedRoute>(path: '/workspace-created')
class WorkspaceCreatedRoute extends GoRouteData with $WorkspaceCreatedRoute{
  const WorkspaceCreatedRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => WorkspaceCreatedScreen();
}

@TypedGoRoute<EnterWorkspaceRoute>(path: '/enter-workspace')
class EnterWorkspaceRoute extends GoRouteData with $EnterWorkspaceRoute {
  const EnterWorkspaceRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => EnterWorkspaceScreen();
}