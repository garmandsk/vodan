import 'package:flutter/material.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';

class VodanDialog {
  static void show({
    required BuildContext context,
    required String title,
    String? message, 
    Widget? customContent,
    String buttonText = 'Tutup',
    Color? buttonColor,
    IconData icon = Icons.info_outline_rounded,
    Color? iconColor,
    VoidCallback? onPressed,
    List<Widget> Function(BuildContext dialogContext)? customActions,
  }) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(icon, color: iconColor ?? theme.colorScheme.primary, size: 48),
        title: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message != null) 
              Text(message, textAlign: TextAlign.center),
            if (message != null && customContent != null) 
              const SizedBox(height: 16),
            if (customContent != null) 
              customContent,
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: customActions != null 
            ? customActions(dialogContext) 
            : [
              VodanActionButton(
                text: buttonText,
                onPressed: () {
                  Navigator.pop(dialogContext); 
                  if (onPressed != null) onPressed();
                },
              ),
            ],
      ),
    );
  }
}