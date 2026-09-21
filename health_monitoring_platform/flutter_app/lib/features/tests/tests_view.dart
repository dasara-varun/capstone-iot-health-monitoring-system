import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/editorial_card.dart';
import '../../core/widgets/page_frame.dart';
import '../../core/widgets/section_label.dart';
import '../../state/app_state.dart';

class TestsView extends StatelessWidget {
  final AppState state;

  const TestsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(text: 'Controlled fixtures'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Test harness',
                  style: GoogleFonts.playfairDisplay(fontSize: 36, height: 1.15, color: AppTheme.foreground),
                ),
              ),
              if (state.statusMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.statusMessage!,
                    style: GoogleFonts.sourceSans3(color: AppTheme.healthy, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              'Inject reproducible scenarios into the edge–cloud pipeline to verify noise gating, baseline deviation, and explainable alerts without putting a subject at risk.',
              style: GoogleFonts.sourceSans3(fontSize: 16, height: 1.75, color: AppTheme.mutedForeground),
            ),
          ),
          const SizedBox(height: 28),
          _buildScenarioGrid(context),
          const SizedBox(height: 32),
          _buildTestMatrixCard(),
        ],
      ),
    );
  }

  Widget _buildScenarioGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        final items = [
          _buildScenarioCard(
            title: 'Normal baseline',
            kicker: 'T-01  ·  T-03',
            description: 'Standard physiology: SpO₂ 98%, heart rate 72 bpm, temperature 36.6°C.',
            expected: 'Severity NORMAL  ·  Quality ACCEPTABLE  ·  Sync SYNCHRONIZED',
            scenario: 'normal',
            featured: true,
          ),
          _buildScenarioCard(
            title: 'Hypoxia desaturation',
            kicker: 'T-06  ·  T-08',
            description: 'Acute SpO₂ drop to 88%, enough to leave the learned baseline.',
            expected: 'Severity REVIEW  ·  deviation_from_baseline  ·  Confidence HIGH',
            scenario: 'spo2_drop',
          ),
          _buildScenarioCard(
            title: 'Tachycardia spike',
            kicker: 'T-06  ·  T-08',
            description: 'Resting pulse lifted above 135 bpm against a calm baseline.',
            expected: 'Severity REVIEW  ·  elevated_pulse_rate  ·  Confidence HIGH',
            scenario: 'tachycardia',
          ),
          _buildScenarioCard(
            title: 'Motion artifact',
            kicker: 'T-04  ·  T-05',
            description: 'Movement noise pulls the quality score below 0.5; median filter still applies.',
            expected: 'Severity OBSERVE  ·  Quality LOW  ·  Filtered median applied',
            scenario: 'noise_spike',
          ),
          _buildScenarioCard(
            title: 'Sensor fault',
            kicker: 'T-04',
            description: 'Unplugged or non-finite values outside the configured temperature range.',
            expected: 'Quality INVALID  ·  outside_configured_range  ·  Alert blocked',
            scenario: 'sensor_fault',
          ),
        ];

        if (isWide) {
          return Wrap(
            spacing: 20,
            runSpacing: 20,
            children: items.map((w) => SizedBox(width: (constraints.maxWidth - 20) / 2, child: w)).toList(),
          );
        }
        return Column(
          children: items
              .map((w) => Padding(padding: const EdgeInsets.only(bottom: 16), child: w))
              .toList(),
        );
      },
    );
  }

  Widget _buildScenarioCard({
    required String title,
    required String kicker,
    required String description,
    required String expected,
    required String scenario,
    bool featured = false,
  }) {
    return EditorialCard(
      accentTop: true,
      featured: featured,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kicker,
            style: GoogleFonts.ibmPlexMono(fontSize: 11, letterSpacing: 1.6, color: AppTheme.accent),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600, fontSize: 22, color: AppTheme.foreground),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.sourceSans3(fontSize: 14, height: 1.65, color: AppTheme.mutedForeground),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.muted,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              expected,
              style: GoogleFonts.sourceSans3(fontSize: 12.5, height: 1.45, color: AppTheme.foreground),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => state.injectFixture(scenario),
              child: const Text('Inject scenario'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestMatrixCard() {
    const rows = [
      'T-01  Normalized sample format with timestamps and quality score.',
      'T-04  Out-of-range and noise spikes marked INVALID or LOW without a false alarm.',
      'T-06  Baseline deviation computed on a median-filter window.',
      'T-08  Decision reason codes match the displayed explanation.',
      'T-09  Write-first SQLite WAL persistence: no loss on outage.',
    ];

    return EditorialCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rubric traceability',
            style: GoogleFonts.playfairDisplay(fontSize: 22, color: AppTheme.foreground),
          ),
          const SizedBox(height: 16),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 24, height: 1, margin: const EdgeInsets.only(top: 10), color: AppTheme.border),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(row, style: GoogleFonts.sourceSans3(fontSize: 14, height: 1.55, color: AppTheme.foreground)),
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
