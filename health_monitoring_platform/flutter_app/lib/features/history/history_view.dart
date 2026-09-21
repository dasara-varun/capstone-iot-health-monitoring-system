import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/editorial_card.dart';
import '../../core/widgets/page_frame.dart';
import '../../core/widgets/quality_pill.dart';
import '../../core/widgets/section_label.dart';
import '../../core/widgets/severity_pill.dart';
import '../../models/observation.dart';
import '../../state/app_state.dart';

class HistoryView extends StatelessWidget {
  final AppState state;

  const HistoryView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final observations = state.observations;

    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(text: 'Audit trail'),
          Text(
            'Observations',
            style: GoogleFonts.playfairDisplay(fontSize: 36, height: 1.15, color: AppTheme.foreground),
          ),
          const SizedBox(height: 8),
          Text(
            'A chronological ledger of processed samples, quality gates, and deviations.',
            style: GoogleFonts.sourceSans3(fontSize: 16, height: 1.7, color: AppTheme.mutedForeground),
          ),
          const SizedBox(height: 24),
          _buildFilterBar(),
          const SizedBox(height: 20),
          EditorialCard(
            padding: const EdgeInsets.all(8),
            hoverEffect: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        'RECORDS',
                        style: GoogleFonts.ibmPlexMono(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          letterSpacing: 1.6,
                          color: AppTheme.mutedForeground,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${observations.length} entries',
                        style: GoogleFonts.sourceSans3(fontSize: 13, color: AppTheme.mutedForeground),
                      ),
                    ],
                  ),
                ),
                if (observations.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        'No observations match the selected criteria.',
                        style: GoogleFonts.sourceSans3(color: AppTheme.mutedForeground),
                      ),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 48,
                      dataRowMinHeight: 48,
                      dataRowMaxHeight: 56,
                      columns: const [
                        DataColumn(label: Text('EVENT TIME')),
                        DataColumn(label: Text('SENSOR')),
                        DataColumn(label: Text('RAW')),
                        DataColumn(label: Text('PROCESSED')),
                        DataColumn(label: Text('QUALITY')),
                        DataColumn(label: Text('BASELINE')),
                        DataColumn(label: Text('DEVIATION')),
                        DataColumn(label: Text('SEVERITY')),
                        DataColumn(label: Text('REASONS')),
                        DataColumn(label: Text('TYPE')),
                      ],
                      rows: observations.map(_buildDataRow).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return EditorialCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Wrap(
        spacing: 20,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildDropdown('Sensor', state.filterSensor, ['ALL', 'spo2', 'heart_rate', 'temperature'], (v) {
            state.setFilters(sensor: v);
          }),
          _buildDropdown('Severity', state.filterSeverity, ['ALL', 'NORMAL', 'OBSERVE', 'REVIEW'], (v) {
            state.setFilters(severity: v);
          }),
          _buildDropdown('Quality', state.filterQuality, ['ALL', 'ACCEPTABLE', 'LOW', 'INVALID'], (v) {
            state.setFilters(quality: v);
          }),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: AppTheme.foreground),
            onPressed: state.refreshObservations,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String currentVal, List<String> items, ValueChanged<String?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${label.toUpperCase()}  ',
          style: GoogleFonts.ibmPlexMono(fontSize: 11, letterSpacing: 1.4, color: AppTheme.mutedForeground),
        ),
        const SizedBox(width: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentVal,
              style: GoogleFonts.sourceSans3(fontSize: 13, color: AppTheme.foreground, fontWeight: FontWeight.w600),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(Observation obs) {
    final timeStr = obs.eventTime.contains('T')
        ? obs.eventTime.split('T').last.split('+').first.split('Z').first
        : obs.eventTime;

    return DataRow(
      cells: [
        DataCell(Text(timeStr, style: GoogleFonts.ibmPlexMono(fontSize: 12))),
        DataCell(Text(obs.sensor.toUpperCase(), style: GoogleFonts.sourceSans3(fontWeight: FontWeight.w700, fontSize: 12))),
        DataCell(Text(obs.rawValue != null ? '${obs.rawValue} ${obs.unit}' : '—')),
        DataCell(Text(
          obs.processedValue != null ? '${obs.processedValue} ${obs.unit}' : '—',
          style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w500),
        )),
        DataCell(QualityPill(status: obs.qualityStatus, score: obs.qualityScore)),
        DataCell(Text(obs.baseline != null ? '${obs.baseline}' : '—')),
        DataCell(Text(
          obs.deviation != null ? '${obs.deviation! >= 0 ? '+' : ''}${obs.deviation}' : '—',
          style: GoogleFonts.sourceSans3(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: obs.deviation != null && obs.deviation!.abs() > 3 ? AppTheme.observe : AppTheme.foreground,
          ),
        )),
        DataCell(SeverityPill(severity: obs.severity)),
        DataCell(Text(
          obs.reasonCodes.isEmpty ? 'normal' : obs.reasonCodes.join(', '),
          style: GoogleFonts.sourceSans3(fontSize: 12, color: AppTheme.mutedForeground),
        )),
        DataCell(Text(
          obs.isFixture ? 'SIMULATED' : 'SENSOR',
          style: GoogleFonts.ibmPlexMono(
            fontSize: 10,
            letterSpacing: 1.2,
            color: obs.isFixture ? AppTheme.mutedForeground : AppTheme.healthy,
          ),
        )),
      ],
    );
  }
}
