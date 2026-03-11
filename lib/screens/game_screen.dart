// ============================================================
//  screens/game_screen.dart — Schermata di gioco principale
// ============================================================
//
//  Questo è il cuore dell'app. Gestisce:
//    - La sequenza di gesture da mostrare
//    - Il rilevamento dell'input del giocatore (touch + accelerometro)
//    - L'avanzamento del gioco (round, livelli)
//    - L'intera UI della partita
//
//  Flusso di gioco:
//    initState() → _nextRound() → _showSequence() → fase waiting
//    → il giocatore fa gesture → _onGestureDetected() → confronto
//    → se giusto: _onRoundComplete() → _nextRound() (loop)
//    → se sbagliato: _onWrongGesture() → GameOverScreen
// ============================================================

import 'dart:math'; // Per Random
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Per HapticFeedback
import '../models/gesture_type.dart';
import '../models/game_phase.dart';
import '../services/accelerometer_service.dart';
import '../widgets/gesture_card.dart';
import '../widgets/sequence_dots.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

/// Stato della GameScreen.
///
/// Usa [TickerProviderStateMixin] (plurale, senza "Single") perché
/// gestisce DUE AnimationController contemporaneamente:
/// _flashCtrl (per la card) e _shakeCtrl (non più usato ma tenuto).
class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {

  // ── STATO DEL GIOCO ───────────────────────────────────────

  /// Generatore di numeri casuali per scegliere le gesture della sequenza.
  final Random _rng = Random();

  /// La sequenza completa di gesture da riprodurre.
  /// Inizia vuota e cresce di 1 ad ogni round vinto.
  final List<GestureType> _sequence = [];

  /// Indice della prossima gesture da confrontare con l'input del giocatore.
  /// Es: se il giocatore ha già fatto le prime 2 gesture correttamente,
  /// _playerIndex vale 2 (aspettiamo la terza).
  int _playerIndex = 0;

  /// Fase corrente del gioco. Determina cosa mostrare e se accettare input.
  GamePhase _phase = GamePhase.showing;

  /// Indice della gesture attualmente mostrata durante la fase "showing".
  /// Usato dai SequenceDots per evidenziare il puntino corretto.
  int _showingIndex = 0;

  /// Contatore che si incrementa ad ogni nuovo round.
  ///
  /// PERCHÉ ESISTE: AnimatedSwitcher decide se animare la transizione
  /// confrontando le key dei widget. Se la key non cambia, Flutter
  /// pensa che sia lo stesso widget e non lo anima. Includendo _roundId
  /// nella key, garantiamo che ad ogni nuovo round tutti i widget
  /// vengano considerati "nuovi" da AnimatedSwitcher, eliminando il bug
  /// del "flash dell'ultima gesture del round precedente".
  int _roundId = 0;

  /// La gesture attualmente mostrata nella card (fase showing).
  /// È null tra una gesture e l'altra (pausa) e durante la fase waiting.
  GestureType? _currentShow;

  /// L'ultima gesture rilevata dal giocatore durante la fase waiting.
  /// Mostrata nel riquadro centrale come feedback immediato.
  GestureType? _lastDetected;

  // ── ANIMAZIONI ────────────────────────────────────────────

  /// Controller per l'animazione di comparsa della card della gesture.
  late AnimationController _flashCtrl;

  /// L'animazione vera: fade-in della card da 0 (trasparente) a 1 (opaco).
  late Animation<double> _flashAnim;

  // ── SERVIZI ──────────────────────────────────────────────

  /// Servizio che legge l'accelerometro per rilevare le inclinazioni.
  late AccelerometerService _accelService;

  // ── RILEVAMENTO SWIPE ─────────────────────────────────────

  /// Posizione di inizio dello swipe. Salvata in onPanStart, usata in onPanEnd.
  Offset? _swipeStart;

  // ── CICLO DI VITA ─────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    // Inizializza il controller dell'animazione flash (350ms)
    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    // Anima da 0 (invisibile) a 1 (visibile) con curva easeOut
    _flashAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut),
    );

    // Crea e avvia il servizio accelerometro.
    // onGesture: quando il sensore rileva un tilt, chiama _onGestureDetected.
    // active: false inizialmente, viene attivato solo durante la fase waiting.
    _accelService = AccelerometerService(onGesture: _onGestureDetected);
    _accelService.start();

    // Avvia il primo round
    _nextRound();
  }

  @override
  void dispose() {
    // FONDAMENTALE: liberare tutte le risorse per evitare memory leak
    _accelService.stop(); // Ferma lo stream dell'accelerometro
    _flashCtrl.dispose(); // Libera l'animation controller
    super.dispose();
  }

  // ── LOGICA DI GIOCO ──────────────────────────────────────

  /// Aggiunge una nuova gesture casuale alla sequenza e avvia il round.
  void _nextRound() {
    // nextInt(n) restituisce un intero casuale da 0 a n-1.
    // GestureType.values.length è il numero totale di gesture (8).
    _sequence.add(GestureType.values[_rng.nextInt(GestureType.values.length)]);

    _playerIndex = 0; // Il giocatore ricomincia dall'inizio della sequenza
    _roundId++;       // Nuovo round = nuova key per AnimatedSwitcher
    _showSequence();  // Mostra la sequenza aggiornata
  }

  /// Mostra la sequenza di gesture una alla volta.
  ///
  /// Questo metodo è ASINCRONO (async/await): usa Future.delayed()
  /// per creare pause senza bloccare il thread dell'UI.
  ///
  /// Senza async/await, non potremmo "aspettare" tra una gesture e l'altra
  /// mantenendo l'UI reattiva. Con Thread.sleep() (Java) blocca tutto;
  /// con async/await in Dart il thread è libero durante l'attesa.
  Future<void> _showSequence() async {
    // Imposta la fase a "showing" e disabilita l'accelerometro.
    // setState() invalida il widget e chiama rebuild().
    setState(() {
      _phase = GamePhase.showing;
      _currentShow = null;    // Nessuna gesture mostrata all'inizio
      _lastDetected = null;   // Pulisce l'ultima gesture del giocatore
      _accelService.active = false; // Non accettare input durante showing
    });

    // Pausa iniziale: dà tempo al fade-out dell'ultima gesture
    // del round precedente di completarsi prima di iniziare.
    await Future.delayed(const Duration(milliseconds: 500));

    // Itera su tutta la sequenza e mostra ogni gesture
    for (int i = 0; i < _sequence.length; i++) {
      // Controllo di sicurezza: se il widget è stato distrutto
      // (es. l'utente ha premuto indietro) durante l'attesa, usciamo.
      // Chiamare setState() su un widget distrutto causa un errore.
      if (!mounted) return;

      // Mostra la gesture corrente
      setState(() {
        _showingIndex = i;
        _currentShow = _sequence[i];
      });

      // Lancia l'animazione di fade-in della card.
      // forward(from: 0) riporta l'animazione a 0 prima di farla partire,
      // così ogni gesture ha il suo fade-in fresco.
      _flashCtrl.forward(from: 0);

      // Vibrazione leggera come feedback sensoriale
      HapticFeedback.lightImpact();

      // Aspetta per la durata della visualizzazione.
      // La durata diminuisce con l'aumentare del livello: difficoltà progressiva.
      final showDuration = _sequence.length <= 3
          ? 900  // Livelli 1-3: 900ms per gesture (abbastanza lento per imparare)
          : _sequence.length <= 6
          ? 700  // Livelli 4-6: 700ms (velocità media)
          : 550; // Livelli 7+: 550ms (veloce, impegnativo)

      await Future.delayed(Duration(milliseconds: showDuration));
      if (!mounted) return; // Controllo dopo ogni await

      // Nascondi la gesture (pausa tra una gesture e l'altra)
      setState(() => _currentShow = null);
      await Future.delayed(const Duration(milliseconds: 300)); // Pausa breve
    }

    // Fine della sequenza: passa alla fase waiting
    if (!mounted) return;
    setState(() {
      _phase = GamePhase.waiting;
      _accelService.active = true; // Ora il giocatore può fare input
    });
  }

  /// Gestisce una gesture rilevata (da touch o accelerometro).
  ///
  /// Questo metodo è il punto centrale del confronto:
  /// riceve la gesture del giocatore e la confronta con quella attesa.
  void _onGestureDetected(GestureType g) {
    // Ignora le gesture se non siamo in fase waiting.
    // Questo è importante perché l'accelerometro potrebbe rilevare
    // movimenti involontari durante la fase showing.
    if (_phase != GamePhase.waiting) return;

    // Aggiorna la UI per mostrare la gesture appena rilevata
    setState(() => _lastDetected = g);

    // Vibrazione di risposta per confermare che la gesture è stata rilevata
    HapticFeedback.selectionClick();

    // Confronta con la gesture attesa nella sequenza
    if (g == _sequence[_playerIndex]) {
      // GESTURE CORRETTA
      _playerIndex++; // Avanza all'attesa della gesture successiva

      if (_playerIndex == _sequence.length) {
        // Ha fatto TUTTE le gesture della sequenza correttamente!
        _onRoundComplete();
      }
      // Se _playerIndex < _sequence.length, aspetta semplicemente
      // la prossima gesture (non fare nulla, la UI si aggiorna con setState)
    } else {
      // GESTURE SBAGLIATA
      _onWrongGesture();
    }
  }

  /// Chiamato quando il giocatore completa correttamente l'intera sequenza.
  void _onRoundComplete() {
    // Vibrazione forte come feedback positivo
    HapticFeedback.heavyImpact();

    // Mostra la schermata di feedback positivo
    setState(() => _phase = GamePhase.feedback);

    // Dopo 1400ms avvia il round successivo
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return; // Controllo di sicurezza
      _nextRound();
    });
  }

  /// Chiamato quando il giocatore fa una gesture sbagliata.
  void _onWrongGesture() {
    HapticFeedback.vibrate(); // Vibrazione di errore
    _accelService.active = false; // Disabilita subito l'accelerometro

    // Naviga alla schermata Game Over SOSTITUENDO la schermata corrente.
    // pushReplacement invece di push: così premendo "indietro" dal Game Over
    // non si torna a metà partita rotta.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameOverScreen(
          sequence: List.from(_sequence), // Copia della lista (non il riferimento)
          wrongIndex: _playerIndex,        // Quale gesture era sbagliata
          wrongGesture: _lastDetected,     // Cosa ha fatto il giocatore
        ),
      ),
    );
  }

  // ── GESTORI DI GESTURE TOUCH ─────────────────────────────

  /// Chiamato quando l'utente fa un tap singolo.
  void _onTap() => _onGestureDetected(GestureType.tapSingle);

  /// Chiamato quando l'utente fa un doppio tap.
  void _onDoubleTap() => _onGestureDetected(GestureType.tapDouble);

  /// Chiamato quando termina uno swipe (trascinamento).
  ///
  /// [DragEndDetails] contiene la velocità finale del gesto.
  /// Analizzando la direzione del vettore velocità, determiniamo
  /// se lo swipe è orizzontale o verticale e in quale verso.
  void _onPanEnd(DragEndDetails details) {
    if (_swipeStart == null) return;

    // pixelsPerSecond è il vettore velocità finale in pixel/secondo
    final vel = details.velocity.pixelsPerSecond;

    // Se la velocità è troppo bassa, non è uno swipe intenzionale
    if (vel.distance < 300) {
      _swipeStart = null;
      return;
    }

    // Confronta la componente orizzontale e verticale della velocità.
    // abs() = valore assoluto (ignora il segno per confrontare le magnitudini)
    if (vel.dx.abs() > vel.dy.abs()) {
      // Il movimento è più orizzontale che verticale
      _onGestureDetected(vel.dx > 0 ? GestureType.swipeRight : GestureType.swipeLeft);
    } else {
      // Il movimento è più verticale che orizzontale
      // NOTA: in Flutter l'asse Y va verso il basso, quindi
      // vel.dy > 0 significa movimento verso il basso (swipeDown)
      _onGestureDetected(vel.dy > 0 ? GestureType.swipeDown : GestureType.swipeUp);
    }
    _swipeStart = null;
  }

  // ── BUILD ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      // GestureDetector avvolge TUTTA la schermata per catturare
      // tap, doppio tap e swipe ovunque il giocatore tocchi.
      body: GestureDetector(
        onTap: _onTap,
        onDoubleTap: _onDoubleTap,
        onPanStart: (d) => _swipeStart = d.globalPosition,
        onPanEnd: _onPanEnd,
        // HitTestBehavior.opaque: intercetta i tocchi anche nelle aree
        // trasparenti (senza questo, i tocchi "passano attraverso" i buchi)
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildCenter()), // Expanded prende tutto lo spazio rimanente
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  /// Header con bottone indietro, indicatore livello e contatore progress.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Bottone indietro
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white70, size: 20),
            ),
          ),
          const Spacer(), // Spazio elastico: spinge il livello al centro

          // Indicatore livello al centro
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'LIVELLO ${_sequence.length}', // Il livello è uguale alla lunghezza della sequenza
              style: const TextStyle(
                fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, color: Colors.white,
              ),
            ),
          ),
          const Spacer(),

          // Contatore "gesture fatte / gesture totali"
          SizedBox(
            width: 40,
            child: Text(
              '$_playerIndex/${_sequence.length}',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Sezione centrale: etichetta fase + card principale + puntini.
  Widget _buildCenter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPhaseLabel(),
        const SizedBox(height: 48),
        _buildMainCard(),
        const SizedBox(height: 48),
        // Widget riutilizzabile per i puntini di avanzamento
        SequenceDots(
          sequence: _sequence,
          playerIndex: _playerIndex,
          showingIndex: _showingIndex,
          phase: _phase,
        ),
      ],
    );
  }

  /// Testo che indica al giocatore cosa fare ("OSSERVA", "RIPRODUCI", ecc.).
  ///
  /// AnimatedSwitcher anima la transizione quando il testo cambia.
  /// La [ValueKey] con il valore della fase garantisce che Flutter
  /// riconosca il cambio e lanci l'animazione.
  Widget _buildPhaseLabel() {
    final String text;
    final Color color;

    if (_phase == GamePhase.showing) {
      text = 'OSSERVA LA SEQUENZA';
      color = Colors.white.withOpacity(0.5);
    } else if (_phase == GamePhase.feedback) {
      text = '✓ PERFETTO!';
      color = const Color(0xFF00E676); // Verde per il successo
    } else {
      text = 'RIPRODUCI LA SEQUENZA';
      color = Colors.white.withOpacity(0.5);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        text,
        key: ValueKey(_phase), // Key necessaria per AnimatedSwitcher
        style: TextStyle(fontSize: 13, letterSpacing: 3, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  /// Card centrale che mostra la gesture corrente o il feedback al giocatore.
  ///
  /// Usa AnimatedSwitcher per animare le transizioni tra:
  ///   - GestureCard (durante showing): mostra la gesture della sequenza
  ///   - _buildSuccessCard (durante feedback): mostra 🎉
  ///   - _buildWaitingCard (durante waiting): mostra l'ultima gesture del giocatore
  Widget _buildMainCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: _currentShow != null
      // Fase showing: mostra la gesture con animazione fade
          ? GestureCard(
        // Key univoca: roundId + showingIndex garantisce che
        // AnimatedSwitcher tratti ogni gesture come widget nuovo
        key: ValueKey('card_${_roundId}_${_showingIndex}'),
        gesture: _currentShow!,
        fadeAnimation: _flashAnim, // Passa l'animazione al widget
      )
          : _phase == GamePhase.feedback
          ? _buildSuccessCard() // Fase feedback: mostra successo
          : _buildWaitingCard(), // Fase waiting: mostra input giocatore
    );
  }

  /// Card mostrata durante la fase waiting.
  ///
  /// Se il giocatore non ha ancora fatto nessuna gesture (_lastDetected == null),
  /// mostra un'icona generica invitante. Altrimenti mostra l'ultima gesture fatta.
  Widget _buildWaitingCard() {
    final g = _lastDetected;
    return Container(
      // La key include _roundId per resettare il widget ad ogni round
      key: ValueKey('waiting_$_roundId'),
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(54),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
      ),
      child: g == null
      // Nessuna gesture ancora: mostra icona invitante
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app, color: Colors.white.withOpacity(0.2), size: 48),
          const SizedBox(height: 8),
          Text(
            'Fai la gesture',
            style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12, letterSpacing: 1.5),
          ),
        ],
      )
      // Ultima gesture rilevata: mostrala con colore
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(g.emoji, style: const TextStyle(fontSize: 64)),
          Text(
            g.label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2, color: g.color),
          ),
        ],
      ),
    );
  }

  /// Card mostrata per ~1400ms quando il round è completato correttamente.
  Widget _buildSuccessCard() {
    return Container(
      key: ValueKey('success_$_roundId'),
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF00E676).withOpacity(0.1),
        borderRadius: BorderRadius.circular(54),
        border: Border.all(color: const Color(0xFF00E676), width: 2),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00E676).withOpacity(0.3), blurRadius: 40, spreadRadius: 4),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🎉', style: TextStyle(fontSize: 64)),
          SizedBox(height: 8),
          Text('ROUND VINTO!', style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2, color: Color(0xFF00E676),
          )),
        ],
      ),
    );
  }

  /// Footer con le istruzioni delle gesture disponibili.
  /// Mostrato solo durante la fase waiting.
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        // Mostra le istruzioni solo quando è il turno del giocatore
        _phase == GamePhase.waiting
            ? '👆 Tap  ✌️ Doppio tap  👈👉 Swipe  📱 Inclina'
            : '', // Stringa vuota nelle altre fasi (nasconde il testo)
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 11, letterSpacing: 0.5),
      ),
    );
  }
}