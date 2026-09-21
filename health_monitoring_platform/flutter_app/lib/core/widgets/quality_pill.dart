import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class QualityPill extends StatelessWidget {
  final String status;
  final double? score;

  const QualityPill({super.key, required this.status, this.score});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status.toUpperCase()) {
      case 'ACCEPTABLE':
        bg = AppTheme.healthySoft;
        fg = AppTheme.healthy;
        break;
      case 'LOW':
        bg = AppTheme.observeSoft;
        fg = AppTheme.observe;
        break;
      case 'INVALID':
      default:
        bg = AppTheme.reviewSoft;
        fg = AppTheme.review;
        break;
    }

    final scoreStr = score != null ? '  ${(score! * 100).toInt()}%' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${status.toUpperCase()}$scoreStr',
        style: GoogleFonts.ibmPlexMono(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
