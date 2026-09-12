import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/game.dart';

class BacklogNotifier extends AsyncNotifier<List<BacklogGame>> {
  @override
  Future<List<BacklogGame>> build() => load();
  Future<List<BacklogGame>> load({String? status, String? search}) async {
    final d = await ref
        .read(apiProvider)
        .get(
          '/api/backlog',
          query: {
            if (status != null) 'status': status,
            if (search?.isNotEmpty == true) 'search': search,
          },
        );
    final l = (d as List)
        .map((e) => BacklogGame.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    state = AsyncData(l);
    return l;
  }

  Future<void> remove(int id) async {
    await ref.read(apiProvider).delete('/api/backlog/$id');
    ref.invalidateSelf();
  }
}

final backlogProvider =
    AsyncNotifierProvider<BacklogNotifier, List<BacklogGame>>(
      BacklogNotifier.new,
    );
