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

    return Row(
      children: [
        // Ikon di kiri
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        
        // Teks / Text Form Field di tengah
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              isEditing
                  ? SizedBox(
                      height: 38,
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    )
                  : Text(
                      controller.text,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        
        // Tombol Ubah / Simpan di kanan
        SizedBox(
          height: 32,
          child: VodanActionButton(
            text: isLoading 
                ? '...' 
                : (isEditing ? 'Simpan' : 'Ubah'), 
            onPressed: isLoading ? null : onPressed,
          ),
        ),
      ],
    );
  }
}