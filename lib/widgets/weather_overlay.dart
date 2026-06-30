import 'dart:math' as math;
import 'package:flutter/material.dart';

class WeatherOverlay extends StatefulWidget {
  final String condition;

  const WeatherOverlay({super.key, required this.condition});

  @override
  State<WeatherOverlay> createState() => _WeatherOverlayState();
}

class _WeatherOverlayState extends State<WeatherOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_RainDrop> _rainDrops = List.generate(80, (_) => _RainDrop());
  final List<_Star> _stars = List.generate(50, (_) => _Star());
  final List<_WindLine> _windLines = List.generate(15, (_) => _WindLine());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: _WeatherCanvasPainter(
              condition: widget.condition,
              progress: _controller.value,
              rainDrops: _rainDrops,
              stars: _stars,
              windLines: _windLines,
            ),
          );
        },
      ),
    );
  }
}

class _WeatherCanvasPainter extends CustomPainter {
  final String condition;
  final double progress;
  final List<_RainDrop> rainDrops;
  final List<_Star> stars;
  final List<_WindLine> windLines;

  _WeatherCanvasPainter({
    required this.condition,
    required this.progress,
    required this.rainDrops,
    required this.stars,
    required this.windLines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ☀️ Sun shapes have been fully removed from here to clean the map workspace
    if (condition == "windy") {
      _paintWindyGusts(canvas, size);
    } else if (condition == "rain") {
      _paintRainStreaks(canvas, size);
    } else if (condition == "night") {
      _paintNightSkyStarsOnly(canvas, size); // Moon circle vector dropped
    }
  }

  void _paintWindyGusts(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(64)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (var line in windLines) {
      final xStart = ((line.xStartOffset + progress * line.speed) % 1.2 - 0.2) * size.width;
      final yPos = line.yRatio * size.height * 0.7;
      
      final path = Path()
        ..moveTo(xStart, yPos)
        ..quadraticBezierTo(xStart + line.length * 0.5, yPos + 15 * math.sin(progress * 2 * math.pi), xStart + line.length, yPos);
      canvas.drawPath(path, paint);
    }
  }

  void _paintRainStreaks(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue.shade300.withAlpha(140)..strokeWidth = 2.0;

    for (var drop in rainDrops) {
      final yPos = ((drop.yStartOffset + progress * drop.speed) % 1.0) * size.height;
      final xPos = drop.xRatio * size.width;
      canvas.drawLine(Offset(xPos, yPos), Offset(xPos - 6, yPos + drop.length), paint);
    }
  }

  void _paintNightSkyStarsOnly(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (var star in stars) {
      final alpha = ((math.sin(progress * 4 * math.pi + star.offset) + 1) / 2 * 255).toInt();
      paint.color = Colors.white.withOpacity(alpha / 255 * 0.85);
      canvas.drawCircle(Offset(star.x * size.width, star.y * size.height * 0.6), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherCanvasPainter oldDelegate) => true;
}

class _RainDrop {
  final double xRatio = math.Random().nextDouble();
  final double yStartOffset = math.Random().nextDouble();
  final double speed = 1.2 + math.Random().nextDouble() * 0.8;
  final double length = 20 + math.Random().nextDouble() * 15;
}

class _Star {
  final double x = math.Random().nextDouble();
  final double y = math.Random().nextDouble();
  final double size = 1.0 + math.Random().nextDouble() * 2.2;
  final double offset = math.Random().nextDouble() * 15;
}

class _WindLine {
  final double xStartOffset = math.Random().nextDouble();
  final double yRatio = 0.1 + math.Random().nextDouble() * 0.8;
  final double speed = 0.5 + math.Random().nextDouble() * 0.4;
  final double length = 60 + math.Random().nextDouble() * 80;
}