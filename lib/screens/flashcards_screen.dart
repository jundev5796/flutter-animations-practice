import 'dart:math';
import 'package:flutter/material.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({Key? key}) : super(key: key);

  @override
  _FlashcardsScreenState createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _dragController;
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;
  double _flipAngle = 0;
  int _currentIndex = 0;
  double _dragOffset = 0;
  final List<String> _questions = [
    "Do you like Flutter?",
    "What is your hobby?",
    "What did you do this weekend?",
    "What are you doing this week?",
    "Your plan after challenge",
  ];
  final List<String> _answers = [
    "Yes!",
    "Gaming",
    "Watch Season 2 of Loki",
    "Work on Flutter Animations project",
    "Maybe study ReactJS",
  ];
  final Color _backgroundColor = const Color(0xFF3FCAFE);

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _dragController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _colorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _flipController.addListener(() {
      setState(() {
        _flipAngle = (_flipController.value * 180).clamp(0.0, 180.0);
      });
    });

    _dragController.addListener(() {
      setState(() {
        _dragOffset = _dragController.value;
      });
    });

    _colorAnimation = ColorTween(begin: _backgroundColor, end: _backgroundColor)
        .animate(_colorController);
  }

  void _onCardTap() {
    if (_flipController.status == AnimationStatus.dismissed ||
        _flipController.status == AnimationStatus.reverse) {
      _flipController.forward();
    } else if (_flipController.status == AnimationStatus.completed ||
        _flipController.status == AnimationStatus.forward) {
      _flipController.reverse();
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.primaryDelta!;
      if (_dragOffset > 0) {
        _colorAnimation = ColorTween(
          begin: _backgroundColor,
          end: Colors.green,
        ).animate(_colorController);
      } else if (_dragOffset < 0) {
        _colorAnimation = ColorTween(
          begin: _backgroundColor,
          end: Colors.red,
        ).animate(_colorController);
      }
      _colorController.forward();
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() > 100) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (_currentIndex < _questions.length - 1) {
          setState(() {
            _currentIndex++;
          });
        }
      });
    }
    _dragController.animateTo(0).then((_) {
      setState(() {
        _dragOffset = 0;
      });
    });

    _colorController.reverse();
  }

  void _nextCard() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _dragOffset = 0;
      });
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _dragController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _colorAnimation.value,
          appBar: AppBar(
            backgroundColor: _colorAnimation.value,
            title: const Text('Flashcards'),
          ),
          body: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_currentIndex < _questions.length - 1)
                  Transform.scale(
                    scale:
                        1 - (0.1 * (_dragOffset.abs() / 300).clamp(0.0, 1.0)),
                    child: Card(
                      child: SizedBox(
                        width: 300,
                        height: 400,
                        child: Center(
                          child: Text(
                            _questions[_currentIndex + 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                Transform.translate(
                  offset: Offset(_dragOffset, 0),
                  child: GestureDetector(
                    onTap: _onCardTap,
                    onHorizontalDragUpdate: _onHorizontalDragUpdate,
                    onHorizontalDragEnd: _onHorizontalDragEnd,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(pi * _flipAngle / 180),
                      child: _flipAngle < 90
                          ? Card(
                              child: SizedBox(
                                width: 300,
                                height: 400,
                                child: Center(
                                  child: Text(_questions[_currentIndex]),
                                ),
                              ),
                            )
                          : Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(pi),
                              child: Card(
                                child: SizedBox(
                                  width: 300,
                                  height: 400,
                                  child: Center(
                                    child: Text(_answers[_currentIndex]),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomPaint(
            painter:
                ProgressBarPainter(_currentIndex / (_questions.length - 1)),
            child: Container(
              height: 5,
            ),
          ),
        );
      },
    );
  }
}

class ProgressBarPainter extends CustomPainter {
  final double progress;

  ProgressBarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(0, 0, size.width * progress, size.height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
