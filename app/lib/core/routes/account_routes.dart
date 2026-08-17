part of 'app_router.dart';

@TypedGoRoute<RegisterRoute>(path: '/register')
class RegisterRoute extends GoRouteData with $RegisterRoute {
  const RegisterRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const RegisterScreen();

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    // final supabase = ProviderScope.containerOf(context).read(supabaseClientProvider);
    final session = Supabase.instance.client.auth.currentSession;
    final bool isLoggedIn = session != null;

    if (isLoggedIn) return EnterWorkspaceRoute().location;
    return null;
  }
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute({this.from});

  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) => LoginScreen();

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    // final supabase = ProviderScope.containerOf(context).read(supabaseClientProvider);
    final session = Supabase.instance.client.auth.currentSession;
    final bool isLoggedIn = session != null;

    if (isLoggedIn) return from ?? EnterWorkspaceRoute().location;
    return null;
  }
}

@TypedGoRoute<ProfileRoute>(path: '/profile')
class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => ProfileScreen();

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    final session = Supabase.instance.client.auth.currentSession;
    final bool isLoggedIn = session != null;

    if (!isLoggedIn) return LoginRoute().location;
    return null;
  }
}