import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class StateBadge extends StatelessWidget {
  final String state;

  const StateBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (state.toUpperCase()) {
      case 'NORMAL':
        bg = AppTheme.healthySoft;
        fg = AppTheme.healthy;
        icon = Icons.check_circle_outline;
        break;
      case 'DEGRADED':
        bg = AppTheme.observeSoft;
        fg = AppTheme.observe;
        icon = Icons.cloud_off_outlined;
        break;
      case 'RECOVERING':
        bg = AppTheme.muted;
        fg = AppTheme.accent;
        icon = Icons.sync;
        break;
      case 'SAFE_STOP':
      default:
        bg = AppTheme.reviewSoft;
        fg = AppTheme.review;
        icon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 8),
          Text(
            state.toUpperCase(),
            style: GoogleFonts.ibmPlexMono(
              color: fg,
              fontWeight: FontWeight.w500,
              fontSize: 11,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
