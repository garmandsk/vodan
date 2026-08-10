import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class VodanScaffold extends StatelessWidget {
  const VodanScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.backgroundColor
  });
  
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: kIsWeb || title == null
          ? null
          : AppBar(
            title: Text(title!),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: actions,
          ),
      body: body,
    );
  }
}