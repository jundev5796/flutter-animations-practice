import 'dart:math';
import 'package:flutter/material.dart';

class ImplicitAnimationsScreen extends StatefulWidget {
  const ImplicitAnimationsScreen({Key? key}) : super(key: key);

  @override
  _ImplicitAnimationsScreenState createState() =>
      _ImplicitAnimationsScreenState();
}

class _ImplicitAnimationsScreenState extends State<ImplicitAnimationsScreen>
    with TickerProviderStateMixin {
  final List<List<AnimationController>> controllers = [];
  final List<List<Animation<double>>> xAnimations = [];
  final List<List<Animation<double>>> yAnimations = [];
  final random = Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 10; i++) {
      List<AnimationController> rowControllers = [];
      List<Animation<double>> rowXAnimations = [];
      List<Animation<double>> rowYAnimations = [];
      for (int j = 0; j < 10; j++) {
        var controller = AnimationController(
          duration: Duration(seconds: 1 + random.nextInt(5)),
          vsync: this,
        )..repeat(reverse: true);

        rowControllers.add(controller);

        double endX = (j - 4.5) * 5;
        rowXAnimations
            .add(Tween<double>(begin: 0, end: endX).animate(controller));

        double endY = (i - 4.5) * 5;
        rowYAnimations
            .add(Tween<double>(begin: 0, end: endY).animate(controller));
      }
      controllers.add(rowControllers);
      xAnimations.add(rowXAnimations);
      yAnimations.add(rowYAnimations);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2E2D),
      appBar: AppBar(title: const Text("Implicit Animations")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(10, (rowIndex) {
            return Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(10, (boxIndex) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: AnimatedBuilder(
                      animation: controllers[rowIndex][
                          boxIndex], // Directly use the AnimationController as the animation
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            xAnimations[rowIndex][boxIndex].value,
                            yAnimations[rowIndex][boxIndex].value,
                          ),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        color: (rowIndex % 2 == 0)
                            ? (boxIndex % 2 == 0
                                ? const Color(0xFFFEAD13)
                                : const Color(0xFFED4029))
                            : (boxIndex % 2 == 0
                                ? const Color(0xFF20A0AA)
                                : const Color(0xFFDFDFC4)),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var rowControllers in controllers) {
      for (var controller in rowControllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }
}

void main() => runApp(const MaterialApp(home: ImplicitAnimationsScreen()));
