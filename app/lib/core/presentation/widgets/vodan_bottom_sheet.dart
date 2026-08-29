import 'package:flutter/material.dart';

class VodanBottomSheet extends StatelessWidget {
  const VodanBottomSheet({
    super.key,
    required this.child,
    this.padding,
    this.isDismissible,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool? isDismissible;

  static Future<T?> show<T>(
      {required BuildContext context,
      required Widget child,
      bool isScrollControlled = true,
      bool isDismissible = true}) {
    return showModalBottomSheet<T>(
      context: context,
      // useRootNavigator: true,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
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
      padding: padding ??
          EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0 + keyboardPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
