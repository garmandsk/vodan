import 'package:flutter/material.dart';

class VodanActionButton extends StatelessWidget {
  VodanActionButton({
    super.key,
    this.height = 50.0,
    required this.text,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.isLoading = false,
    required this.onPressed,
  });

  final double height;
  final String text;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final VoidCallback? onPressed;
  final bool isLoading; 

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, 
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
          foregroundColor: foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
          elevation: elevation
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24, // Ukuran circular loading agar tidak membesarkan tombol
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  // Jika foregroundColor null, biarkan CircularProgressIndicator 
                  // mengikuti warna teks bawaan tema (onPrimary)
                  color: foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : Text(
                text,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foregroundColor ?? Theme.of(context).colorScheme.onPrimary
                )
              ),
      ),
    );
  }
}