import 'package:flutter/material.dart';

class VodanActionButton extends StatelessWidget {
  const VodanActionButton({
    super.key,
    this.height = 50.0,
    required this.text,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.isLoading = false,
    required this.onPressed,
    this.isExpanded = false,
    this.extraInfo,
  });

  final double height;
  final String text;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final VoidCallback? onPressed;
  final bool isLoading; 
  final bool isExpanded;
  final String? extraInfo;

  @override
  Widget build(BuildContext context) {
    final effectiveForegroundColor = foregroundColor ?? Theme.of(context).colorScheme.onPrimary;
    
    return SizedBox(
      height: height,
      width: isExpanded ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, 
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
          foregroundColor: effectiveForegroundColor,
          elevation: elevation ?? (isExpanded ? 8 : 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isExpanded ? 20 : 16), 
          ),
          padding: EdgeInsets.symmetric(horizontal: isExpanded ? 24 : 16),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24, 
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  color: effectiveForegroundColor,
                ),
              )
            : Row(
                mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: isExpanded ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                children: [
                  // --- BAGIAN KIRI (Icon + Teks Utama) ---
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (prefixIcon != null) ...[
                        Icon(prefixIcon, size: 20, color: effectiveForegroundColor),
                        const SizedBox(width: 8), 
                      ],
                      Text(
                        text,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: effectiveForegroundColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // --- BAGIAN KANAN (Info Tambahan + Suffix Icon) ---
                  if (isExpanded || suffixIcon != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (extraInfo != null)
                          Text(
                            extraInfo!,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: effectiveForegroundColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (suffixIcon != null) ...[
                          if (extraInfo != null) const SizedBox(width: 8), 
                          suffixIcon!,
                        ],
                      ],
                    ),
                ],
              ),
      ),
    );
  }
}