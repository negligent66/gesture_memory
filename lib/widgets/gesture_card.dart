// ============================================================
//  widgets/gesture_card.dart — Card animata per una gesture
// ============================================================
//
//  Widget riutilizzabile che mostra una gesture dentro una card
//  con bordo colorato e effetto glow.
//
//  È uno StatelessWidget: non ha stato proprio, dipende solo
//  dai parametri che riceve dall'esterno.
//
//  Usato in GameScreen durante la fase "showing" per mostrare
//  le gesture della sequenza.
// ============================================================

import 'package:flutter/material.dart';
import '../models/gesture_type.dart';

/// Card che mostra emoji + label di una gesture, con effetto glow colorato.
///
/// Accetta un'[Animation<double>] opzionale per il fade-in:
/// se fornita, la card appare con una transizione di opacità.
class GestureCard extends StatelessWidget {
  /// La gesture da mostrare.
  final GestureType gesture;

  /// Dimensione del lato della card in pixel. Default: 180.
  final double size;

  /// Se true, mostra anche il testo dell'etichetta sotto l'emoji.
  final bool showLabel;

  /// Animazione opzionale di fade-in.
  /// Se null, la card è sempre visibile senza animazione.
  final Animation<double>? fadeAnimation;

  /// Key alternativa da passare al Container interno.
  /// Usato da AnimatedSwitcher per identificare i widget.
  final Object? animationKey;

  const GestureCard({
    super.key,
    required this.gesture,
    this.size = 180,          // Valore di default
    this.showLabel = true,    // Di default mostra l'etichetta
    this.fadeAnimation,       // Opzionale (null = nessuna animazione)
    this.animationKey,
  });

  @override
  Widget build(BuildContext context) {
    // Costruisce la card vera e propria
    final card = Container(
      // Se animationKey è fornito, lo usa come ValueKey.
      // Questo permette ad AnimatedSwitcher di identificare univocamente il widget.
      key: animationKey != null ? ValueKey(animationKey) : null,
      width: size,
      height: size,
      decoration: BoxDecoration(
        // Sfondo con il colore della gesture molto trasparente (12%)
        color: gesture.color.withOpacity(0.12),

        // Arrotondamento proporzionale alla dimensione (30% del lato)
        borderRadius: BorderRadius.circular(size * 0.3),

        // Bordo colorato con il colore univoco della gesture
        border: Border.all(color: gesture.color, width: 2),

        // Glow effect: ombra dello stesso colore del bordo
        boxShadow: [
          BoxShadow(
            color: gesture.color.withOpacity(0.4),
            blurRadius: 40,   // Quanto è sfumato il glow
            spreadRadius: 4,  // Quanto si estende oltre i bordi
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji: dimensione proporzionale alla card (35% del lato)
          Text(
            gesture.emoji,
            style: TextStyle(fontSize: size * 0.35),
          ),

          // Etichetta testuale (solo se showLabel è true)
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

    // Se è stata fornita un'animazione, avvolge la card in FadeTransition
    if (fadeAnimation != null) {
      // FadeTransition cambia l'opacità del figlio in base al valore
      // dell'animazione (0 = trasparente, 1 = opaco)
      return FadeTransition(opacity: fadeAnimation!, child: card);
    }

    // Altrimenti restituisce la card senza animazione
    return card;
  }
}