import 'package:flutter/material.dart';
import '../services/tracking_service.dart';

class ControlButtons extends StatelessWidget {
  final TrackingState state;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onReset;

  const ControlButtons({
    super.key,
    required this.state,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      TrackingState.idle => _btn('Štart', Icons.play_arrow_rounded, const Color(0xFF00C853), onStart, large: true),
      TrackingState.tracking => Row(children: [
          Expanded(child: _btn('Pauza', Icons.pause_rounded, const Color(0xFFFF9800), onPause)),
          const SizedBox(width: 12),
          Expanded(child: _btn('Stop', Icons.stop_rounded, const Color(0xFFEF5350), onStop)),
        ]),
      TrackingState.paused => Row(children: [
          Expanded(child: _btn('Pokračovať', Icons.play_arrow_rounded, const Color(0xFF00C853), onResume)),
          const SizedBox(width: 12),
          _iconBtn(Icons.restart_alt_rounded, onReset),
        ]),
    };
  }

  Widget _btn(String label, IconData icon, Color color, VoidCallback onPressed, {bool large = false}) {
    return SizedBox(
      height: large ? 68 : 58,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: large ? 26 : 22),
        label: Text(label, style: TextStyle(fontSize: large ? 17 : 15, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      height: 58, width: 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2A2A2A),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 26, color: Colors.white54),
      ),
    );
  }
}
