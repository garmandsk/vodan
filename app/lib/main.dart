import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(child: VodanApp())
  );
}

class VodanApp extends StatelessWidget {
  const VodanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoDan',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        'Hello World',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}