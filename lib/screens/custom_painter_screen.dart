import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';

class CustomPainterScreen extends StatefulWidget {
  const CustomPainterScreen({super.key});

  @override
  State<CustomPainterScreen> createState() => _CustomPainterScreenState();
}

class _CustomPainterScreenState extends State<CustomPainterScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    duration: const Duration(seconds: 10),
    vsync: this,
    lowerBound: 0.0,
    upperBound: 2.0,
  );

  bool _isPlaying = false;
  late Timer _timer;
  int _duration = 10;

  String get _formattedDuration {
    final minutes = (_duration / 60).floor();
    final seconds = _duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _replay() {
    _animationController.reset();
    _startAnimation();
    setState(() {
      _isPlaying = true; // Change to pause icon
    });
  }

  void _play() {
    if (_animationController.isAnimating) {
      _animationController.stop();
      _timer.cancel();
    } else {
      if (_animationController.isCompleted) {
        _animationController.reset();
        _startAnimation();
      } else {
        _resumeAnimation();
      }
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _resumeAnimation() {
    _animationController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration -= 1;
        if (_duration == 0) {
          timer.cancel();
        }
      });
    });
  }

  void _startAnimation() {
    setState(() {
      _duration = 10; // Reset duration before starting
    });
    _resumeAnimation();
  }

  void _stop() {
    _animationController.stop();
    _animationController.value = 0.0; // Reset the red arc
    _timer.cancel();
    setState(() {
      _duration = 10;
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1f2937),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1f2937),
        title: const Text(
          "Custom Painter",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: TimerPainter(
                        progress: _animationController.value,
                      ),
                      size: const Size(400, 400),
                    );
                  },
                ),
                Text(
                  _formattedDuration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _replay,
                icon: const Icon(
                  Icons.replay,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              IconButton(
                onPressed: _play,
                icon: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              IconButton(
                onPressed: _stop,
                icon: const Icon(
                  Icons.stop_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
  }
}

class TimerPainter extends CustomPainter {
  final double progress;

  TimerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final circlePaint = Paint()
      ..color = const Color.fromARGB(255, 71, 74, 92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30;

    canvas.drawCircle(
      center,
      (size.width / 2) * 0.8,
      circlePaint,
    );

    final arcRect = Rect.fromCircle(
      center: center,
      radius: (size.width / 2) * 0.8,
    );

    final arcPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 30;

    canvas.drawArc(
      arcRect,
      -pi / 2,
      progress * pi,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
