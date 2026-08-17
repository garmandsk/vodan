import 'package:flutter/material.dart';

class VodanBottomSheet extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const VodanBottomSheet({
    super.key,
    required this.child,
    this.padding,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) => VodanBottomSheet(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: padding ?? EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0 + keyboardPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Tinggi menyesuaikan isi anak
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🌟 Garis Penarik (Grabber) yang selalu konsisten
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          child,
        ],
      ),
    );
  }
}