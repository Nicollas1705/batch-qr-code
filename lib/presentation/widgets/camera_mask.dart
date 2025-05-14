import 'package:flutter/material.dart';

class CameraMask extends StatefulWidget {
  const CameraMask({
    super.key,
    required this.size,
    this.lineColor = Colors.red,
    this.thickness = 2,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  final Color lineColor;
  final Size size;
  final double thickness;
  final Duration animationDuration;

  @override
  State<CameraMask> createState() => _CameraMaskState();
}

class _CameraMaskState extends State<CameraMask> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _QrCodeMaskPainter(
            size: widget.size,
            backgroundColor: Colors.black.withValues(alpha: 0.3),
          ),
          size: Size.infinite,
        ),
        Center(
          child: SizedBox.fromSize(
            size: widget.size,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Align(
                  alignment: Alignment(_animation.value.dx, _animation.value.dy),
                  child: child,
                );
              },
              child: Container(
                width: widget.size.width,
                height: widget.thickness,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.lineColor.withValues(alpha: 0.3),
                      widget.lineColor,
                      widget.lineColor.withValues(alpha: 0.3),
                    ],
                    stops: const [0.1, 0.5, 0.9],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.lineColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QrCodeMaskPainter extends CustomPainter {
  _QrCodeMaskPainter({required this.size, required this.backgroundColor});

  final Size size;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

    final holeRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: this.size.width,
      height: this.size.height,
    );

    // Draw the outer black area with a transparent hole in the middle
    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRect(holeRect),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _QrCodeMaskPainter oldDelegate) => size != oldDelegate.size;
}
