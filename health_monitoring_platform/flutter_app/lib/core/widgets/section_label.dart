import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Editorial small-caps section label flanked by hairline rules.
class SectionLabel extends StatelessWidget {
  final String text;
  final bool leadingRule;

  const SectionLabel({super.key, required this.text, this.leadingRule = true});

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text.toUpperCase(),
      style: GoogleFonts.ibmPlexMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 2.2,
        color: AppTheme.accent,
      ),
    );

    if (!leadingRule) {
      return Padding(padding: const EdgeInsets.only(bottom: 16), child: label);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppTheme.border, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: label,
          ),
          const Expanded(child: Divider(color: AppTheme.border, height: 1)),
        ],
      ),
    );
  }
}
