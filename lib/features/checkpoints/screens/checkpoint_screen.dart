import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_provider.dart';
import '../../backlog/models/game.dart';

class CheckpointScreen extends ConsumerStatefulWidget {
  const CheckpointScreen({super.key, required this.game});
  final BacklogGame game;
  @override
  ConsumerState<CheckpointScreen> createState() => _S();
}

class _S extends ConsumerState<CheckpointScreen> {
  late Future<dynamic> future;
  @override
  void initState() {
    super.initState();
    future = ref
        .read(apiProvider)
        .get('/api/backlog/${widget.game.id}/checkpoints');
  }

  void reload() => setState(
    () => future = ref
        .read(apiProvider)
        .get('/api/backlog/${widget.game.id}/checkpoints'),
  );
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Progress Checkpoints')),
    floatingActionButton: FloatingActionButton(
      onPressed: () => edit(),
      child: const Icon(Icons.add),
    ),
    body: FutureBuilder(
      future: future,
      builder: (_, s) {
        if (s.connectionState != ConnectionState.done)
          return const Center(child: CircularProgressIndicator());
        if (s.hasError) return Center(child: Text('${s.error}'));
        final list = s.data as List;
        if (list.isEmpty)
          return const Center(
            child: Text(
              'No checkpoints yet.\nAdd a note about your latest progress.',
              textAlign: TextAlign.center,
            ),
          );
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final x = list[i];
            return Card(
              child: ListTile(
                title: Text(x['note']),
                subtitle: Text(x['checkpoint_date'].toString()),
                trailing: PopupMenuButton(
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  onSelected: (v) async {
                    if (v == 'edit')
                      edit(item: x);
                    else {
                      await ref
                          .read(apiProvider)
                          .delete('/api/checkpoints/${x['id']}');
                      reload();
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    ),
  );
  Future<void> edit({dynamic item}) async {
    final note = TextEditingController(text: item?['note']);
    DateTime date = item == null
        ? DateTime.now()
        : DateTime.tryParse(item['checkpoint_date'].toString()) ??
              DateTime.now();
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(item == null ? 'Add Checkpoint' : 'Edit Checkpoint'),
        content: TextField(
          controller: note,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Progress note'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final data = {
                'note': note.text,
                'checkpoint_date': DateFormat('yyyy-MM-dd').format(date),
              };
              item == null
                  ? await ref
                        .read(apiProvider)
                        .post(
                          '/api/backlog/${widget.game.id}/checkpoints',
                          data: data,
                        )
                  : await ref
                        .read(apiProvider)
                        .put('/api/checkpoints/${item['id']}', data: data);
              if (c.mounted) Navigator.pop(c);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    reload();
  }
}
