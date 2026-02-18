import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  late SharedPreferences _prefs;

  bool _announceDistance = true;
  bool _announceCurrentSpeed = true;
  bool _announceAverageSpeed = true;
  bool _announcePace = false;
  bool _announceAltitude = false;
  bool _announceTime = true;
  double _distanceIntervalKm = 1.0;
  int _timeIntervalMinutes = 0;

  bool get announceDistance => _announceDistance;
  bool get announceCurrentSpeed => _announceCurrentSpeed;
  bool get announceAverageSpeed => _announceAverageSpeed;
  bool get announcePace => _announcePace;
  bool get announceAltitude => _announceAltitude;
  bool get announceTime => _announceTime;
  double get distanceIntervalKm => _distanceIntervalKm;
  int get timeIntervalMinutes => _timeIntervalMinutes;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _announceDistance = _prefs.getBool('announceDistance') ?? true;
    _announceCurrentSpeed = _prefs.getBool('announceCurrentSpeed') ?? true;
    _announceAverageSpeed = _prefs.getBool('announceAverageSpeed') ?? true;
    _announcePace = _prefs.getBool('announcePace') ?? false;
    _announceAltitude = _prefs.getBool('announceAltitude') ?? false;
    _announceTime = _prefs.getBool('announceTime') ?? true;
    _distanceIntervalKm = _prefs.getDouble('distanceIntervalKm') ?? 1.0;
    _timeIntervalMinutes = _prefs.getInt('timeIntervalMinutes') ?? 0;
  }

  Future<void> setAnnounceDistance(bool v) async { _announceDistance = v; await _prefs.setBool('announceDistance', v); notifyListeners(); }
  Future<void> setAnnounceCurrentSpeed(bool v) async { _announceCurrentSpeed = v; await _prefs.setBool('announceCurrentSpeed', v); notifyListeners(); }
  Future<void> setAnnounceAverageSpeed(bool v) async { _announceAverageSpeed = v; await _prefs.setBool('announceAverageSpeed', v); notifyListeners(); }
  Future<void> setAnnouncePace(bool v) async { _announcePace = v; await _prefs.setBool('announcePace', v); notifyListeners(); }
  Future<void> setAnnounceAltitude(bool v) async { _announceAltitude = v; await _prefs.setBool('announceAltitude', v); notifyListeners(); }
  Future<void> setAnnounceTime(bool v) async { _announceTime = v; await _prefs.setBool('announceTime', v); notifyListeners(); }
  Future<void> setDistanceIntervalKm(double v) async { _distanceIntervalKm = v; await _prefs.setDouble('distanceIntervalKm', v); notifyListeners(); }
  Future<void> setTimeIntervalMinutes(int v) async { _timeIntervalMinutes = v; await _prefs.setInt('timeIntervalMinutes', v); notifyListeners(); }
}
