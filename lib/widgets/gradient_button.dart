// ============================================================
//  widgets/gradient_button.dart — Bottone con gradiente
// ============================================================
//
//  Widget riutilizzabile per bottoni a forma di pillola con
//  sfondo a gradiente e ombra colorata (glow effect).
//
//  Usato in GameOverScreen per i bottoni "RIPROVA" e "MENU".
//  La stessa classe gestisce entrambi passando colori diversi:
//  questo evita la duplicazione del codice (principio DRY:
//  Don't Repeat Yourself).
// ============================================================

import 'package:flutter/material.dart';

/// Bottone a pillola con gradiente e glow.
///
/// [StatelessWidget] perché non ha stato: la sua UI dipende
/// solo dai parametri ricevuti nel costruttore.
class GradientButton extends StatelessWidget {
  /// Testo da mostrare nel bottone.
  final String label;

  /// Lista di colori per il gradiente di sfondo.
  /// Minimo 2 colori. Il gradiente va da sinistra (primo) a destra (ultimo).
  final List<Color> colors;

  /// Callback chiamato quando il bottone viene premuto.
  /// VoidCallback è un alias per Function() (funzione senza parametri e senza return).
  final VoidCallback onTap;

  const GradientButton({
    super.key,
    required this.label,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Chiama il callback quando premuto
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          // Gradiente con i colori passati come parametro
          gradient: LinearGradient(colors: colors),

          // Bordi arrotondati a forma di pillola
          borderRadius: BorderRadius.circular(28),

          // Ombra colorata per effetto glow.
          // Usa il primo colore della lista per il glow.
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 16,  // Diffusione dell'ombra
              spreadRadius: 1, // Espansione dell'ombra
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            letterSpacing: 3, // Spaziatura tra le lettere
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}