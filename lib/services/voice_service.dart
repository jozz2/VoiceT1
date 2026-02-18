import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'settings_service.dart';
import 'tracking_service.dart';

class VoiceService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _isSpeaking = false;
  double _lastAnnouncedKm = 0.0;
  int _lastAnnouncedMinute = 0;

  bool get isSpeaking => _isSpeaking;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final languages = await _tts.getLanguages as List;
      if (languages.any((l) => l.toString().startsWith('sk'))) {
        await _tts.setLanguage('sk-SK');
      } else {
        await _tts.setLanguage('en-US');
      }
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _tts.setStartHandler(() { _isSpeaking = true; notifyListeners(); });
      _tts.setCompletionHandler(() { _isSpeaking = false; notifyListeners(); });
      _tts.setErrorHandler((_) { _isSpeaking = false; notifyListeners(); });
      _initialized = true;
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!_initialized) await init();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  void checkAndAnnounce(TrackingService tracking, SettingsService settings) {
    if (tracking.state != TrackingState.tracking) return;

    final distKm = tracking.totalDistance / 1000.0;
    final kmInterval = settings.distanceIntervalKm;
    if (kmInterval > 0 && distKm > 0) {
      final milestone = (distKm / kmInterval).floor() * kmInterval;
      if (milestone > _lastAnnouncedKm) {
        _lastAnnouncedKm = milestone;
        _announceStats(tracking, settings);
        return;
      }
    }

    final elapsedMin = tracking.elapsedTime.inMinutes;
    final timeInterval = settings.timeIntervalMinutes;
    if (timeInterval > 0 && elapsedMin > 0 && elapsedMin > _lastAnnouncedMinute) {
      if (elapsedMin % timeInterval == 0) {
        _lastAnnouncedMinute = elapsedMin;
        _announceStats(tracking, settings);
      }
    }
  }

  void _announceStats(TrackingService tracking, SettingsService settings) {
    final parts = <String>[];

    if (settings.announceDistance) {
      final km = tracking.totalDistance / 1000.0;
      if (km < 1.0) {
        parts.add('${(km * 1000).toStringAsFixed(0)} metrov');
      } else {
        parts.add('${km.toStringAsFixed(1)} kilometrov');
      }
    }
    if (settings.announceCurrentSpeed) {
      parts.add('Rýchlosť ${tracking.currentSpeedKmh.toStringAsFixed(1)} km/h');
    }
    if (settings.announceAverageSpeed) {
      parts.add('Priemer ${tracking.averageSpeedKmh.toStringAsFixed(1)} km/h');
    }
    if (settings.announcePace) {
      parts.add('Tempo ${tracking.averagePaceString} minút na kilometer');
    }
    if (settings.announceAltitude) {
      parts.add('Výška ${tracking.currentAltitude.toStringAsFixed(0)} metrov');
    }
    if (settings.announceTime) {
      parts.add('Čas ${tracking.elapsedTimeString}');
    }

    if (parts.isNotEmpty) speak(parts.join('. '));
  }

  void announceNow(TrackingService tracking, SettingsService settings) {
    _announceStats(tracking, settings);
  }

  Future<void> testSpeech() async {
    await speak('Test hlasového oznámenia. Päť kilometrov, rýchlosť desať km/h.');
  }

  void reset() {
    _lastAnnouncedKm = 0.0;
    _lastAnnouncedMinute = 0;
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
