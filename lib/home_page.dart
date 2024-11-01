import 'dart:async';
import 'package:fluppy_bird/barriers.dart';
import 'package:fluppy_bird/bird.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static double birdYaxis = 0;
  double time = 0;
  double height = 0;
  double initialHeight = birdYaxis;
  bool gameHasStarted = false;
  int score = 0;
  int bestScore = 0;

  List<double> barrierX = [2.5, 4.0, 5.5];  // Start barriers off-screen
  List<double> barrierHeights = [200.0, 250.0, 180.0];
  Duration barrierAnimationDuration = const Duration(milliseconds: 2000);

  void jump() {
    setState(() {
      time = 0;
      initialHeight = birdYaxis;
    });
  }

  void startGame() {
    gameHasStarted = true;
    barrierAnimationDuration = const Duration(milliseconds: 0); // Normal speed
    Timer.periodic(const Duration(milliseconds: 60), (timer) {
      time += 0.04;
      height = -4.9 * time * time + 2.8 * time;
      setState(() {
        birdYaxis = initialHeight - height;
      });

      moveBarriers();

      if (birdYaxis > 1 || checkCollision()) {
        timer.cancel();
        gameHasStarted = false;
        _showGameOverDialog();
      }

      updateScore();
    });
  }

  void moveBarriers() {
    setState(() {
      for (int i = 0; i < barrierX.length; i++) {
        if (barrierX[i] < -2) {
          barrierX[i] += 4.5;
          barrierHeights[i] = [150.0, 200.0, 250.0, 180.0][i % 4];
        } else {
          barrierX[i] -= 0.05;
        }
      }
    });
  }

  bool checkCollision() {
    for (double barrierPos in barrierX) {
      if (barrierPos < 0.2 && barrierPos > -0.2) {
        if (birdYaxis < -0.7 || birdYaxis > 0.7) {
          return true;
        }
      }
    }
    return false;
  }

  void updateScore() {
    setState(() {
      for (double barrierPos in barrierX) {
        if (barrierPos < 0 && barrierPos > -0.05) {
          score += 1;
        }
      }
    });
  }

  void _showGameOverDialog() {
    if (score > bestScore) {
      bestScore = score;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Game Over"),
          content: Text("Your Score: $score"),
          actions: [
            TextButton(
              child: const Text("Try Again"),
              onPressed: () {
                resetGame();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      birdYaxis = 0;
      time = 0;
      height = 0;
      initialHeight = birdYaxis;
      barrierX = [2.5, 4.0, 5.5];
      score = 0;
      gameHasStarted = false;
      barrierAnimationDuration = const Duration(milliseconds: 2000); // Reset animation
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (gameHasStarted) {
          jump();
        } else {
          startGame();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  AnimatedContainer(
                    alignment: Alignment(0, birdYaxis),
                    duration: const Duration(milliseconds: 0),
                    color: Colors.blue,
                    child: MyBird(),
                  ),
                  Container(
                    alignment: const Alignment(0, -0.3),
                    child: gameHasStarted
                        ? const Text("")
                        : const Text(
                      "T A P  T O  PLAY",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  if (gameHasStarted)
                    for (int i = 0; i < barrierX.length; i++) ...[
                      AnimatedContainer(
                        alignment: Alignment(barrierX[i], 1.1),
                        duration: barrierAnimationDuration,
                        child: MyBarrier(size: barrierHeights[i]),
                      ),
                      AnimatedContainer(
                        alignment: Alignment(barrierX[i], -1.1),
                        duration: barrierAnimationDuration,
                        child: MyBarrier(size: barrierHeights[i]),
                      ),
                    ]
                ],
              ),
            ),
            Container(
              height: 15,
              color: Colors.green,
            ),
            Expanded(
              child: Container(
                color: Colors.brown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text(
                              "SCORE",
                              style:
                              TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "$score",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 35),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              "BEST",
                              style:
                              TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "$bestScore",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 35),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "BY HOSSAM ELBESH",
                      style: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
