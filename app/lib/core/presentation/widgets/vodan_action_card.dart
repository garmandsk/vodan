import 'package:flutter/material.dart';

// Widget Pembantu untuk Membuat Kartu Pilihan yang Elegan
class VodanActionCard extends StatelessWidget {
  const VodanActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.prefixIcon,
    this.suffixIcon = Icons.chevron_right_rounded,
    required this.color,
    required this.onTap,
  }); 
  
  final String title;
  final String subtitle;
  final IconData prefixIcon;
  final IconData suffixIcon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16), // Efek riak/sentuhan melengkung
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Ikon Peran
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(prefixIcon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              
              // Teks Penjelasan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                    ),
                  ],
                ),
              ),
              
              // Panah Kanan
              Icon(suffixIcon, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}