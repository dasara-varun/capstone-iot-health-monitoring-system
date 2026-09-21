import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/editorial_card.dart';
import '../../core/widgets/page_frame.dart';
import '../../core/widgets/section_label.dart';
import '../../core/widgets/state_badge.dart';
import '../../models/device.dart';
import '../../state/app_state.dart';

class DevicesView extends StatelessWidget {
  final AppState state;

  const DevicesView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final devices = state.devices;

    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(text: 'Hardware registry'),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Edge devices',
                  style: GoogleFonts.playfairDisplay(fontSize: 36, height: 1.15, color: AppTheme.foreground),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.foreground),
                onPressed: state.refreshDevices,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Gateways, firmware, and the local store that keeps samples durable before the cloud ever sees them.',
            style: GoogleFonts.sourceSans3(fontSize: 16, height: 1.7, color: AppTheme.mutedForeground),
          ),
          const SizedBox(height: 28),
          ...devices.map(_buildDeviceCard),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(DeviceItem dev) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: EditorialCard(
        accentTop: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.muted,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Icon(Icons.memory_outlined, color: AppTheme.foreground, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dev.name,
                        style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          color: AppTheme.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'DEVICE  ${dev.deviceId}',
                        style: GoogleFonts.ibmPlexMono(fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedForeground),
                      ),
                    ],
                  ),
                ),
                StateBadge(state: dev.operatingState),
              ],
            ),
            const SizedBox(height: 22),
            const Divider(color: AppTheme.border),
            const SizedBox(height: 22),
            Wrap(
              spacing: 32,
              runSpacing: 18,
              children: [
                _buildInfoCol('Firmware', dev.softwareVersion),
                _buildInfoCol('Pending queue', '${dev.queueDepth} records'),
                _buildInfoCol('Storage', dev.storageCondition),
                _buildInfoCol('Sampling', '${dev.samplingIntervalSec}s'),
                _buildInfoCol('Last sync', dev.lastSync != null ? dev.lastSync!.split('T').last.split('.').first : 'None'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.ibmPlexMono(fontSize: 11, letterSpacing: 1.5, color: AppTheme.mutedForeground),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.sourceSans3(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.foreground),
        ),
      ],
    );
  }
}
