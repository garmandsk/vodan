import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_text_form_field.dart';

class PinBarrier extends StatelessWidget {
  const PinBarrier({
    super.key,
    this.icon,
    this.title,
    this.subtitle,
    required this.tffController,
    this.tffLabelText,
    this.tffHintText,
    this.tffPrefixIcon,
    this.tffPrefixIconColor,
    this.tffSuffixIcon,
    this.tffSuffixIconColor,
    this.tffObscureText,
    this.tffKeyboardType,
    this.tffTextInputAction,
    this.tffValidator,
    this.tffOnChanged,
    this.tffOnFieldSubmitted,
    this.tffOnSubmitted,
    this.tffEnabled,
    this.tffMaxLines,
    this.tffInputFormatters,
    this.tffTextAlign,
    this.tffTextAlignVertical,
    this.buttonHeight,
    required this.buttonText,
    this.buttonPrefixIcon,
    this.buttonSuffixIcon,
    this.buttonBackgroundColor,
    this.buttonForegroundColor,
    this.buttonElevation,
    this.buttonOnPressed,
    this.buttonIsLoading, 
    this.buttonIsExpanded,
    this.buttonExtraInfo,
  });

  // Main
  final IconData? icon;
  final String? title;
  final String? subtitle;

  // TextFormField
  final TextEditingController tffController;
  final String? tffLabelText;
  final String? tffHintText;
  final IconData? tffPrefixIcon;
  final Color? tffPrefixIconColor;
  final Widget? tffSuffixIcon;
  final Color? tffSuffixIconColor;
  final bool? tffObscureText;
  final TextInputType? tffKeyboardType;
  final TextInputAction? tffTextInputAction;
  final String? Function(String?)? tffValidator;
  final void Function(String)? tffOnChanged;
  final void Function(String)? tffOnFieldSubmitted;
  final ValueChanged<String>? tffOnSubmitted;
  final bool? tffEnabled;
  final int? tffMaxLines;
  final List<TextInputFormatter>? tffInputFormatters;
  final TextAlign? tffTextAlign;
  final TextAlignVertical? tffTextAlignVertical;

  // Button
  final double? buttonHeight;
  final String buttonText;
  final IconData? buttonPrefixIcon;
  final Widget? buttonSuffixIcon;
  final Color? buttonBackgroundColor;
  final Color? buttonForegroundColor;
  final double? buttonElevation;
  final VoidCallback? buttonOnPressed;
  final bool? buttonIsLoading; 
  final bool? buttonIsExpanded;
  final String? buttonExtraInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16,
              children: [
                Icon(icon ?? Icons.lock_person_rounded, size: 80, color: theme.colorScheme.primary),
                Text(title ?? 'Masukkan PIN Keamanan', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle ?? 'Halaman ini memuat data sensitif lapak', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                
                VodanTextFormField(
                  controller: tffController,
                  hintText: tffHintText ?? 'PIN Admin',
                  prefixIcon: tffPrefixIcon ?? Icons.dialpad,
                  obscureText: tffObscureText ?? true, 
                  keyboardType: tffKeyboardType ?? TextInputType.number,
                  textAlign: tffTextAlign ?? TextAlign.center,
                  inputFormatters: tffInputFormatters ?? [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6)
                  ],
                  onFieldSubmitted: tffOnFieldSubmitted,
                ),
                
                SizedBox(
                  width: double.infinity,
                  child: VodanActionButton(
                    text: buttonText,
                    onPressed: buttonOnPressed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}