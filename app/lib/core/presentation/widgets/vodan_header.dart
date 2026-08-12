import 'package:flutter/material.dart';

class VodanHeader extends StatelessWidget {
  const VodanHeader({
    super.key,
    required this.icon,
    this.iconColor,
    this.iconSize,
    required this.title,
    this.titleStyle,
    this.subtitle,
    this.subtitleStyle
  });

  final IconData icon;
  final Color? iconColor;
  final double? iconSize;
  final String title;
  final TextStyle? titleStyle;
  final String? subtitle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    // Bungkus semua elemen di dalam Column
    return Column(
      mainAxisSize: MainAxisSize.min, // Agar tinggi column menyesuaikan isinya
      crossAxisAlignment: CrossAxisAlignment.center, // Memastikan semuanya rata tengah
      children: [
        Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.primary, 
          size: iconSize ?? 80.0, // Beri ukuran bawaan jika iconSize tidak diisi
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
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