import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'state/app_state.dart';
import 'features/overview/overview_view.dart';
import 'features/history/history_view.dart';
import 'features/alerts/alerts_view.dart';
import 'features/devices/devices_view.dart';
import 'features/tests/tests_view.dart';
import 'features/auth/login_dialog.dart';

class HealthMonitoringApp extends StatefulWidget {
  final AppState state;

  const HealthMonitoringApp({super.key, required this.state});

  @override
  State<HealthMonitoringApp> createState() => _HealthMonitoringAppState();
}

class _HealthMonitoringAppState extends State<HealthMonitoringApp> {
  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onStateChange);
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  Widget _getCurrentView() {
    switch (widget.state.selectedNavIndex) {
      case 0:
        return OverviewView(state: widget.state);
      case 1:
        return HistoryView(state: widget.state);
      case 2:
        return AlertsView(state: widget.state);
      case 3:
        return DevicesView(state: widget.state);
      case 4:
        return TestsView(state: widget.state);
      default:
        return OverviewView(state: widget.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud IoT Health Monitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          toolbarHeight: 72,
          titleSpacing: 24,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: AppTheme.border),
          ),
          title: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'IoT Health Monitor',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.foreground,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'REVIEW 2',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.8,
                  color: AppTheme.mutedForeground,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.muted,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.state.userRole == 'operator' ? Icons.admin_panel_settings_outlined : Icons.person_outline,
                    size: 16,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.state.currentUser}  ·  ${widget.state.userRole}',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: AppTheme.foreground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                showDialog(context: context, builder: (_) => LoginDialog(state: widget.state));
              },
              child: Text(
                'Sign in',
                style: GoogleFonts.sourceSans3(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accent,
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.accent,
                  decorationThickness: 1,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 768;

            if (isWide) {
              return Row(
                children: [
                  NavigationRail(
                    selectedIndex: widget.state.selectedNavIndex,
                    onDestinationSelected: widget.state.setNavIndex,
                    backgroundColor: AppTheme.card,
                    indicatorColor: AppTheme.muted,
                    selectedIconTheme: const IconThemeData(color: AppTheme.accent),
                    unselectedIconTheme: const IconThemeData(color: AppTheme.mutedForeground),
                    labelType: NavigationRailLabelType.all,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.menu_book_outlined),
                        selectedIcon: Icon(Icons.menu_book),
                        label: Text('Overview'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.history_edu_outlined),
                        selectedIcon: Icon(Icons.history_edu),
                        label: Text('History'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.notifications_none_outlined),
                        selectedIcon: Icon(Icons.notifications_none),
                        label: Text('Alerts'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.memory_outlined),
                        selectedIcon: Icon(Icons.memory),
                        label: Text('Devices'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.science_outlined),
                        selectedIcon: Icon(Icons.science),
                        label: Text('Tests'),
                      ),
                    ],
                  ),
                  const VerticalDivider(width: 1, thickness: 1, color: AppTheme.border),
                  Expanded(child: ColoredBox(color: AppTheme.background, child: _getCurrentView())),
                ],
              );
            } else {
              return _getCurrentView();
            }
          },
        ),
        bottomNavigationBar: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <= 768) {
              return Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppTheme.border)),
                  color: AppTheme.card,
                ),
                child: BottomNavigationBar(
                  currentIndex: widget.state.selectedNavIndex,
                  onTap: widget.state.setNavIndex,
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Overview'),
                    BottomNavigationBarItem(icon: Icon(Icons.history_edu_outlined), label: 'History'),
                    BottomNavigationBarItem(icon: Icon(Icons.notifications_none_outlined), label: 'Alerts'),
                    BottomNavigationBarItem(icon: Icon(Icons.memory_outlined), label: 'Devices'),
                    BottomNavigationBarItem(icon: Icon(Icons.science_outlined), label: 'Tests'),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
