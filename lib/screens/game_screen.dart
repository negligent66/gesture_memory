import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // ── State ──────────────────────────────────
  final Random _rng = Random();
  final List<GestureType> _sequence = [];
  int _playerIndex = 0;
  GamePhase _phase = GamePhase.showing;
  int _showingIndex = 0;

  // _roundId cambia ad ogni nuovo round: forza AnimatedSwitcher a
  // distruggere il vecchio widget invece di fare fade-out dell'ultima gesture.
  int _roundId = 0;

  GestureType? _currentShow;
  GestureType? _lastDetected;

  // ── Animations ────────────────────────────
  late AnimationController _flashCtrl;
  late Animation<double> _flashAnim;

  // ── Services ──────────────────────────────
  late AccelerometerService _accelService;

  // ── Swipe tracking ────────────────────────
  Offset? _swipeStart;

  @override
  void initState() {
    super.initState();

    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _flashAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut),
    );

    _accelService = AccelerometerService(onGesture: _onGestureDetected);
    _accelService.start();

    _nextRound();
  }

  @override
  void dispose() {
    _accelService.stop();
    _flashCtrl.dispose();
    super.dispose();
  }

  // ── Game Logic ────────────────────────────

  void _nextRound() {
    _sequence.add(GestureType.values[_rng.nextInt(GestureType.values.length)]);
    _playerIndex = 0;
    _roundId++;          // nuovo round → nuovo key per AnimatedSwitcher
    _showSequence();
  }

  Future<void> _showSequence() async {
    // Reset completo prima di iniziare: _currentShow = null PRIMA del delay,
    // così AnimatedSwitcher ha tempo di pulire il vecchio widget.
    setState(() {
      _phase = GamePhase.showing;
      _currentShow = null;
      _lastDetected = null;
      _accelService.active = false;
    });

    // Pausa più lunga: dà tempo al fade-out dell'ultimo widget di finire
    await Future.delayed(const Duration(milliseconds: 500));

    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;

      setState(() {
        _showingIndex = i;
        _currentShow = _sequence[i];
      });
      _flashCtrl.forward(from: 0);
      HapticFeedback.lightImpact();

      final showDuration = _sequence.length <= 3
          ? 900
          : _sequence.length <= 6
          ? 700
          : 550;

      await Future.delayed(Duration(milliseconds: showDuration));
      if (!mounted) return;

      setState(() => _currentShow = null);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (!mounted) return;
    setState(() {
      _phase = GamePhase.waiting;
      _accelService.active = true;
    });
  }

  void _onGestureDetected(GestureType g) {
    if (_phase != GamePhase.waiting) return;

    setState(() => _lastDetected = g);
    HapticFeedback.selectionClick();

    if (g == _sequence[_playerIndex]) {
      _playerIndex++;
      if (_playerIndex == _sequence.length) {
        _onRoundComplete();
      }
    } else {
      _onWrongGesture();
    }
  }

  void _onRoundComplete() {
    HapticFeedback.heavyImpact();
    setState(() => _phase = GamePhase.feedback);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      _nextRound();
    });
  }

  void _onWrongGesture() {
    HapticFeedback.vibrate();
    _accelService.active = false;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameOverScreen(
          sequence: List.from(_sequence),
          wrongIndex: _playerIndex,
          wrongGesture: _lastDetected,
        ),
      ),
    );
  }

  // ── Gesture handlers ─────────────────────

  void _onTap() => _onGestureDetected(GestureType.tapSingle);
  void _onDoubleTap() => _onGestureDetected(GestureType.tapDouble);

  void _onPanEnd(DragEndDetails details) {
    if (_swipeStart == null) return;
    final vel = details.velocity.pixelsPerSecond;
    if (vel.distance < 300) {
      _swipeStart = null;
      return;
    }
    if (vel.dx.abs() > vel.dy.abs()) {
      _onGestureDetected(vel.dx > 0 ? GestureType.swipeRight : GestureType.swipeLeft);
    } else {
      _onGestureDetected(vel.dy > 0 ? GestureType.swipeDown : GestureType.swipeUp);
    }
    _swipeStart = null;
  }

  // ── Build ─────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: GestureDetector(
        onTap: _onTap,
        onDoubleTap: _onDoubleTap,
        onPanStart: (d) => _swipeStart = d.globalPosition,
        onPanEnd: _onPanEnd,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildCenter()),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
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
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'LIVELLO ${_sequence.length}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
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

  Widget _buildCenter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPhaseLabel(),
        const SizedBox(height: 48),
        _buildMainCard(),
        const SizedBox(height: 48),
        SequenceDots(
          sequence: _sequence,
          playerIndex: _playerIndex,
          showingIndex: _showingIndex,
          phase: _phase,
        ),
      ],
    );
  }

  Widget _buildPhaseLabel() {
    final String text;
    final Color color;

    if (_phase == GamePhase.showing) {
      text = 'OSSERVA LA SEQUENZA';
      color = Colors.white.withOpacity(0.5);
    } else if (_phase == GamePhase.feedback) {
      text = '✓ PERFETTO!';
      color = const Color(0xFF00E676);
    } else {
      text = 'RIPRODUCI LA SEQUENZA';
      color = Colors.white.withOpacity(0.5);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        text,
        key: ValueKey(_phase),
        style: TextStyle(fontSize: 13, letterSpacing: 3, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildMainCard() {
    // La key include _roundId: quando cambia round, AnimatedSwitcher
    // tratta sempre il widget come nuovo e non mostra residui del round precedente.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: _currentShow != null
          ? GestureCard(
        key: ValueKey('card_${_roundId}_${_showingIndex}'),
        gesture: _currentShow!,
        fadeAnimation: _flashAnim,
      )
          : _phase == GamePhase.feedback
          ? _buildSuccessCard()
          : _buildWaitingCard(),
    );
  }

  Widget _buildWaitingCard() {
    final g = _lastDetected;
    return Container(
      key: ValueKey('waiting_$_roundId'),
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(54),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
      ),
      child: g == null
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
          Text('ROUND VINTO!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2, color: Color(0xFF00E676))),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        _phase == GamePhase.waiting
            ? '👆 Tap  ✌️ Doppio tap  👈👉 Swipe  📳 Shake  📱 Inclina'
            : '',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 11, letterSpacing: 0.5),
      ),
    );
  }
}