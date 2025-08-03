import 'package:flutter/material.dart';

class InfoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const InfoButton({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF4FC3A1)),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Color(0xFF4FC3A1), fontSize: 13)),
      ],
    );
  }
}
