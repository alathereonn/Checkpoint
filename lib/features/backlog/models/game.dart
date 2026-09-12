class BacklogGame {
  const BacklogGame({
    required this.id,
    required this.title,
    required this.platform,
    required this.status,
    required this.totalSeconds,
    this.coverUrl,
    this.notes,
  });
  final int id, totalSeconds;
  final String title, platform, status;
  final String? coverUrl, notes;
  factory BacklogGame.fromJson(Map<String, dynamic> j) => BacklogGame(
    id: int.parse('${j['id']}'),
    title: j['title'] ?? '',
    platform: j['platform'] ?? '',
    status: j['status'] ?? 'plan_to_play',
    totalSeconds: int.tryParse('${j['total_playtime_seconds']}') ?? 0,
    coverUrl: j['cover_url'],
    notes: j['notes'],
  );
}

class ExternalGame {
  const ExternalGame({
    required this.externalId,
    required this.title,
    required this.platforms,
    this.coverUrl,
    this.releaseDate,
  });
  final String externalId, title;
  final List<String> platforms;
  final String? coverUrl, releaseDate;
  factory ExternalGame.fromJson(Map<String, dynamic> j) => ExternalGame(
    externalId: '${j['external_game_id']}',
    title: j['title'] ?? '',
    platforms: (j['platforms'] as List? ?? [])
        .map((e) => e.toString())
        .toList(),
    coverUrl: j['cover_url'],
    releaseDate: j['release_date'],
  );
}

String durationLabel(int s) => '${s ~/ 3600}h ${(s % 3600) ~/ 60}m';
