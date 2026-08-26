import 'package:flutter/material.dart';

class AiKeyFormRow {
  AiKeyFormRow({
    this.provider = 'Gemini',
    String? key,
  }) : keyController = TextEditingController(text: key);

  String provider;
  final TextEditingController keyController;
  bool isObscure = true;

  void dispose() {
    keyController.dispose();
  }
}