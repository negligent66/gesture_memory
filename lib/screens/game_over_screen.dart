import 'package:flutter/material.dart';
import '../models/gesture_type.dart';
import '../widgets/gradient_button.dart';
import 'game_screen.dart';

class GameOverScreen extends StatelessWidget {
  final List<GestureType> sequence;
  final int wrongIndex;
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildDeathIcon(),
              const SizedBox(height: 16),
              _buildScore(),
              const SizedBox(height: 32),
              _buildMistakeBox(),
              const SizedBox(height: 28),
              _buildSequenceReview(),
              const SizedBox(height: 40),
              _buildActions(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeathIcon() {
    return const Text('💀', style: TextStyle(fontSize: 72));
  }

  Widget _buildScore() {
    return Column(
      children: [
        const Text(
          'GAME OVER',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
            color: Color(0xFFFF1744),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Hai raggiunto il livello',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, letterSpacing: 1.5),
        ),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
          ).createShader(b),
          child: Text(
            '${sequence.length}',
            style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// Box che mostra esattamente cosa era richiesto e cosa hai fatto
  Widget _buildMistakeBox() {
    final expected = sequence[wrongIndex];
    final actual = wrongGesture;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF1744).withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF1744).withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            'ERRORE AL PASSO ${wrongIndex + 1}',
            style: const TextStyle(
              color: Color(0xFFFF1744),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cosa era richiesto
              _buildCompareCard(
                label: 'RICHIESTO',
                gesture: expected,
                borderColor: expected.color,
              ),
              // Freccia
              Column(
                children: [
                  const SizedBox(height: 16),
                  Icon(Icons.arrow_forward, color: Colors.white.withOpacity(0.2), size: 28),
                ],
              ),
              // Cosa hai fatto
              actual != null
                  ? _buildCompareCard(
                label: 'HAI FATTO',
                gesture: actual,
                borderColor: const Color(0xFFFF1744),
                isWrong: true,
              )
                  : _buildEmptyCard(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompareCard({
    required String label,
    required GestureType gesture,
    required Color borderColor,
    bool isWrong = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isWrong ? const Color(0xFFFF1744) : Colors.white.withOpacity(0.4),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: borderColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(color: borderColor.withOpacity(0.25), blurRadius: 16, spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(gesture.emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 4),
              Text(
                gesture.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: borderColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard() {
    return Column(
      children: [
        Text(
          'HAI FATTO',
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
          ),
          child: Center(
            child: Text('?', style: TextStyle(fontSize: 36, color: Colors.white.withOpacity(0.2))),
          ),
        ),
      ],
    );
  }

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
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: sequence.asMap().entries.map((entry) {
            final i = entry.key;
            final g = entry.value;
            final isError = i == wrongIndex;
            final isDone = i < wrongIndex;

            return _SequenceChip(gesture: g, isError: isError, isDone: isDone, index: i);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GradientButton(
          label: 'RIPROVA',
          colors: const [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const GameScreen()),
          ),
        ),
        const SizedBox(width: 16),
        GradientButton(
          label: 'MENU',
          colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _SequenceChip extends StatelessWidget {
  final GestureType gesture;
  final bool isError;
  final bool isDone;
  final int index;

  const _SequenceChip({
    required this.gesture,
    required this.isError,
    required this.isDone,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color bgColor;

    if (isError) {
      borderColor = const Color(0xFFFF1744);
      bgColor = const Color(0xFFFF1744).withOpacity(0.15);
    } else if (isDone) {
      borderColor = const Color(0xFF00E676).withOpacity(0.6);
      bgColor = const Color(0xFF00E676).withOpacity(0.08);
    } else {
      borderColor = gesture.color.withOpacity(0.35);
      bgColor = gesture.color.withOpacity(0.08);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: isError ? 2 : 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Numero del passo
          Text(
            '${index + 1}',
            style: TextStyle(
              color: isError
                  ? const Color(0xFFFF1744)
                  : isDone
                  ? const Color(0xFF00E676)
                  : Colors.white.withOpacity(0.25),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 5),
          Text(gesture.emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 5),
          Text(
            gesture.label,
            style: TextStyle(
              color: isError
                  ? const Color(0xFFFF1744)
                  : isDone
                  ? const Color(0xFF00E676).withOpacity(0.8)
                  : gesture.color.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          if (isError) ...[
            const SizedBox(width: 5),
            const Icon(Icons.close, color: Color(0xFFFF1744), size: 12),
          ] else if (isDone) ...[
            const SizedBox(width: 5),
            const Icon(Icons.check, color: Color(0xFF00E676), size: 12),
          ],
        ],
      ),
    );
  }
}