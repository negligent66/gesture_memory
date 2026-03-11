// ============================================================
//  screens/game_over_screen.dart — Schermata Fine Partita
// ============================================================
//
//  Mostrata quando il giocatore sbaglia una gesture.
//  È uno StatelessWidget perché non ha animazioni proprie:
//  riceve tutto ciò che deve mostrare come parametri immutabili.
//
//  Mostra:
//    - Il livello raggiunto
//    - Quale gesture era richiesta vs quale è stata fatta
//    - La sequenza completa con indicazione errori/successi
//    - Bottoni per riprovare o tornare al menu
// ============================================================

import 'package:flutter/material.dart';
import '../models/gesture_type.dart';
import '../widgets/gradient_button.dart';
import 'game_screen.dart';

/// Schermata Game Over.
///
/// Riceve i dati dell'errore da GameScreen come parametri costruttore.
/// Questo è il modo corretto in Flutter di passare dati tra schermate:
/// non si usa uno stato globale, si passano i dati direttamente.
class GameOverScreen extends StatelessWidget {
  /// La sequenza completa di gesture del round in corso.
  final List<GestureType> sequence;

  /// L'indice nella sequenza della gesture sbagliata.
  /// Es: se wrongIndex = 2, il giocatore ha sbagliato la terza gesture.
  final int wrongIndex;

  /// La gesture che il giocatore ha effettivamente eseguito.
  /// Può essere null se il giocatore non ha fatto nulla (timeout o errore di rilevamento).
  final GestureType? wrongGesture;

  const GameOverScreen({
    super.key,
    required this.sequence,
    required this.wrongIndex,
    required this.wrongGesture,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        // SingleChildScrollView permette lo scroll se il contenuto
        // supera l'altezza dello schermo (ad es. con sequenze molto lunghe)
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildDeathIcon(),
              const SizedBox(height: 16),
              _buildScore(),
              const SizedBox(height: 32),
              _buildMistakeBox(),    // Il confronto richiesto vs fatto
              const SizedBox(height: 28),
              _buildSequenceReview(), // Tutta la sequenza con stato per gesture
              const SizedBox(height: 40),
              _buildActions(context), // Bottoni Riprova / Menu
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Emoji scherzosa di game over.
  Widget _buildDeathIcon() {
    return const Text('💀', style: TextStyle(fontSize: 72));
  }

  /// Mostra il titolo GAME OVER e il livello raggiunto.
  Widget _buildScore() {
    return Column(
      children: [
        const Text(
          'GAME OVER',
          style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: 6, color: Color(0xFFFF1744)),
        ),
        const SizedBox(height: 6),
        Text(
          'Hai raggiunto il livello',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, letterSpacing: 1.5),
        ),
        // Il livello corrisponde alla lunghezza della sequenza
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
          ).createShader(b),
          child: Text(
            '${sequence.length}', // Converte int in String con ${}
            style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// Box che mostra esattamente il confronto tra richiesto e fatto.
  ///
  /// Questo è utile sia per il giocatore (capisce dove ha sbagliato)
  /// che per il debug (verifica che il rilevamento funzioni correttamente).
  Widget _buildMistakeBox() {
    // La gesture che DOVEVA fare il giocatore
    final expected = sequence[wrongIndex];
    // La gesture che HA FATTO il giocatore (potrebbe essere null)
    final actual = wrongGesture;

    return Container(
      width: double.infinity, // Larghezza massima disponibile
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF1744).withOpacity(0.07), // Rosso molto trasparente
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF1744).withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          // Titolo del box: indica a che passo è avvenuto l'errore
          // wrongIndex + 1 perché gli indici partono da 0 ma per l'utente da 1
          Text(
            'ERRORE AL PASSO ${wrongIndex + 1}',
            style: const TextStyle(color: Color(0xFFFF1744), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Sinistra: cosa era richiesto
              _buildCompareCard(label: 'RICHIESTO', gesture: expected, borderColor: expected.color),

              // Freccia al centro
              Column(
                children: [
                  const SizedBox(height: 16),
                  Icon(Icons.arrow_forward, color: Colors.white.withOpacity(0.2), size: 28),
                ],
              ),

              // Destra: cosa ha fatto il giocatore (o '?' se null)
              actual != null
                  ? _buildCompareCard(
                label: 'HAI FATTO',
                gesture: actual,
                borderColor: const Color(0xFFFF1744), // Rosso perché sbagliata
                isWrong: true,
              )
                  : _buildEmptyCard(), // Se il giocatore non ha fatto nulla
            ],
          ),
        ],
      ),
    );
  }

  /// Card che mostra una gesture nel box di confronto.
  ///
  /// [isWrong] cambia il colore del testo dell'etichetta in rosso.
  Widget _buildCompareCard({
    required String label,
    required GestureType gesture,
    required Color borderColor,
    bool isWrong = false,
  }) {
    return Column(
      children: [
        // Etichetta sopra la card ("RICHIESTO" o "HAI FATTO")
        Text(
          label,
          style: TextStyle(
            color: isWrong ? const Color(0xFFFF1744) : Colors.white.withOpacity(0.4),
            fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            color: borderColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [BoxShadow(color: borderColor.withOpacity(0.25), blurRadius: 16, spreadRadius: 2)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(gesture.emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 4),
              Text(
                gesture.label,
                textAlign: TextAlign.center,
                style: TextStyle(color: borderColor, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Card con '?' mostrata quando il giocatore non ha rilevato nessuna gesture.
  Widget _buildEmptyCard() {
    return Column(
      children: [
        Text('HAI FATTO', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
          ),
          child: Center(child: Text('?', style: TextStyle(fontSize: 36, color: Colors.white.withOpacity(0.2)))),
        ),
      ],
    );
  }

  /// Mostra l'intera sequenza con lo stato visivo di ogni gesture.
  Widget _buildSequenceReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'SEQUENZA COMPLETA',
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8, runSpacing: 8,
          alignment: WrapAlignment.center,
          // asMap() converte la lista in una Map<int, GestureType>
          // così possiamo accedere sia all'indice che al valore.
          // entries restituisce Iterable<MapEntry<int, GestureType>>
          children: sequence.asMap().entries.map((entry) {
            final i = entry.key;   // Indice (0, 1, 2, ...)
            final g = entry.value; // Gesture corrispondente
            final isError = i == wrongIndex; // Questa è quella sbagliata?
            final isDone = i < wrongIndex;   // Questa era già stata fatta correttamente?

            return _SequenceChip(gesture: g, isError: isError, isDone: isDone, index: i);
          }).toList(),
        ),
      ],
    );
  }

  /// Bottoni di azione: Riprova e Menu.
  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GradientButton(
          label: 'RIPROVA',
          colors: const [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
          // pushReplacement sostituisce GameOverScreen con una nuova GameScreen
          // nello stack. Così non si accumula la cronologia delle partite.
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const GameScreen()),
          ),
        ),
        const SizedBox(width: 16),
        GradientButton(
          label: 'MENU',
          colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
          // pop() rimuove GameOverScreen e torna alla HomeScreen
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

/// Widget privato per ogni chip nella sequenza completa.
///
/// Il prefisso '_' indica che è privato al file: non può essere
/// usato in altri file. È un dettaglio implementativo di GameOverScreen.
class _SequenceChip extends StatelessWidget {
  final GestureType gesture;
  final bool isError;  // true se questa è la gesture sbagliata
  final bool isDone;   // true se questa gesture era già stata fatta correttamente
  final int index;     // Numero del passo (0-based)

  const _SequenceChip({
    required this.gesture,
    required this.isError,
    required this.isDone,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Determina colori in base allo stato del chip
    final Color borderColor;
    final Color bgColor;

    if (isError) {
      borderColor = const Color(0xFFFF1744); // Rosso = sbagliata
      bgColor = const Color(0xFFFF1744).withOpacity(0.15);
    } else if (isDone) {
      borderColor = const Color(0xFF00E676).withOpacity(0.6); // Verde = corretta
      bgColor = const Color(0xFF00E676).withOpacity(0.08);
    } else {
      borderColor = gesture.color.withOpacity(0.35); // Colore normale = non raggiunta
      bgColor = gesture.color.withOpacity(0.08);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: isError ? 2 : 1), // Bordo più spesso per l'errore
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // La Row occupa solo lo spazio necessario
        children: [
          // Numero del passo (index + 1 perché mostriamo da 1, non da 0)
          Text(
            '${index + 1}',
            style: TextStyle(
              color: isError ? const Color(0xFFFF1744)
                  : isDone ? const Color(0xFF00E676)
                  : Colors.white.withOpacity(0.25),
              fontSize: 9, fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 5),
          Text(gesture.emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 5),
          Text(
            gesture.label,
            style: TextStyle(
              color: isError ? const Color(0xFFFF1744)
                  : isDone ? const Color(0xFF00E676).withOpacity(0.8)
                  : gesture.color.withOpacity(0.7),
              fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5,
            ),
          ),
          // Icona di stato: X per errore, ✓ per corretta
          if (isError) ...[
            const SizedBox(width: 5),
            const Icon(Icons.close, color: Color(0xFFFF1744), size: 12),
          ] else if (isDone) ...[
            const SizedBox(width: 5),
            const Icon(Icons.check, color: Color(0xFF00E676), size: 12),
          ],
          // Le gesture non ancora raggiunte non hanno icona
        ],
      ),
    );
  }
}