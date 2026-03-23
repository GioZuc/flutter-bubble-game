class LeaderboardEntry {
  final String name;
  final int score;

  LeaderboardEntry({required this.name, required this.score});

  factory LeaderboardEntry.fromString(String s) {
    final parts = s.split(':');
    return LeaderboardEntry(
      name: parts[0],
      score: int.tryParse(parts[1]) ?? 0,
    );
  }

  @override
  String toString() => '$name:$score';
}
