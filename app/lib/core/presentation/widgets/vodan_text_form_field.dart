import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VodanTextFormField extends StatelessWidget {
  const VodanTextFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.prefixIconColor,
    this.suffixIcon,
    this.suffixIconColor,
    this.obscureText,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.inputFormatters,
    this.textAlign,
    this.textAlignVertical,
    this.textCapitalization
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final Widget? suffixIcon;
  final Color? suffixIconColor;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign? textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextCapitalization? textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText ?? false,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      maxLines: maxLines,
      inputFormatters: inputFormatters ?? [],
      textAlign: textAlign ?? TextAlign.start,
      textAlignVertical: textAlignVertical ?? TextAlignVertical.center,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      
     decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? SizedBox(
              width: 48,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    prefixIcon, 
                    color: prefixIconColor ?? Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
            )
            : null,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14)
      ),
    );
  }
}