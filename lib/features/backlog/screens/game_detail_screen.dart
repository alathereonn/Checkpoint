import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/game.dart';
import '../providers/backlog_provider.dart';
import '../../checkpoints/screens/checkpoint_screen.dart';
import '../../play_sessions/screens/session_screen.dart';

class GameDetailScreen extends ConsumerWidget {
  const GameDetailScreen({super.key, required this.game});
  final BacklogGame game;
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: Text(game.title),
      actions: [
        PopupMenuButton(
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit backlog')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (v) async {
            if (v == 'edit')
              await showDialog(
                context: c,
                builder: (_) => EditBacklogDialog(game: game),
              );
            if (v == 'delete') {
              await ref.read(backlogProvider.notifier).remove(game.id);
              if (c.mounted) Navigator.pop(c);
            }
          },
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (game.coverUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              game.coverUrl!,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 20),
        Text(
          game.title,
          style: Theme.of(c).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          game.status.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(color: Theme.of(c).colorScheme.primary),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _Stat(label: 'Platform', value: game.platform),
            ),
            Expanded(
              child: _Stat(
                label: 'Total Playtime',
                value: durationLabel(game.totalSeconds),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => Navigator.push(
            c,
            MaterialPageRoute(builder: (_) => SessionScreen(game: game)),
          ),
          icon: const Icon(Icons.timer),
          label: const Text('PLAY SESSION'),
        ),
        const SizedBox(height: 28),
        _Link(
          title: 'Progress Checkpoints',
          subtitle: 'Track milestones, bosses, chapters, and notes',
          icon: Icons.flag,
          onTap: () => Navigator.push(
            c,
            MaterialPageRoute(builder: (_) => CheckpointScreen(game: game)),
          ),
        ),
        const SizedBox(height: 12),
        _Link(
          title: 'Session History',
          subtitle: 'See every finished play session',
          icon: Icons.history,
          onTap: () => Navigator.push(
            c,
            MaterialPageRoute(builder: (_) => SessionHistoryScreen(game: game)),
          ),
        ),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext c) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Text(label, style: Theme.of(c).textTheme.bodySmall),
          const SizedBox(height: 5),
          Text(value, style: Theme.of(c).textTheme.titleLarge),
        ],
      ),
    ),
  );
}

class _Link extends StatelessWidget {
  const _Link({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext c) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class EditBacklogDialog extends ConsumerStatefulWidget {
  const EditBacklogDialog({super.key, required this.game});
  final BacklogGame game;
  @override
  ConsumerState<EditBacklogDialog> createState() => _Edit();
}

class _Edit extends ConsumerState<EditBacklogDialog> {
  late final platform = TextEditingController(text: widget.game.platform),
      notes = TextEditingController(text: widget.game.notes);
  late String status = widget.game.status;
  @override
  Widget build(BuildContext c) => AlertDialog(
    title: const Text('Edit backlog'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: platform,
          decoration: const InputDecoration(labelText: 'Platform'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField(
          value: status,
          items: const [
            DropdownMenuItem(
              value: 'plan_to_play',
              child: Text('Plan to Play'),
            ),
            DropdownMenuItem(value: 'playing', child: Text('Playing')),
            DropdownMenuItem(value: 'completed', child: Text('Completed')),
          ],
          onChanged: (v) => status = v!,
          decoration: const InputDecoration(labelText: 'Status'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: notes,
          decoration: const InputDecoration(labelText: 'Notes'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(c),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () async {
          await ref
              .read(apiProvider)
              .put(
                '/api/backlog/${widget.game.id}',
                data: {
                  'platform': platform.text,
                  'status': status,
                  'notes': notes.text,
                },
              );
          ref.invalidate(backlogProvider);
          if (c.mounted) Navigator.pop(c);
        },
        child: const Text('Save'),
      ),
    ],
  );
}
