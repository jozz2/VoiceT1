import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/voice_service.dart';
import '../services/tracking_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final voice = context.read<VoiceService>();
    final tracking = context.read<TrackingService>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text('Nastavenia', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header('🔊 Čo oznamovať hlasom'),
          _card([
            _toggle('Vzdialenosť', Icons.route, settings.announceDistance, settings.setAnnounceDistance),
            _divider(),
            _toggle('Aktuálna rýchlosť', Icons.speed, settings.announceCurrentSpeed, settings.setAnnounceCurrentSpeed),
            _divider(),
            _toggle('Priemerná rýchlosť', Icons.trending_up, settings.announceAverageSpeed, settings.setAnnounceAverageSpeed),
            _divider(),
            _toggle('Tempo (min/km)', Icons.timer, settings.announcePace, settings.setAnnouncePace),
            _divider(),
            _toggle('Výška nad morom', Icons.terrain, settings.announceAltitude, settings.setAnnounceAltitude),
            _divider(),
            _toggle('Čas aktivity', Icons.access_time, settings.announceTime, settings.setAnnounceTime),
          ]),

          const SizedBox(height: 20),
          _header('⏱ Intervaly'),
          _card([
            _sliderTile(
              'Každých X km',
              Icons.route,
              const Color(0xFF00C853),
              settings.distanceIntervalKm,
              0, 10, 20,
              (v) => settings.distanceIntervalKm == 0 ? 'Vypnuté' : '${v.toStringAsFixed(1)} km',
              (v) => settings.setDistanceIntervalKm(double.parse(v.toStringAsFixed(1))),
            ),
            _divider(),
            _sliderTile(
              'Každých X minút',
              Icons.access_time,
              const Color(0xFFFF9800),
              settings.timeIntervalMinutes.toDouble(),
              0, 30, 6,
              (v) => v == 0 ? 'Vypnuté' : '${v.round()} min',
              (v) => settings.setTimeIntervalMinutes(v.round()),
            ),
          ]),

          const SizedBox(height: 20),
          _header('🧪 Test'),
          _card([
            ListTile(
              leading: const Icon(Icons.volume_up, color: Color(0xFF2196F3)),
              title: const Text('Testovať hlas', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Prehrá ukážkové oznámenie', style: TextStyle(color: Colors.white54, fontSize: 12)),
              trailing: const Icon(Icons.play_arrow, color: Colors.white38),
              onTap: () => voice.testSpeech(),
            ),
            _divider(),
            ListTile(
              leading: const Icon(Icons.mic, color: Color(0xFF00C853)),
              title: const Text('Oznámiť aktuálne', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Prečíta aktuálne hodnoty', style: TextStyle(color: Colors.white54, fontSize: 12)),
              trailing: const Icon(Icons.play_arrow, color: Colors.white38),
              onTap: () => voice.announceNow(tracking, settings),
            ),
          ]),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _header(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(title, style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
  );

  Widget _card(List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(children: children),
  );

  Widget _divider() => const Divider(color: Colors.white12, height: 1);

  Widget _toggle(String title, IconData icon, bool value, Future<void> Function(bool) onChanged) {
    return SwitchListTile(
      secondary: Icon(icon, size: 22, color: value ? const Color(0xFF00C853) : Colors.white38),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
      value: value,
      activeColor: const Color(0xFF00C853),
      onChanged: onChanged,
    );
  }

  Widget _sliderTile(String title, IconData icon, Color color, double value,
      double min, double max, int divisions,
      String Function(double) labelBuilder, void Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
            const Spacer(),
            Text(labelBuilder(value), style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          ]),
          Slider(
            value: value,
            min: min, max: max, divisions: divisions,
            activeColor: color,
            inactiveColor: Colors.white12,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
