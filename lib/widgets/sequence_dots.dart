import 'package:flutter/material.dart';
import '../models/gesture_type.dart';
import '../models/game_phase.dart';

/// Animated progress dots showing the current sequence state.
class SequenceDots extends StatelessWidget {
  final List<GestureType> sequence;
  final int playerIndex;
  final int showingIndex;
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
      children: List.generate(sequence.length, (i) {
        final Color color;

        if (phase == GamePhase.showing) {
          color = i == showingIndex
              ? sequence[i].color
              : Colors.white.withOpacity(0.15);
        } else {
          color = i < playerIndex
              ? const Color(0xFF00E676)
              : Colors.white.withOpacity(0.15);
        }

        final isActive = i == showingIndex && phase == GamePhase.showing;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}