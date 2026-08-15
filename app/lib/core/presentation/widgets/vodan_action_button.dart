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

  @override
  Widget build(BuildContext context) {
    final effectiveForegroundColor = foregroundColor ?? Theme.of(context).colorScheme.onPrimary;
    
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, 
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
          foregroundColor: effectiveForegroundColor,
          elevation: elevation
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24, // Ukuran circular loading agar tidak membesarkan tombol
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  color: effectiveForegroundColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, size: 20, color: effectiveForegroundColor),
                    const SizedBox(width: 8), // Jarak antara ikon dan teks
                  ],
                  
                  Text(
                    text,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: effectiveForegroundColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8), // Jarak antara teks dan ikon
                    suffixIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}