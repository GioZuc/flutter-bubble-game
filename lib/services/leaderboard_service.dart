import 'package:shared_preferences/shared_preferences.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardService {
  static const _key = 'leaderboard';

  Future<List<LeaderboardEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) => LeaderboardEntry.fromString(s)).toList();
  }

  Future<void> save(String name, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await load();
    entries.add(LeaderboardEntry(name: name, score: score));
    entries.sort((a, b) => b.score.compareTo(a.score));
    final top = entries.take(10).toList();
    await prefs.setStringList(_key, top.map((e) => e.toString()).toList());
  }
}
