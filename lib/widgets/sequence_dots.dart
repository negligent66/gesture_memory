// ============================================================
//  widgets/sequence_dots.dart — Puntini di avanzamento
// ============================================================
//
//  Mostra una riga di puntini che rappresentano la sequenza.
//  Ogni puntino cambia colore e larghezza in base alla fase:
//
//  Durante "showing":
//    - Puntino attivo: colorato con il colore della gesture + più largo
//    - Gli altri: grigi
//
//  Durante "waiting":
//    - Gesture già fatte correttamente: verdi
//    - Gesture ancora da fare: grigie
// ============================================================

import 'package:flutter/material.dart';
import '../models/gesture_type.dart';
import '../models/game_phase.dart';

/// Riga di puntini animati che indicano l'avanzamento nella sequenza.
///
/// È uno [StatelessWidget]: non gestisce stato interno.
/// Riceve tutto ciò che serve dall'esterno come parametri.
class SequenceDots extends StatelessWidget {
  /// La sequenza completa: serve per sapere quanti puntini disegnare
  /// e di che colore colorare quello attivo durante la fase showing.
  final List<GestureType> sequence;

  /// Indice della prossima gesture da fare (fase waiting).
  /// I puntini con indice < playerIndex vengono colorati di verde.
  final int playerIndex;

  /// Indice della gesture attualmente mostrata (fase showing).
  /// Il puntino corrispondente viene evidenziato con il colore della gesture.
  final int showingIndex;

  /// La fase corrente del gioco: determina la logica di colorazione.
  final GamePhase phase;

  const SequenceDots({
    super.key,
    required this.sequence,
    required this.playerIndex,
    required this.showingIndex,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      // List.generate(n, builder) crea una lista di n elementi
      // chiamando builder(i) per ogni indice i da 0 a n-1.
      children: List.generate(sequence.length, (i) {
        // Determina il colore del puntino i in base alla fase corrente
        final Color color;

        if (phase == GamePhase.showing) {
          // Durante la fase showing: evidenzia il puntino della gesture corrente
          color = i == showingIndex
              ? sequence[i].color          // Colore univoco della gesture
              : Colors.white.withOpacity(0.15); // Grigio per gli altri
        } else {
          // Durante le fasi waiting/feedback: verde per le gesture già fatte
          color = i < playerIndex
              ? const Color(0xFF00E676)         // Verde = fatto correttamente
              : Colors.white.withOpacity(0.15); // Grigio = da fare ancora
        }

        // Il puntino attivo durante showing è più largo degli altri
        final isActive = i == showingIndex && phase == GamePhase.showing;

        // AnimatedContainer anima automaticamente le transizioni di
        // colore, larghezza e forma. Quando i valori cambiano con setState(),
        // Flutter interpola fluidamente tra vecchio e nuovo valore.
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200), // Durata della transizione
          margin: const EdgeInsets.symmetric(horizontal: 3), // Spazio tra i puntini
          width: isActive ? 20 : 10,  // Puntino attivo: 20px, gli altri: 10px
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5), // Forma a pillola
          ),
        );
      }),
    );
  }
}