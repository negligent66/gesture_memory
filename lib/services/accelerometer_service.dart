import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/gesture_type.dart';

/// Listens to the accelerometer and fires callbacks for tilt only.
class AccelerometerService {
  StreamSubscription? _subscription;
  bool _tiltCooldown = false;

  final void Function(GestureType) onGesture;
  bool active = false;

  AccelerometerService({required this.onGesture});

  void start() {
    _subscription = accelerometerEventStream().listen(_onEvent);
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _onEvent(AccelerometerEvent event) {
    if (!active) return;
    _detectTilt(event);
  }

  void _detectTilt(AccelerometerEvent event) {
    if (_tiltCooldown) return;

    if (event.x < -3.5) {
      _fireTilt(GestureType.tiltRight);
    } else if (event.x > 3.5) {
      _fireTilt(GestureType.tiltLeft);
    }
  }

  void _fireTilt(GestureType type) {
    _tiltCooldown = true;
    onGesture(type);
    Future.delayed(const Duration(milliseconds: 1400), () {
      _tiltCooldown = false;
    });
  }
}