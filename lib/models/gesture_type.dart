// ============================================================
//  models/gesture_type.dart — Modello delle gesture di gioco
// ============================================================
//
//  Definisce tutte le gesture riconoscibili dal gioco e le
//  loro proprietà visive (emoji, etichetta testuale, colore).
//
//  Pattern usato: ENUM + EXTENSION
//  - L'enum elenca i valori possibili (dati "puri")
//  - L'extension aggiunge proprietà visuali senza sporcare l'enum
// ============================================================

import 'package:flutter/material.dart';

/// Enum che rappresenta tutti i tipi di gesture disponibili nel gioco.
///
/// Un enum in Dart è un insieme fisso di valori costanti.
/// Usare un enum invece di stringhe o interi garantisce type-safety:
/// il compilatore segnala errori se si usa un valore inesistente.
enum GestureType {
  tapSingle,   // Tocco singolo sullo schermo
  tapDouble,   // Doppio tocco rapido
  swipeLeft,   // Trascinamento verso sinistra
  swipeRight,  // Trascinamento verso destra
  swipeUp,     // Trascinamento verso l'alto
  swipeDown,   // Trascinamento verso il basso
  tiltLeft,    // Inclinazione del telefono a sinistra (asse X positivo)
  tiltRight,   // Inclinazione del telefono a destra (asse X negativo)
}

/// Extension che aggiunge proprietà visive all'enum [GestureType].
///
/// Le extension in Dart permettono di aggiungere metodi e proprietà
/// a un tipo esistente (anche tipi built-in come String o int)
/// senza modificarlo o creare una sottoclasse.
///
/// Vantaggio: la logica visiva (emoji, colori) è separata dalla
/// definizione dell'enum, rispettando il principio Single Responsibility.
extension GestureInfo on GestureType {

  /// Restituisce l'emoji associata alla gesture.
  /// Mostrata nella card durante la fase di visualizzazione.
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

  /// Restituisce il nome leggibile della gesture.
  /// Mostrato sotto l'emoji nella card e nei chip del game over.
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

  /// Restituisce il colore identificativo della gesture.
  /// Ogni gesture ha un colore unico usato per bordi, sfondi e glow.
  Color get color {
    switch (this) {
      case GestureType.tapSingle:  return const Color(0xFF00E5FF); // azzurro
      case GestureType.tapDouble:  return const Color(0xFF7C4DFF); // viola
      case GestureType.swipeLeft:  return const Color(0xFFFF6D00); // arancione
      case GestureType.swipeRight: return const Color(0xFF00E676); // verde
      case GestureType.swipeUp:    return const Color(0xFFFFD600); // giallo
      case GestureType.swipeDown:  return const Color(0xFFFF4081); // rosa
      case GestureType.tiltLeft:   return const Color(0xFF40C4FF); // azzurro chiaro
      case GestureType.tiltRight:  return const Color(0xFF69F0AE); // verde acqua
    }
  }
}