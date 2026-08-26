import 'package:flutter/material.dart';

class VodanHeader extends StatelessWidget {
  const VodanHeader({
    super.key,
    this.crossAlign,
    this.icon,
    this.iconColor,
    this.iconSize,
    required this.title,
    this.titleAlign,
    this.titleStyle,
    this.subtitle,
    this.subtitleStyle
  });

  final CrossAxisAlignment? crossAlign;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final String title;
  final TextAlign? titleAlign;
  final TextStyle? titleStyle;
  final String? subtitle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    // Bungkus semua elemen di dalam Column
    return Column(
      mainAxisSize: MainAxisSize.min, // Agar tinggi column menyesuaikan isinya
      crossAxisAlignment: crossAlign ?? CrossAxisAlignment.center, // Memastikan semuanya rata tengah
      children: [
        if (icon != null)
          Icon(
            icon,
            color: iconColor ?? Theme.of(context).colorScheme.primary, 
            size: iconSize ?? 80.0, // Beri ukuran bawaan jika iconSize tidak diisi
          ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: titleAlign ?? TextAlign.center,
          style: titleStyle ?? Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        if (subtitle != null)
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: subtitleStyle ?? Theme.of(context).textTheme.bodyMedium
          ),
        const SizedBox(height: 32),
      ],
    );
  }
}