/// SVG风格倒计时环
/// 参考：focus-timer的requestAnimationFrame SVG countdown ring
/// 用CustomPainter实现，流畅60fps

import 'dart:math';
import 'package:flutter/material.dart';

class CountdownRing extends StatelessWidget {
  final double progress;   // 0.0~1.0
  final String timeText;   // "25:00"
  final bool isRunning;
  final bool isBreak;
  final double size;

  const CountdownRing({
    super.key,
    required this.progress,
    required this.timeText,
    this.isRunning = false,
    this.isBreak = false,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ringColor = isBreak
        ? Colors.orange
        : isRunning
            ? theme.colorScheme.primary
            : Colors.grey.shade300;
    final bgColor = Colors.grey.shade200;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景圆环
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: 1.0,
              color: bgColor,
              strokeWidth: 10,
            ),
          ),
          // 进度圆环
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              color: ringColor,
              strokeWidth: 10,
            ),
          ),
          // 时间文字
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeText,
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  color: isRunning ? theme.colorScheme.onSurface : Colors.grey,
                ),
              ),
              if (isRunning)
                Text(
                  isBreak ? '休息' : '专注',
                  style: TextStyle(
                    fontSize: 14,
                    color: ringColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          // 进度百分比（小字）
          if (isRunning && progress > 0)
            Positioned(
              bottom: size * 0.15,
              child: Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 从顶部(-pi/2)开始，顺时针绘制
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,                      // 起始角度：顶部
      2 * pi * progress,            // 扫过角度
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
