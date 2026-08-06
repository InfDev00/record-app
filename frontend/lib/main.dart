import 'package:flutter/material.dart';

import 'note.dart';
import 'note_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Record',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)),
      home: const TodayPage(),
    );
  }
}

/// 연동 확인용 최소 화면: 오늘 날짜의 기록을 조회/추가/삭제한다.
class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final _api = NoteApi();
  final _controller = TextEditingController();
  final _today = DateTime.now();

  late Future<List<Note>> _notes;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _notes = _api.fetchByDate(_today);
    });
  }

  Future<void> _add() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await _api.create(_today, text);
    _controller.clear();
    _reload();
  }

  Future<void> _delete(int id) async {
    await _api.delete(id);
    _reload();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ymd = _today.toIso8601String().split('T').first;
    return Scaffold(
      appBar: AppBar(title: Text('오늘 기록  $ymd')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '기록 입력',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _add, child: const Text('추가')),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Note>>(
              future: _notes,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('불러오기 실패: ${snap.error}'));
                }
                final notes = snap.data ?? [];
                if (notes.isEmpty) {
                  return const Center(child: Text('오늘 기록이 없습니다'));
                }
                return ListView(
                  children: [
                    for (final n in notes)
                      ListTile(
                        title: Text(n.content),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: n.id == null ? null : () => _delete(n.id!),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
