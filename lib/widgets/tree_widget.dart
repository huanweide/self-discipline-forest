/// 种树动画组件
/// 参考：Forest App的树生长机制 + 专注森林Flutter版的CustomPainter实现
/// 5个生长阶段：种子→发芽→生长→开花→成熟
/// 枯萎和受伤状态

import 'dart:math';
import 'package:flutter/material.dart';
import '../models/tree.dart';

class TreeWidget extends StatelessWidget {
  final double progress;   // 0.0~1.0
  final bool isRunning;
  final bool isBreak;
  final TreeStage? forcedStage; // 强制显示某个阶段（用于森林展示）

  const TreeWidget({
    super.key,
    required this.progress,
    this.isRunning = false,
    this.isBreak = false,
    this.forcedStage,
  });

  TreeStage get stage {
    if (forcedStage != null) return forcedStage!;
    if (!isRunning && progress == 0) return TreeStage.seed;
    if (progress < 0.2) return TreeStage.seed;
    if (progress < 0.4) return TreeStage.sprout;
    if (progress < 0.7) return TreeStage.growing;
    if (progress < 0.95) return TreeStage.blooming;
    return TreeStage.mature;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: CustomPaint(
        key: ValueKey(stage),
        size: const Size(200, 220),
        painter: _TreePainter(
          progress: progress,
          stage: stage,
          isRunning: isRunning,
        ),
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  final double progress;
  final TreeStage stage;
  final bool isRunning;

  _TreePainter({
    required this.progress,
    required this.stage,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.75);
    final rng = Random(42); // 固定种子→每次画出来一样

    switch (stage) {
      case TreeStage.seed:
        _drawSeed(canvas, center, progress);
        break;
      case TreeStage.sprout:
        _drawSprout(canvas, center, progress, rng);
        break;
      case TreeStage.growing:
        _drawGrowing(canvas, center, progress, rng);
        break;
      case TreeStage.blooming:
        _drawGrowing(canvas, center, progress, rng);
        _drawFlowers(canvas, center, rng);
        break;
      case TreeStage.mature:
        _drawGrowing(canvas, center, 1.0, rng);
        _drawFlowers(canvas, center, rng);
        _drawFruits(canvas, center, rng);
        break;
      case TreeStage.withered:
        _drawWithered(canvas, center, rng);
        break;
      case TreeStage.damaged:
        _drawGrowing(canvas, center, progress, rng);
        _drawDamageMark(canvas, center);
        break;
    }

    // 泥土底盘
    _drawSoil(canvas, center);
  }

  void _drawSeed(Canvas canvas, Offset center, double progress) {
    final soilPaint = Paint()..color = const Color(0xFF8B4513);
    final seedSize = 4.0 + progress * 2; // 种子慢慢变大
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy - 2), width: seedSize * 2, height: seedSize),
      soilPaint,
    );
    // 小芽尖
    if (progress > 0.1) {
      final sproutPaint = Paint()
        ..color = const Color(0xFF4CAF50)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      final path = Path();
      path.moveTo(center.dx, center.dy - seedSize);
      path.quadraticBezierTo(center.dx + 3, center.dy - seedSize - 6, center.dx + 1, center.dy - seedSize - 10);
      canvas.drawPath(path, sproutPaint);
    }
  }

  void _drawSprout(Canvas canvas, Offset center, double progress, Random rng) {
    _drawTrunk(canvas, center, progress, rng, trunkHeight: 30 * progress, trunkWidth: 3.0);
    // 几片小叶子
    final leafPaint = Paint()..color = const Color(0xFF66BB6A);
    for (int i = 0; i < 3; i++) {
      final angle = -pi / 2 + (i - 1) * 0.8;
      final leafX = center.dx + cos(angle) * 15 * progress;
      final leafY = center.dy - 25 * progress + sin(angle) * 15 * progress;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(leafX, leafY), width: 10 * progress, height: 6 * progress),
        leafPaint,
      );
    }
  }

  void _drawGrowing(Canvas canvas, Offset center, double progress, Random rng) {
    final trunkHeight = 50 + 40 * progress;
    _drawTrunk(canvas, center, progress, rng, trunkHeight: trunkHeight, trunkWidth: 5.0);
    // 树冠（圆形的叶子簇）
    final crownCenter = Offset(center.dx, center.dy - trunkHeight);
    final crownRadius = 20 + 25 * progress;
    final crownPaint = Paint()..color = const Color(0xFF4CAF50).withOpacity(0.85);
    canvas.drawCircle(crownCenter, crownRadius, crownPaint);
    // 树冠层次感
    final crownPaint2 = Paint()..color = const Color(0xFF66BB6A).withOpacity(0.6);
    canvas.drawCircle(Offset(crownCenter.dx - 8, crownCenter.dy + 5), crownRadius * 0.7, crownPaint2);
    canvas.drawCircle(Offset(crownCenter.dx + 8, crownCenter.dy + 3), crownRadius * 0.65, crownPaint2);

    // 树枝
    final branchPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 3; i++) {
      final angle = -pi / 2 + (i - 1) * 0.6;
      final path = Path();
      path.moveTo(center.dx, center.dy - trunkHeight * 0.7);
      path.lineTo(center.dx + cos(angle) * crownRadius * 0.8, center.dy - trunkHeight * 0.7 + sin(angle) * crownRadius * 0.4);
      canvas.drawPath(path, branchPaint);
    }
  }

  void _drawTrunk(Canvas canvas, Offset center, double progress, Random rng, {required double trunkHeight, required double trunkWidth}) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF795548)
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(center.dx - trunkWidth / 2, center.dy);
    path.lineTo(center.dx - trunkWidth * 0.4, center.dy - trunkHeight);
    path.quadraticBezierTo(center.dx, center.dy - trunkHeight - 3, center.dx + trunkWidth * 0.4, center.dy - trunkHeight);
    path.lineTo(center.dx + trunkWidth / 2, center.dy);
    path.close();
    canvas.drawPath(path, trunkPaint);
  }

  void _drawFlowers(Canvas canvas, Offset center, Random rng) {
    final flowerPaint = Paint()..color = const Color(0xFFFF80AB); // 粉色花
    final crownCenter = Offset(center.dx, center.dy - 80);
    for (int i = 0; i < 5; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final dist = 15 + rng.nextDouble() * 20;
      final fx = crownCenter.dx + cos(angle) * dist;
      final fy = crownCenter.dy + sin(angle) * dist;
      canvas.drawCircle(Offset(fx, fy), 4, flowerPaint);
      canvas.drawCircle(Offset(fx, fy), 2, Paint()..color = Colors.yellow); // 花蕊
    }
  }

  void _drawFruits(Canvas canvas, Offset center, Random rng) {
    final fruitPaint = Paint()..color = const Color(0xFFFF6F00); // 橙色果实
    final crownCenter = Offset(center.dx, center.dy - 80);
    for (int i = 0; i < 3; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final dist = 10 + rng.nextDouble() * 15;
      canvas.drawCircle(
        Offset(crownCenter.dx + cos(angle) * dist, crownCenter.dy + sin(angle) * dist),
        3,
        fruitPaint,
      );
    }
  }

  void _drawWithered(Canvas canvas, Offset center, Random rng) {
    _drawTrunk(canvas, center, 1.0, rng, trunkHeight: 50, trunkWidth: 3.0);
    // 枯萎的棕色树冠
    final deadCrown = Paint()..color = const Color(0xFF8D6E63).withOpacity(0.5);
    canvas.drawCircle(Offset(center.dx, center.dy - 50), 18, deadCrown);
    // 落叶
    final leafPaint = Paint()..color = const Color(0xFFA1887F);
    for (int i = 0; i < 4; i++) {
      final lx = center.dx + (i - 1.5) * 15;
      final ly = center.dy + 10 + (i % 2) * 8;
      canvas.drawOval(Rect.fromCenter(center: Offset(lx, ly), width: 6, height: 3), leafPaint);
    }
  }

  void _drawDamageMark(Canvas canvas, Offset center) {
    final markPaint = Paint()
      ..color = Colors.red.shade400
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    // 树干上的裂痕
    canvas.drawLine(
      Offset(center.dx - 3, center.dy - 20),
      Offset(center.dx + 3, center.dy - 10),
      markPaint,
    );
    canvas.drawLine(
      Offset(center.dx + 3, center.dy - 20),
      Offset(center.dx - 3, center.dy - 10),
      markPaint,
    );
  }

  void _drawSoil(Canvas canvas, Offset center) {
    final soilPaint = Paint()..color = const Color(0xFF5D4037);
    final path = Path();
    path.moveTo(center.dx - 25, center.dy);
    path.quadraticBezierTo(center.dx, center.dy + 6, center.dx + 25, center.dy);
    path.quadraticBezierTo(center.dx + 30, center.dy + 2, center.dx + 20, center.dy + 4);
    path.lineTo(center.dx - 20, center.dy + 4);
    path.quadraticBezierTo(center.dx - 30, center.dy + 2, center.dx - 25, center.dy);
    canvas.drawPath(path, soilPaint);
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.stage != stage ||
        oldDelegate.isRunning != isRunning;
  }
}
