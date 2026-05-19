import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _AppLogoPainter(),
      ),
    );
  }
}

class _AppLogoPainter extends CustomPainter {
  // App color palette
  static const Color primary = Color(0xFFC47F52);
  static const Color accent = Color(0xFFD4956A);
  static const Color partnerGreen = Color(0xFF7B9E6B);
  static const Color textBrown = Color(0xFF5A3E2B);

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final double cx = s / 2;
    final double cy = s / 2;

    // We draw two overlapping tomato circles that together form a heart shape.
    // The heart is composed of two round "tomato" lobes offset left and right,
    // meeting at a point at the bottom.

    final double lobeRadius = s * 0.27;
    final double lobeOffsetX = s * 0.16;
    final double lobeY = cy - s * 0.04;
    final double bottomTipY = cy + s * 0.32;

    // --- Shadow ---
    final Paint shadowPaint = Paint()
      ..color = textBrown.withValues(alpha:0.13)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.03);

    final Path heartShadow = _buildHeartPath(
      cx, lobeY + s * 0.02, lobeOffsetX, lobeRadius, bottomTipY + s * 0.02, s,
    );
    canvas.drawPath(heartShadow, shadowPaint);

    // --- Left tomato (primary color) ---
    final Paint leftTomatoPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 1.0,
        colors: [accent, primary],
      ).createShader(Rect.fromCircle(
        center: Offset(cx - lobeOffsetX, lobeY),
        radius: lobeRadius,
      ));

    final Path leftLobe = _buildLobePath(
      cx - lobeOffsetX, lobeY, lobeRadius, cx, bottomTipY, isLeft: true, s: s,
    );
    canvas.drawPath(leftLobe, leftTomatoPaint);

    // --- Right tomato (accent/lighter) ---
    final Paint rightTomatoPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.3, -0.4),
        radius: 1.0,
        colors: [
          Color.lerp(accent, const Color(0xFFE2A97C), 0.5)!,
          primary,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(cx + lobeOffsetX, lobeY),
        radius: lobeRadius,
      ));

    final Path rightLobe = _buildLobePath(
      cx + lobeOffsetX, lobeY, lobeRadius, cx, bottomTipY, isLeft: false, s: s,
    );
    canvas.drawPath(rightLobe, rightTomatoPaint);

    // --- Highlight sheen on each lobe ---
    final Paint sheenPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.5),
        radius: 0.6,
        colors: [
          Colors.white.withValues(alpha:0.35),
          Colors.white.withValues(alpha:0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(cx - lobeOffsetX - lobeRadius * 0.2, lobeY - lobeRadius * 0.2),
        radius: lobeRadius * 0.7,
      ));
    canvas.drawCircle(
      Offset(cx - lobeOffsetX - lobeRadius * 0.1, lobeY - lobeRadius * 0.15),
      lobeRadius * 0.35,
      sheenPaint,
    );

    final Paint sheenPaint2 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.5),
        radius: 0.6,
        colors: [
          Colors.white.withValues(alpha:0.25),
          Colors.white.withValues(alpha:0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(cx + lobeOffsetX - lobeRadius * 0.1, lobeY - lobeRadius * 0.2),
        radius: lobeRadius * 0.5,
      ));
    canvas.drawCircle(
      Offset(cx + lobeOffsetX - lobeRadius * 0.05, lobeY - lobeRadius * 0.15),
      lobeRadius * 0.25,
      sheenPaint2,
    );

    // --- Tomato segment lines (subtle) ---
    _drawTomatoSegments(canvas, cx - lobeOffsetX, lobeY, lobeRadius, s, isLeft: true);
    _drawTomatoSegments(canvas, cx + lobeOffsetX, lobeY, lobeRadius, s, isLeft: false);

    // --- Stems and leaves ---
    _drawStemsAndLeaves(canvas, cx, lobeY, lobeRadius, lobeOffsetX, s);

    // --- Clock/timer arc detail on the right tomato ---
    _drawTimerDetail(canvas, cx + lobeOffsetX, lobeY, lobeRadius, s);
  }

  /// Builds the full heart silhouette path (used for shadow).
  Path _buildHeartPath(
    double cx, double lobeY, double lobeOffsetX, double lobeRadius,
    double bottomTipY, double s,
  ) {
    final Path path = Path();
    final double leftCx = cx - lobeOffsetX;
    final double rightCx = cx + lobeOffsetX;

    // Start at the dip between the two lobes (top center)
    path.moveTo(cx, lobeY - lobeRadius * 0.55);

    // Left lobe arc
    path.cubicTo(
      leftCx - lobeRadius * 0.6, lobeY - lobeRadius * 1.3,
      leftCx - lobeRadius * 1.15, lobeY - lobeRadius * 0.3,
      leftCx - lobeRadius * 0.9, lobeY + lobeRadius * 0.3,
    );

    // Down to bottom tip (left side)
    path.cubicTo(
      leftCx - lobeRadius * 0.5, lobeY + lobeRadius * 1.0,
      cx - s * 0.05, bottomTipY - s * 0.06,
      cx, bottomTipY,
    );

    // Bottom tip to right side
    path.cubicTo(
      cx + s * 0.05, bottomTipY - s * 0.06,
      rightCx + lobeRadius * 0.5, lobeY + lobeRadius * 1.0,
      rightCx + lobeRadius * 0.9, lobeY + lobeRadius * 0.3,
    );

    // Right lobe arc back to top center
    path.cubicTo(
      rightCx + lobeRadius * 1.15, lobeY - lobeRadius * 0.3,
      rightCx + lobeRadius * 0.6, lobeY - lobeRadius * 1.3,
      cx, lobeY - lobeRadius * 0.55,
    );

    path.close();
    return path;
  }

  /// Builds one lobe (left or right half of the heart-tomato).
  Path _buildLobePath(
    double lobeCx, double lobeCy, double r, double tipX, double tipY,
    {required bool isLeft, required double s}
  ) {
    final Path path = Path();
    final double midX = tipX;

    if (isLeft) {
      path.moveTo(midX, lobeCy - r * 0.55);
      // Top of left lobe, curving left and around
      path.cubicTo(
        lobeCx - r * 0.6, lobeCy - r * 1.3,
        lobeCx - r * 1.15, lobeCy - r * 0.3,
        lobeCx - r * 0.9, lobeCy + r * 0.3,
      );
      // Down to the bottom tip
      path.cubicTo(
        lobeCx - r * 0.5, lobeCy + r * 1.0,
        midX - s * 0.05, tipY - s * 0.06,
        tipX, tipY,
      );
      // Back up through center
      path.cubicTo(
        midX + s * 0.01, tipY - s * 0.15,
        midX + r * 0.1, lobeCy + r * 0.4,
        midX, lobeCy - r * 0.55,
      );
    } else {
      path.moveTo(midX, lobeCy - r * 0.55);
      // Top of right lobe, curving right and around
      path.cubicTo(
        lobeCx + r * 0.6, lobeCy - r * 1.3,
        lobeCx + r * 1.15, lobeCy - r * 0.3,
        lobeCx + r * 0.9, lobeCy + r * 0.3,
      );
      // Down to the bottom tip
      path.cubicTo(
        lobeCx + r * 0.5, lobeCy + r * 1.0,
        midX + s * 0.05, tipY - s * 0.06,
        tipX, tipY,
      );
      // Back up through center
      path.cubicTo(
        midX - s * 0.01, tipY - s * 0.15,
        midX - r * 0.1, lobeCy + r * 0.4,
        midX, lobeCy - r * 0.55,
      );
    }

    path.close();
    return path;
  }

  /// Draws subtle tomato segment lines on a lobe.
  void _drawTomatoSegments(
    Canvas canvas, double cx, double cy, double r, double s,
    {required bool isLeft}
  ) {
    final Paint segPaint = Paint()
      ..color = textBrown.withValues(alpha:0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.006
      ..strokeCap = StrokeCap.round;

    // Draw 2 subtle curved segment lines
    for (int i = 0; i < 2; i++) {
      final double offsetX = (i == 0 ? -0.15 : 0.2) * r;
      final Path seg = Path();
      seg.moveTo(cx + offsetX, cy - r * 0.6);
      seg.cubicTo(
        cx + offsetX + r * 0.05, cy - r * 0.15,
        cx + offsetX - r * 0.05, cy + r * 0.3,
        cx + offsetX + r * 0.02, cy + r * 0.65,
      );
      canvas.drawPath(seg, segPaint);
    }
  }

  /// Draws cute stems and leaves at the top of the heart.
  void _drawStemsAndLeaves(
    Canvas canvas, double cx, double lobeY, double r,
    double lobeOffsetX, double s,
  ) {
    final double stemBaseY = lobeY - r * 0.55;

    // --- Main stems (two little curved stems meeting at center) ---
    final Paint stemPaint = Paint()
      ..color = partnerGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.025
      ..strokeCap = StrokeCap.round;

    // Left stem
    final Path leftStem = Path();
    leftStem.moveTo(cx - s * 0.02, stemBaseY);
    leftStem.cubicTo(
      cx - s * 0.04, stemBaseY - s * 0.06,
      cx - s * 0.06, stemBaseY - s * 0.10,
      cx - s * 0.03, stemBaseY - s * 0.14,
    );
    canvas.drawPath(leftStem, stemPaint);

    // Right stem
    final Path rightStem = Path();
    rightStem.moveTo(cx + s * 0.02, stemBaseY);
    rightStem.cubicTo(
      cx + s * 0.04, stemBaseY - s * 0.06,
      cx + s * 0.06, stemBaseY - s * 0.10,
      cx + s * 0.03, stemBaseY - s * 0.14,
    );
    canvas.drawPath(rightStem, stemPaint);

    // --- Leaves ---
    final Paint leafPaint = Paint()
      ..color = partnerGreen
      ..style = PaintingStyle.fill;

    final Paint leafDarkPaint = Paint()
      ..color = const Color(0xFF6A8A5C)
      ..style = PaintingStyle.fill;

    // Left leaf — a cute rounded teardrop shape curving to the left
    final double leafStartY = stemBaseY - s * 0.08;
    final Path leftLeaf = Path();
    leftLeaf.moveTo(cx - s * 0.04, leafStartY);
    leftLeaf.cubicTo(
      cx - s * 0.12, leafStartY - s * 0.06,
      cx - s * 0.16, leafStartY + s * 0.01,
      cx - s * 0.10, leafStartY + s * 0.04,
    );
    leftLeaf.cubicTo(
      cx - s * 0.07, leafStartY + s * 0.05,
      cx - s * 0.04, leafStartY + s * 0.03,
      cx - s * 0.04, leafStartY,
    );
    leftLeaf.close();
    canvas.drawPath(leftLeaf, leafPaint);

    // Left leaf vein
    final Paint veinPaint = Paint()
      ..color = const Color(0xFF6A8A5C).withValues(alpha:0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.006
      ..strokeCap = StrokeCap.round;
    final Path leftVein = Path();
    leftVein.moveTo(cx - s * 0.045, leafStartY + s * 0.005);
    leftVein.cubicTo(
      cx - s * 0.08, leafStartY - s * 0.01,
      cx - s * 0.10, leafStartY + s * 0.01,
      cx - s * 0.10, leafStartY + s * 0.03,
    );
    canvas.drawPath(leftVein, veinPaint);

    // Right leaf — mirrored
    final Path rightLeaf = Path();
    rightLeaf.moveTo(cx + s * 0.04, leafStartY);
    rightLeaf.cubicTo(
      cx + s * 0.12, leafStartY - s * 0.06,
      cx + s * 0.16, leafStartY + s * 0.01,
      cx + s * 0.10, leafStartY + s * 0.04,
    );
    rightLeaf.cubicTo(
      cx + s * 0.07, leafStartY + s * 0.05,
      cx + s * 0.04, leafStartY + s * 0.03,
      cx + s * 0.04, leafStartY,
    );
    rightLeaf.close();
    canvas.drawPath(rightLeaf, leafDarkPaint);

    // Right leaf vein
    final Path rightVein = Path();
    rightVein.moveTo(cx + s * 0.045, leafStartY + s * 0.005);
    rightVein.cubicTo(
      cx + s * 0.08, leafStartY - s * 0.01,
      cx + s * 0.10, leafStartY + s * 0.01,
      cx + s * 0.10, leafStartY + s * 0.03,
    );
    canvas.drawPath(rightVein, veinPaint);

    // Small highlight on left leaf
    final Paint leafHighlight = Paint()
      ..color = Colors.white.withValues(alpha:0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(cx - s * 0.09, leafStartY - s * 0.01),
      s * 0.012,
      leafHighlight,
    );
  }

  /// Draws a subtle clock/timer arc and hands on the right tomato.
  void _drawTimerDetail(
    Canvas canvas, double cx, double cy, double r, double s,
  ) {
    final double clockR = r * 0.32;

    // Timer arc (partial circle outline)
    final Paint arcPaint = Paint()
      ..color = Colors.white.withValues(alpha:0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.012
      ..strokeCap = StrokeCap.round;

    // Draw a ~270 degree arc (like a timer that's 3/4 done)
    final Rect arcRect = Rect.fromCircle(center: Offset(cx, cy), radius: clockR);
    canvas.drawArc(arcRect, -1.57, 4.71, false, arcPaint); // full subtle ring

    // Thicker progress arc — shows ~75% progress
    final Paint progressPaint = Paint()
      ..color = Colors.white.withValues(alpha:0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.018
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, -1.57, 3.93, false, progressPaint);

    // Clock center dot
    final Paint dotPaint = Paint()
      ..color = Colors.white.withValues(alpha:0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), s * 0.012, dotPaint);

    // Minute hand (pointing to ~12 o'clock direction, slightly tilted)
    final Paint handPaint = Paint()
      ..color = Colors.white.withValues(alpha:0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.014
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + clockR * 0.15, cy - clockR * 0.7),
      handPaint,
    );

    // Hour hand (pointing to ~3 o'clock-ish)
    final Paint hourHandPaint = Paint()
      ..color = Colors.white.withValues(alpha:0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.018
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + clockR * 0.5, cy + clockR * 0.15),
      hourHandPaint,
    );

    // Small tick marks at 12, 3, 6, 9 positions
    final Paint tickPaint = Paint()
      ..color = Colors.white.withValues(alpha:0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.008
      ..strokeCap = StrokeCap.round;

    final List<Offset> tickDirections = [
      const Offset(0, -1),   // 12
      const Offset(1, 0),    // 3
      const Offset(0, 1),    // 6
      const Offset(-1, 0),   // 9
    ];

    for (final dir in tickDirections) {
      final Offset outer = Offset(cx + dir.dx * clockR, cy + dir.dy * clockR);
      final Offset inner = Offset(
        cx + dir.dx * clockR * 0.8,
        cy + dir.dy * clockR * 0.8,
      );
      canvas.drawLine(inner, outer, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
