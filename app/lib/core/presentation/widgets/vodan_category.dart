import 'package:flutter/material.dart';

class VodanCategory extends StatelessWidget {
  const VodanCategory({
    super.key,
    required this.text,
    required this.selected,
    required this.onSelected,
    this.showCheckmark,
    this.selectedColor,
    this.radius
  });

  final String text;
  final bool selected;
  final ValueChanged onSelected;
  final bool? showCheckmark;
  final Color? selectedColor;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChoiceChip(
      label: Text(text),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: showCheckmark ?? false,
      selectedColor: selectedColor ?? theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius ?? 20)),
    );
  }
}

class VodanFilterChips extends StatelessWidget {
  final List<String> items;
  final String selectedItem;
  final ValueChanged<String> onSelected;
  final EdgeInsetsGeometry? padding;

  const VodanFilterChips({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onSelected,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selectedItem == item;
          
          return ChoiceChip(
            label: Text(item),
            selected: isSelected,
            onSelected: (_) => onSelected(item),
            showCheckmark: false,
            selectedColor: theme.colorScheme.primary,
            labelStyle: TextStyle(
              color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }
}