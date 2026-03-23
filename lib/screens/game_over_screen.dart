import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart';
import '../services/leaderboard_service.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';

class GameOverScreen extends StatefulWidget {
  final int score;

  const GameOverScreen({super.key, required this.score});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  final _nameController = TextEditingController();
  final _service = LeaderboardService();
  bool _saved = false;

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await _service.save(name, widget.score);
    setState(() => _saved = true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Game Over',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Score: ${widget.score}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 48),
              if (!_saved) ...[
                const Text(
                  'Inserisci il tuo nome',
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Nome',
                    counterText: '',
                  ),
                  onSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Salva'),
                ),
              ] else ...[
                const Text(
                  'Salvato!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                ),
                child: const Text('Gioca ancora'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                ),
                child: const Text('Classifica'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
