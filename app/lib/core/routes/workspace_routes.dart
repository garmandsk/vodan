part of 'app_router.dart';

@TypedGoRoute<WorkspaceRoute>(path: '/workspace')
class WorkspaceRoute extends GoRouteData with $WorkspaceRoute {
  const WorkspaceRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => WorkspaceScreen();
}