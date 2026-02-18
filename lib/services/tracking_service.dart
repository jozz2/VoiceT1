import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum TrackingState { idle, tracking, paused }

class TrackPoint {
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final DateTime timestamp;

  TrackPoint({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.timestamp,
  });
}

class TrackingService extends ChangeNotifier {
  TrackingState _state = TrackingState.idle;
  List<TrackPoint> _points = [];
  StreamSubscription<Position>? _positionSubscription;

  double _totalDistance = 0.0;
  double _currentSpeed = 0.0;
  double _currentAltitude = 0.0;
  Duration _elapsedTime = Duration.zero;
  Timer? _timer;
  DateTime? _startTime;
  DateTime? _pauseTime;
  Duration _pausedDuration = Duration.zero;

  TrackingState get state => _state;
  double get totalDistance => _totalDistance;
  double get currentSpeedKmh => _currentSpeed * 3.6;
  double get currentAltitude => _currentAltitude;
  Duration get elapsedTime => _elapsedTime;
  List<TrackPoint> get points => List.unmodifiable(_points);

  double get averageSpeedKmh {
    final seconds = _elapsedTime.inSeconds;
    if (seconds == 0 || _totalDistance == 0) return 0.0;
    return (_totalDistance / seconds) * 3.6;
  }

  String get currentPaceString {
    if (_currentSpeed < 0.5) return '--:--';
    final secsPerKm = 1000 / _currentSpeed;
    final mins = (secsPerKm / 60).floor();
    final secs = (secsPerKm % 60).floor();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String get averagePaceString {
    final avgMs = averageSpeedKmh / 3.6;
    if (avgMs < 0.5) return '--:--';
    final secsPerKm = 1000 / avgMs;
    final mins = (secsPerKm / 60).floor();
    final secs = (secsPerKm % 60).floor();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String get elapsedTimeString {
    final h = _elapsedTime.inHours;
    final m = _elapsedTime.inMinutes % 60;
    final s = _elapsedTime.inSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<bool> requestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> startTracking() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) return;
    _state = TrackingState.tracking;
    _startTime = DateTime.now();
    _pausedDuration = Duration.zero;
    _points = [];
    _totalDistance = 0.0;
    _currentSpeed = 0.0;
    _startTimer();
    _startLocationUpdates();
    notifyListeners();
  }

  void pauseTracking() {
    if (_state != TrackingState.tracking) return;
    _state = TrackingState.paused;
    _pauseTime = DateTime.now();
    _timer?.cancel();
    _positionSubscription?.pause();
    notifyListeners();
  }

  void resumeTracking() {
    if (_state != TrackingState.paused) return;
    _state = TrackingState.tracking;
    if (_pauseTime != null) {
      _pausedDuration += DateTime.now().difference(_pauseTime!);
    }
    _startTimer();
    _positionSubscription?.resume();
    notifyListeners();
  }

  void stopTracking() {
    _state = TrackingState.idle;
    _timer?.cancel();
    _positionSubscription?.cancel();
    _positionSubscription = null;
    notifyListeners();
  }

  void resetTracking() {
    stopTracking();
    _points = [];
    _totalDistance = 0.0;
    _currentSpeed = 0.0;
    _currentAltitude = 0.0;
    _elapsedTime = Duration.zero;
    _startTime = null;
    _pauseTime = null;
    _pausedDuration = Duration.zero;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime != null) {
        _elapsedTime = DateTime.now().difference(_startTime!) - _pausedDuration;
        notifyListeners();
      }
    });
  }

  void _startLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_onPositionUpdate, onError: (e) => debugPrint('GPS error: $e'));
  }

  void _onPositionUpdate(Position position) {
    final newPoint = TrackPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      speed: position.speed < 0 ? 0 : position.speed,
      timestamp: DateTime.now(),
    );
    _currentSpeed = newPoint.speed;
    _currentAltitude = newPoint.altitude;

    if (_points.isNotEmpty) {
      final dist = _calculateDistance(
        _points.last.latitude, _points.last.longitude,
        newPoint.latitude, newPoint.longitude,
      );
      if (dist >= 3.0) {
        _totalDistance += dist;
        _points.add(newPoint);
      }
    } else {
      _points.add(newPoint);
    }
    notifyListeners();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;

  @override
  void dispose() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }
}
