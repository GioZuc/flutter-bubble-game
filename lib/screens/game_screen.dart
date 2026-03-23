import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../game/game_controller.dart';
import '../game/bubble_painter.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameController _controller = GameController();

  StreamSubscription<AccelerometerEvent>? _accelSub;
  Timer? _gameLoop;
  Timer? _spawnTimer;

  static const _tickMs = 16; // ~60 fps

  // Spawn interval bounds (milliseconds)
  static const _spawnIntervalStart = 2000;
  static const _spawnIntervalMin = 600;

  double _screenHeight = 800.0;
  double _screenWidth = 400.0;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _controller.reset();

    _accelSub?.cancel();
    _accelSub = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((e) {
      _controller.tiltX = e.x;
    });

    _gameLoop?.cancel();
    _gameLoop = Timer.periodic(
      const Duration(milliseconds: _tickMs),
      (_) => _tick(),
    );

    // First spawn immediately, then start the recursive spawn loop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.spawn(_screenHeight);
      _scheduleNextSpawn();
    });
  }

  /// Interval decreases as difficulty grows: starts at 2000ms, min 600ms.
  int get _currentSpawnIntervalMs {
    final interval = _spawnIntervalStart / _controller.difficulty;
    return interval.clamp(_spawnIntervalMin.toDouble(), _spawnIntervalStart.toDouble()).toInt();
  }

  void _scheduleNextSpawn() {
    _spawnTimer?.cancel();
    _spawnTimer = Timer(
      Duration(milliseconds: _currentSpawnIntervalMs),
      () {
        if (!mounted || _controller.gameOver) return;
        _controller.spawn(_screenHeight);
        _scheduleNextSpawn(); // reschedule with updated interval
      },
    );
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      _controller.update(_tickMs / 1000.0, _screenHeight);
    });

    if (_controller.gameOver) {
      _gameLoop?.cancel();
      _spawnTimer?.cancel();
      _accelSub?.cancel();
      _goToGameOver();
    }
  }

  void _goToGameOver() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameOverScreen(score: _controller.score),
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    final pos = details.localPosition;
    setState(() {
      _controller.tryPop(pos.dx, pos.dy);
    });
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    _spawnTimer?.cancel();
    _accelSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _screenHeight = constraints.maxHeight;
      _screenWidth = constraints.maxWidth;
      _controller.screenWidth = _screenWidth;

      return Scaffold(
        backgroundColor: const Color(0xFFE3F2FD),
        body: GestureDetector(
          onTapDown: _onTapDown,
          child: Stack(
            children: [
              // Game canvas
              CustomPaint(
                size: Size(_screenWidth, _screenHeight),
                painter: BubblePainter(_controller.bubbles),
              ),

              // Score
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Score: ${_controller.score}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),

              // Danger zone indicator at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  color: Colors.red.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
