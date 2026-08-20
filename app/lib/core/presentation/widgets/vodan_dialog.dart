import 'package:flutter/material.dart';

class VodanDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'Tutup',
    Color buttonColor = Colors.red,
    IconData icon = Icons.error_outline_rounded,
    Color iconColor = Colors.red,
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(icon, color: iconColor, size: 48),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: buttonColor),
            onPressed: () {
              Navigator.pop(context); 
              if (onPressed != null) onPressed();
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}