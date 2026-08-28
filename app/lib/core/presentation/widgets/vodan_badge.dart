import 'package:flutter/material.dart';

class VodanBadge extends StatelessWidget {
  final String? text;           
  final IconData? icon;         
  final VoidCallback? onTap;    
  final double radius;          
  final Color? backgroundColor; 
  final Color? foregroundColor; 
  final String? tooltip;        

  const VodanBadge({
    super.key,
    this.text,
    this.icon,
    this.onTap,
    this.radius = 18,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget badgeContent = InkWell(
      borderRadius: BorderRadius.circular(radius + 4),
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? theme.colorScheme.primaryContainer,
        foregroundColor: foregroundColor ?? theme.colorScheme.onPrimaryContainer,
        child: icon != null
            ? Icon(icon, size: radius * 1.1)
            : Text(
                text != null && text!.isNotEmpty ? text!.substring(0, 1).toUpperCase() : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.9,
                ),
              ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        child: badgeContent,
      );
    }

    return badgeContent;
  }
}