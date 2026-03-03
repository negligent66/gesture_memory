import 'package:flutter/material.dart';
import '../models/gesture_type.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                _buildTitle(),
                const Spacer(flex: 2),
                _buildGestureGrid(),
                const Spacer(flex: 2),
                _buildPlayButton(),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
          ).createShader(bounds),
          child: const Text(
            'GESTURE\nMEMORY',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              letterSpacing: 8,
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Ricorda la sequenza. Riproducila.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0x66FFFFFF),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildGestureGrid() {
    return Center(
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        alignment: WrapAlignment.center,
        children: GestureType.values.map((g) {
          return Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: g.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: g.color.withOpacity(0.35), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(g.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 2),
                Text(
                  g.label.split(' ').first, // solo la prima parola es. "TAP", "SWIPE", "SHAKE"
                  style: TextStyle(
                    fontSize: 7,
                    color: g.color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Center(
      child: ScaleTransition(
        scale: _pulse,
        child: GestureDetector(
          onTap: _startGame,
          child: Container(
            width: 200,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.4),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'INIZIA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}