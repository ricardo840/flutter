import 'package:flutter/cupertino.dart';

// Widget reutilizable para los títulos de cada sección en HomeScreen
class SectionHeader extends StatelessWidget {
  final String titulo;
  final IconData icono;

  const SectionHeader({
    super.key,
    required this.titulo,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(
            titulo.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: CupertinoColors.systemGrey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 12),
          // Línea divisora
          Expanded(
            child: Container(
              height: 1,
              color: const Color(0xFF2C2C2E),
            ),
          ),
        ],
      ),
    );
  }
}