import 'package:flutter/material.dart';

class ExplicitAnimationsScreen extends StatefulWidget {
  const ExplicitAnimationsScreen({super.key});

  @override
  State<ExplicitAnimationsScreen> createState() =>
      _ExplicitAnimationsScreenState();
}

class _ExplicitAnimationsScreenState extends State<ExplicitAnimationsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );

  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    _loop();
  }

  void _loop() {
    _animationController.repeat();
  }

  Widget _buildBox(int row, int col) {
    bool isWhite =
        (row % 2 == 0 && col % 2 == 0) || (row % 2 == 1 && col % 2 == 1);

    // Domino effect: Let's consider 16 intervals (8 for black and 8 for white boxes)
    // First 8 intervals (0 to 0.5) are for black boxes. Next 8 (0.5 to 1) are for white.
    double start = isWhite ? 0.5 + row * 0.0625 : row * 0.0625;
    double end = isWhite ? 0.5 + row * 0.0625 + 0.0625 : row * 0.0625 + 0.0625;

    Animation<double> boxAnimation = Tween<double>(begin: 0, end: 0.25).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(start, end, curve: Curves.easeInOut),
      ),
    );

    return RotationTransition(
      turns: boxAnimation,
      alignment:
          Alignment.center, // This keeps the box rotating around its center.
      child: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: isWhite ? const Color(0xFFDCDCD2) : const Color(0xFF262626),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 62, 65, 64),
      appBar: AppBar(
        title: const Text("Explicit Anmiations"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(8, (row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(8, (col) => _buildBox(row, col)),
            );
          }),
        ),
      ),
    );
  }
}
