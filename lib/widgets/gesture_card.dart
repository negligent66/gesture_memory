import 'package:flutter/material.dart';
import '../models/gesture_type.dart';

/// Shows a single gesture with emoji + optional label inside a glowing card.
class GestureCard extends StatelessWidget {
  final GestureType gesture;
  final double size;
  final bool showLabel;
  final Animation<double>? fadeAnimation;
  final Object? animationKey;

  const GestureCard({
    super.key,
    required this.gesture,
    this.size = 180,
    this.showLabel = true,
    this.fadeAnimation,
    this.animationKey,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      key: animationKey != null ? ValueKey(animationKey) : null,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: gesture.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: gesture.color, width: 2),
        boxShadow: [
          BoxShadow(
            color: gesture.color.withOpacity(0.4),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            gesture.emoji,
            style: TextStyle(fontSize: size * 0.35),
          ),
          if (showLabel) ...[
            const SizedBox(height: 8),
            Text(
              gesture.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: gesture.color,
              ),
            ),
          ],
        ],
      ),
    );

    if (fadeAnimation != null) {
      return FadeTransition(opacity: fadeAnimation!, child: card);
    }
    return card;
  }
}