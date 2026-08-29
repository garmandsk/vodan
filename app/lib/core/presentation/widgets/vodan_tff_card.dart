import 'package:flutter/material.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';

class VodanTffCard extends StatelessWidget {
  const VodanTffCard({
    super.key,
    required this.title,
    required this.controller,
    required this.isEditing,
    required this.isLoading,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final TextEditingController controller;
  final bool isEditing;
  final bool isLoading;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Card(
      elevation: 2,
      shadowColor: accentColor.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: accentColor.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  isEditing
                      ? SizedBox(
                          height: 42,
                          child: TextField(
                            controller: controller,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: accentColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          controller.text,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 36,
              child: VodanActionButton(
                text: isLoading ? '...' : (isEditing ? 'Simpan' : 'Ubah'),
                onPressed: isLoading ? null : onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
