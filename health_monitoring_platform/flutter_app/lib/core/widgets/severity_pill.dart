import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SeverityPill extends StatelessWidget {
  final String severity;

  const SeverityPill({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (severity.toUpperCase()) {
      case 'NORMAL':
        bg = AppTheme.healthySoft;
        fg = AppTheme.healthy;
        break;
      case 'OBSERVE':
        bg = AppTheme.observeSoft;
        fg = AppTheme.observe;
        break;
      case 'REVIEW':
      default:
        bg = AppTheme.reviewSoft;
        fg = AppTheme.review;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        severity.toUpperCase(),
        style: GoogleFonts.ibmPlexMono(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}
