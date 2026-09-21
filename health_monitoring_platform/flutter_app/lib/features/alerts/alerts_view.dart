import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/editorial_card.dart';
import '../../core/widgets/page_frame.dart';
import '../../core/widgets/quality_pill.dart';
import '../../core/widgets/section_label.dart';
import '../../core/widgets/severity_pill.dart';
import '../../models/alert.dart';
import '../../state/app_state.dart';

class AlertsView extends StatelessWidget {
  final AppState state;

  const AlertsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final alerts = state.alerts;

    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(text: 'Engineering review'),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Alerts',
                  style: GoogleFonts.playfairDisplay(fontSize: 36, height: 1.15, color: AppTheme.foreground),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.foreground),
                onPressed: state.refreshAlerts,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Anomalies arrive with reason codes, baselines, and a written explanation — never a silent flag.',
            style: GoogleFonts.sourceSans3(fontSize: 16, height: 1.7, color: AppTheme.mutedForeground),
          ),
          const SizedBox(height: 28),
          if (alerts.isEmpty)
            EditorialCard(
              featured: true,
              child: Column(
                children: [
                  Text(
                    '“',
                    style: GoogleFonts.playfairDisplay(fontSize: 64, height: 0.8, color: AppTheme.accent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No review alerts active',
                    style: GoogleFonts.playfairDisplay(fontSize: 24, color: AppTheme.foreground),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Incoming physiological signals remain within the learned baseline.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sourceSans3(color: AppTheme.mutedForeground, height: 1.6),
                  ),
                ],
              ),
            )
          else
            ...alerts.map(_buildAlertCard),
        ],
      ),
    );
  }

  Widget _buildAlertCard(AlertItem alert) {
    final isReview = alert.severity.toUpperCase() == 'REVIEW';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: EditorialCard(
        accentTop: true,
        featured: isReview,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${alert.sensor.toUpperCase()} ANOMALY',
                  style: GoogleFonts.ibmPlexMono(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    letterSpacing: 1.6,
                    color: AppTheme.accent,
                  ),
                ),
                const Spacer(),
                SeverityPill(severity: alert.severity),
                const SizedBox(width: 8),
                QualityPill(status: alert.qualityStatus),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alert.explanation,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                height: 1.35,
                color: AppTheme.foreground,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag('Reading  ${alert.processedValue ?? alert.rawValue} ${alert.unit}'),
                if (alert.baseline != null) _buildTag('Baseline  ${alert.baseline} ${alert.unit}'),
                if (alert.deviation != null)
                  _buildTag('Deviation  ${alert.deviation! >= 0 ? '+' : ''}${alert.deviation} ${alert.unit}'),
                _buildTag('Confidence  ${alert.confidence}'),
                if (alert.isFixture) _buildTag('Simulated fixture', highlight: true),
              ],
            ),
            if (alert.reasonCodes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: alert.reasonCodes
                    .map(
                      (code) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.border),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          code,
                          style: GoogleFonts.ibmPlexMono(fontSize: 11, letterSpacing: 0.4, color: AppTheme.foreground),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: highlight ? AppTheme.observeSoft : AppTheme.muted,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.sourceSans3(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: highlight ? AppTheme.observe : AppTheme.mutedForeground,
        ),
      ),
    );
  }
}
