import 'dart:math';
import '../models/bubble.dart';

class GameController {
  static const double minRadius = 18.0;
  static const double maxSpeed = 4.5;

  final Random _random = Random();

  List<Bubble> bubbles = [];
  int score = 0;
  double difficulty = 1.0;
  bool gameOver = false;
  double screenWidth = 400.0;

  // Tilt from accelerometer: -10..10 range
  double tiltX = 0.0;

  // Called once per frame. dt in seconds.
  // screenHeight needed to know when bubble exits top.
  void update(double dt, double screenHeight) {
    if (gameOver) return;

    // Increase difficulty over time
    difficulty += dt * 0.05;

    // Move bubbles
    for (final b in bubbles) {
      // Vertical: rise (speed unchanged)
      b.y -= b.speed;

      // Horizontal: tilt accelerates velocityX
      b.velocityX += -tiltX * 0.4;

      // Dampen so it doesn't accelerate forever
      b.velocityX *= 0.92;

      b.x += b.velocityX;

      // Bounce off walls: invert velocityX, keep position inside bounds
      if (b.x - b.radius < 0) {
        b.x = b.radius;
        b.velocityX = 25 * _random.nextDouble(); // stronger bounce on left wall
      } else if (b.x + b.radius > screenWidth) {
        b.x = screenWidth - b.radius;
        b.velocityX = -25 * _random.nextDouble(); // stronger bounce on right wall
      }
    }

    // Check game over: any bubble reached the top
    for (final b in bubbles) {
      if (b.y - b.radius <= 0) {
        gameOver = true;
        return;
      }
    }
  }

  void spawn(double screenHeight) {
    final count = _random.nextInt(3) + 1;
    for (int i = 0; i < count; i++) {
      final radius = max(30.0 / (difficulty * 0.3), minRadius);
      final speed = min(1.0 + (difficulty * 0.15), maxSpeed);
      bubbles.add(Bubble(
        x: _random.nextDouble() * 350 + 25,
        y: screenHeight + radius, // spawn just below visible area
        radius: radius,
        speed: speed,
      ));
    }
  }

  // Returns true if the bubble was hit
  bool tryPop(double tapX, double tapY) {
    for (int i = 0; i < bubbles.length; i++) {
      final b = bubbles[i];
      final dx = tapX - b.x;
      final dy = tapY - b.y;
      if (dx * dx + dy * dy <= b.radius * b.radius) {
        bubbles.removeAt(i);
        score++;
        return true;
      }
    }
    return false;
  }

  void reset() {
    bubbles.clear();
    score = 0;
    difficulty = 1.0;
    gameOver = false;
    tiltX = 0.0;
  }
}
