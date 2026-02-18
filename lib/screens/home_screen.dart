import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tracking_service.dart';
import '../services/voice_service.dart';
import '../services/settings_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/control_buttons.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<VoiceService>().init();
    });
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) return (meters / 1000).toStringAsFixed(2);
    return meters.toStringAsFixed(0);
  }

  String _distanceUnit(double meters) => meters >= 1000 ? 'km' : 'm';

  @override
  Widget build(BuildContext context) {
    return Consumer3<TrackingService, VoiceService, SettingsService>(
      builder: (context, tracking, voice, settings, _) {
        if (tracking.state == TrackingState.tracking) {
          voice.checkAndAnnounce(tracking, settings);
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A0A0A),
            elevation: 0,
            title: const Row(
              children: [
                Icon(Icons.directions_run, color: Color(0xFF00C853), size: 26),
                SizedBox(width: 8),
                Text('Sport Tracker',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white70),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Čas
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: tracking.state == TrackingState.tracking
                            ? const Color(0xFF00C853).withOpacity(0.4)
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          tracking.elapsedTimeString,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 52,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tracking.state == TrackingState.idle
                              ? 'Pripravený'
                              : tracking.state == TrackingState.paused
                                  ? 'Pozastavené'
                                  : 'Prebieha',
                          style: TextStyle(
                            color: tracking.state == TrackingState.tracking
                                ? const Color(0xFF00C853)
                                : Colors.white38,
                            fontSize: 13,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StatCard(
                          label: 'Vzdialenosť',
                          value: _formatDistance(tracking.totalDistance),
                          unit: _distanceUnit(tracking.totalDistance),
                          icon: Icons.route,
                          color: const Color(0xFF00C853),
                        ),
                        StatCard(
                          label: 'Rýchlosť',
                          value: tracking.currentSpeedKmh.toStringAsFixed(1),
                          unit: 'km/h',
                          icon: Icons.speed,
                          color: const Color(0xFF2196F3),
                        ),
                        StatCard(
                          label: 'Priem. rýchlosť',
                          value: tracking.averageSpeedKmh.toStringAsFixed(1),
                          unit: 'km/h',
                          icon: Icons.trending_up,
                          color: const Color(0xFFFF9800),
                        ),
                        StatCard(
                          label: 'Tempo',
                          value: tracking.averagePaceString,
                          unit: 'min/km',
                          icon: Icons.timer,
                          color: const Color(0xFF9C27B0),
                        ),
                        StatCard(
                          label: 'Výška',
                          value: tracking.currentAltitude.toStringAsFixed(0),
                          unit: 'm n.m.',
                          icon: Icons.terrain,
                          color: const Color(0xFF00BCD4),
                        ),
                        StatCard(
                          label: 'GPS body',
                          value: tracking.points.length.toString(),
                          unit: 'bodov',
                          icon: Icons.gps_fixed,
                          color: const Color(0xFFE91E63),
                        ),
                      ],
                    ),
                  ),
                ),

                // Oznámiť teraz
                if (tracking.state == TrackingState.tracking)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => voice.announceNow(tracking, settings),
                        icon: const Icon(Icons.volume_up, size: 18),
                        label: const Text('Oznámiť teraz'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),

                // Tlačidlá
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ControlButtons(
                    state: tracking.state,
                    onStart: () { voice.reset(); tracking.startTracking(); },
                    onPause: tracking.pauseTracking,
                    onResume: tracking.resumeTracking,
                    onStop: () { tracking.stopTracking(); voice.stop(); },
                    onReset: () { tracking.resetTracking(); voice.reset(); },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
