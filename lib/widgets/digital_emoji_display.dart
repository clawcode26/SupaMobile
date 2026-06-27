import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class DigitalEmojiDisplay extends StatefulWidget {
  final String emojiType; // 'happy', 'neutral', 'monitoring', 'active'
  const DigitalEmojiDisplay({super.key, this.emojiType = 'monitoring'});

  @override
  State<DigitalEmojiDisplay> createState() => _DigitalEmojiDisplayState();
}

class _DigitalEmojiDisplayState extends State<DigitalEmojiDisplay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.supaGreen.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(44, 44),
            painter: _NothingDotMatrixPainter(
              type: widget.emojiType,
              pulse: _controller.value,
              dotColor: AppColors.supaGreen,
            ),
          );
        },
      ),
    );
  }
}

class _NothingDotMatrixPainter extends CustomPainter {
  final String type;
  final double pulse;
  final Color dotColor;

  _NothingDotMatrixPainter({required this.type, required this.pulse, required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = dotColor.withOpacity(0.3 + (pulse * 0.7))
      ..style = PaintingStyle.fill;

    final double dotSize = 2.0;
    final double spacing = 1.0;
    final int rows = 12;
    final int cols = 12;

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        bool shouldDraw = _getPixel(x, y);
        if (shouldDraw) {
          canvas.drawCircle(
            Offset(x * (dotSize + spacing) + dotSize, y * (dotSize + spacing) + dotSize),
            dotSize / 2,
            dotPaint,
          );
        } else {
          // Draw faint background dots for that authentic Nothing look
          canvas.drawCircle(
            Offset(x * (dotSize + spacing) + dotSize, y * (dotSize + spacing) + dotSize),
            dotSize / 4,
            Paint()..color = Colors.white.withOpacity(0.05),
          );
        }
      }
    }
  }

  bool _getPixel(int x, int y) {
    // 12x12 Dot Matrix Android Logo Simplified
    
    // Antennas
    if (y == 0) {
      if (x == 3 || x == 8) return true;
    }
    if (y == 1) {
      if (x == 4 || x == 7) return true;
    }

    // Head (semi-circle)
    if (y == 2) {
      if (x >= 3 && x <= 8) return true;
    }
    if (y == 3) {
      if (x >= 2 && x <= 9) return true;
    }

    // Eyes
    if (y == 3) {
      if (x == 4 || x == 7) return false; // Punched out eyes
    }

    // Body (Rectangle)
    if (y >= 4 && y <= 8) {
       if (x >= 2 && x <= 9) return true;
    }

    // Hands
    if (y >= 4 && y <= 7) {
      if (x == 0 || x == 11) return true;
    }

    // Legs
    if (y == 9 || y == 10) {
      if (x == 4 || x == 7) return true;
    }

    // Scanline animation over the logo
    int scanY = (pulse * 12).toInt();
    if (y == scanY) return true;

    return false;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
