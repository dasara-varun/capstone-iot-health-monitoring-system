import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../../core/widgets/editorial_card.dart';
import '../../core/widgets/page_frame.dart';
import '../../core/widgets/quality_pill.dart';
import '../../core/widgets/section_label.dart';
import '../../core/widgets/severity_pill.dart';
import '../../core/widgets/state_badge.dart';
import '../../models/observation.dart';
import '../../state/app_state.dart';

class OverviewView extends StatelessWidget {
  final AppState state;

  const OverviewView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final overview = state.overview;
    final systemState = overview?.systemState ?? 'NORMAL';
    final latestObs = overview?.latestObservations ?? {};

    return PageFrame(
      onRefresh: state.refreshAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DisclaimerBanner(),
          const SectionLabel(text: 'Operating ledger'),
          Text(
            'Quiet watch over the edge.',
            style: GoogleFonts.playfairDisplay(
              fontSize: 40,
              height: 1.12,
              letterSpacing: -0.6,
              color: AppTheme.foreground,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              'Live readings from the write-first gateway, presented with the same restraint as a laboratory notebook: values first, ornaments never.',
              style: GoogleFonts.sourceSans3(
                fontSize: 16,
                height: 1.75,
                letterSpacing: 0.2,
                color: AppTheme.mutedForeground,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _buildStatusHeader(systemState, overview?.pendingQueueCount ?? 0, overview?.lastSuccessfulSync),
          const SizedBox(height: 36),
          const SectionLabel(text: 'Vital channels'),
          _buildCardsRow(context, latestObs),
          const SizedBox(height: 36),
          const SectionLabel(text: 'Explainable notes'),
          _buildRecentActivitySection(latestObs),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(String systemState, int queueDepth, String? lastSync) {
    return EditorialCard(
      accentTop: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 640;
          final status = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SYSTEM OPERATING STATUS',
                style: GoogleFonts.ibmPlexMono(
                  color: AppTheme.mutedForeground,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  StateBadge(state: systemState),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      systemState == 'NORMAL'
                          ? 'All edge channels operating within expected bounds.'
                          : systemState == 'DEGRADED'
                              ? 'Offline mode: persisting to local SQLite.'
                              : 'Reconciling pending records with the cloud ledger.',
                      style: GoogleFonts.sourceSans3(
                        color: AppTheme.foreground,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );

          final queue = Column(
            crossAxisAlignment: stacked ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Text(
                '$queueDepth',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 40,
                  height: 1,
                  color: queueDepth > 0 ? AppTheme.observe : AppTheme.foreground,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'QUEUE DEPTH',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 11,
                  letterSpacing: 1.6,
                  color: AppTheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lastSync != null ? 'Last sync ${lastSync.split('T').last.split('.').first}' : 'Sync pending',
                style: GoogleFonts.sourceSans3(color: AppTheme.mutedForeground, fontSize: 13),
              ),
            ],
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [status, const SizedBox(height: 24), const Divider(color: AppTheme.border), const SizedBox(height: 20), queue],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 13, child: status),
              const SizedBox(width: 24),
              Expanded(flex: 7, child: queue),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCardsRow(BuildContext context, Map<String, Observation> obs) {
    final spo2 = obs['spo2'];
    final hr = obs['heart_rate'];
    final temp = obs['temperature'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _buildMetricCard('Blood Oxygen', 'SpO₂', spo2, '%', Icons.air),
          _buildMetricCard('Heart Rate', 'BPM', hr, 'bpm', Icons.favorite_border),
          _buildMetricCard('Temperature', 'Core', temp, '°C', Icons.thermostat_outlined),
        ];

        if (constraints.maxWidth > 800) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 20),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              cards[i],
            ],
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String kicker, Observation? obs, String defaultUnit, IconData icon) {
    final hasVal = obs != null && obs.processedValue != null;
    final valStr = hasVal ? obs.processedValue!.toStringAsFixed(1) : '—';
    final unit = obs?.unit ?? defaultUnit;

    return EditorialCard(
      accentTop: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kicker.toUpperCase(),
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 11,
                        letterSpacing: 1.6,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: AppTheme.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              if (obs != null) QualityPill(status: obs.qualityStatus, score: obs.qualityScore),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                valStr,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 46,
                  height: 1,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.foreground,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                unit,
                style: GoogleFonts.sourceSans3(
                  fontSize: 15,
                  color: AppTheme.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (obs != null) SeverityPill(severity: obs.severity),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: AppTheme.border),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  obs?.baseline != null ? 'Baseline  ${obs!.baseline!.toStringAsFixed(1)}$unit' : 'Baseline  learning',
                  style: GoogleFonts.sourceSans3(fontSize: 13, color: AppTheme.mutedForeground),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (obs != null && obs.deviation != null)
                Text(
                  'Dev  ${obs.deviation! >= 0 ? '+' : ''}${obs.deviation!.toStringAsFixed(1)}$unit',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: obs.deviation!.abs() > 3 ? AppTheme.observe : AppTheme.mutedForeground,
                  ),
                ),
            ],
          ),
          if (obs?.isFixture ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'SIMULATED FIXTURE',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 10,
                  letterSpacing: 1.4,
                  color: AppTheme.mutedForeground,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(Map<String, Observation> obs) {
    return EditorialCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reason log',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              color: AppTheme.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Each line is the detector speaking in plain language, not a black-box score.',
            style: GoogleFonts.sourceSans3(color: AppTheme.mutedForeground, height: 1.6),
          ),
          const SizedBox(height: 20),
          if (obs.isEmpty)
            Text('No readings recorded yet.', style: GoogleFonts.sourceSans3(color: AppTheme.mutedForeground))
          else
            ...obs.values.map(
              (o) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 28, height: 1, margin: const EdgeInsets.only(top: 11), color: AppTheme.accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.sourceSans3(color: AppTheme.foreground, fontSize: 15, height: 1.6),
                          children: [
                            TextSpan(
                              text: '${o.sensor.toUpperCase()}  ',
                              style: GoogleFonts.ibmPlexMono(
                                fontSize: 12,
                                letterSpacing: 1.4,
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(text: o.explanation),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
