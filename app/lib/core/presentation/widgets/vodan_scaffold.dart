import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class VodanScaffold extends StatelessWidget {
  const VodanScaffold({
    super.key,
    required this.body,
    this.title,
    this. scaffoldBackgroundColor,
    this.appBarBackgroundColor,
    this.appBarForegroundColor,
    this.useSafeArea = true,
    this.actions,
  });
  
  final Widget body;
  final String? title;
  final Color? scaffoldBackgroundColor;
  final Color? appBarBackgroundColor;
  final Color? appBarForegroundColor;
  final bool useSafeArea;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final content = useSafeArea ? (SafeArea(child: Center(child: body,))) : body;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: kIsWeb || title == null
          ? null
          : AppBar(
            title: Text(title!),
            backgroundColor: appBarBackgroundColor ?? Colors.transparent,
            foregroundColor: appBarForegroundColor ?? Theme.of(context).colorScheme.onSurface,
            elevation: 0,
            actions: actions,
          ),
      body: content,
    );
  }
}