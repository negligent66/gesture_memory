import 'package:flutter/material.dart';

enum GestureType {
  tapSingle,
  tapDouble,
  swipeLeft,
  swipeRight,
  swipeUp,
  swipeDown,
  tiltLeft,
  tiltRight,
}

extension GestureInfo on GestureType {
  String get emoji {
    switch (this) {
      case GestureType.tapSingle:  return '👆';
      case GestureType.tapDouble:  return '✌️';
      case GestureType.swipeLeft:  return '👈';
      case GestureType.swipeRight: return '👉';
      case GestureType.swipeUp:    return '☝️';
      case GestureType.swipeDown:  return '👇';
      case GestureType.tiltLeft:   return '↺';
      case GestureType.tiltRight:  return '↻';
    }
  }

  String get label {
    switch (this) {
      case GestureType.tapSingle:  return 'TAP';
      case GestureType.tapDouble:  return 'DOPPIO TAP';
      case GestureType.swipeLeft:  return 'SWIPE ←';
      case GestureType.swipeRight: return 'SWIPE →';
      case GestureType.swipeUp:    return 'SWIPE ↑';
      case GestureType.swipeDown:  return 'SWIPE ↓';
      case GestureType.tiltLeft:   return 'INCLINA ←';
      case GestureType.tiltRight:  return 'INCLINA →';
    }
  }

  Color get color {
    switch (this) {
      case GestureType.tapSingle:  return const Color(0xFF00E5FF);
      case GestureType.tapDouble:  return const Color(0xFF7C4DFF);
      case GestureType.swipeLeft:  return const Color(0xFFFF6D00);
      case GestureType.swipeRight: return const Color(0xFF00E676);
      case GestureType.swipeUp:    return const Color(0xFFFFD600);
      case GestureType.swipeDown:  return const Color(0xFFFF4081);
      case GestureType.tiltLeft:   return const Color(0xFF40C4FF);
      case GestureType.tiltRight:  return const Color(0xFF69F0AE);
    }
  }
}