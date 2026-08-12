import 'package:flutter/src/widgets/framework.dart';
import 'package:go_router/go_router.dart';
import 'package:vodan/core/presentation/screens/error_screen.dart';

class ErrorRoute extends GoRouteData {
  const ErrorRoute({required this.error});

  final Exception error;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ErrorScreen(error: error);
  }
}