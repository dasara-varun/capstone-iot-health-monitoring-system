import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Constrained reading column with paper grain and a quiet gold ambient glow.
class PageFrame extends StatelessWidget {
  final Widget child;
  final Future<void> Function()? onRefresh;

  const PageFrame({super.key, required this.child, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final content = CustomPaint(
      foregroundPainter: _PaperGrainPainter(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            top: -90,
            right: -30,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x05B8860B),
                      blurRadius: 180,
                      spreadRadius: 90,
                    ),
                  ],
                ),
                child: SizedBox(width: 200, height: 200),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1024),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 56),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        color: AppTheme.accent,
        onRefresh: onRefresh!,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: content,
        ),
      );
    }

    return SingleChildScrollView(child: content);
  }
}

class _PaperGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final random = Random(7);
    final paint = Paint()..style = PaintingStyle.fill;
    final count = (size.width * size.height / 2800).clamp(80, 500).toInt();
    for (var i = 0; i < count; i++) {
      final opacity = 0.02 + random.nextDouble() * 0.035;
      paint.color = Color.fromRGBO(26, 26, 26, opacity);
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        random.nextDouble() * 1.1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
