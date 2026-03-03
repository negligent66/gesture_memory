import 'package:flutter/material.dart';

/// A pill-shaped button with a gradient background and glow shadow.
class GradientButton extends StatelessWidget {
  final String label;
  final List<Color> colors;
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
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            letterSpacing: 3,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}