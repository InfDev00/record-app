import 'package:flutter/material.dart';

import 'compose_page.dart';
import 'note.dart';
import 'note_api.dart';

/// 선택된 날짜의 기록 목록(읽기 전용)을 옆에서 보여주는 임베드 패널.
/// 항목을 누르면 모달로 제목/내용을 보고 수정·삭제할 수 있다.
/// 추가는 이 패널이 아니라 캘린더 우상단의 작성 버튼으로 (항상 오늘).
class DayPanel extends StatefulWidget {
  final DateTime date;
  final VoidCallback onChanged;
  const DayPanel({super.key, required this.date, required this.onChanged});

  @override
  State<DayPanel> createState() => _DayPanelState();
}

class _DayPanelState extends State<DayPanel> {
  final _api = NoteApi();
  late Future<List<Note>> _notes;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(DayPanel old) {
    super.didUpdateWidget(old);
    if (old.date != widget.date) _reload();
  }

  void _reload() {
    setState(() {
      _notes = _api.fetchByDate(widget.date);
    });
  }

  Future<void> _delete(int id) async {
    await _api.delete(id);
    _reload();
    widget.onChanged();
  }

  Future<void> _edit(Note n) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ComposePage(existing: n)),
    );
    if (saved == true) {
      _reload();
      widget.onChanged();
    }
  }

  void _openDetail(Note n) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: n.hasTitle ? Text(n.title!) : null, // 제목 없으면 제목 칸 자체를 생략
        content: SingleChildScrollView(child: Text(n.content)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              if (n.id != null) _delete(n.id!);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              _edit(n);
            },
            child: const Text('수정'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ymd = widget.date.toIso8601String().split('T').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Text(ymd, style: Theme.of(context).textTheme.titleMedium),
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
                return const Center(child: Text('기록이 없습니다'));
              }
              return ListView(
                children: [
                  for (final n in notes)
                    ListTile(
                      dense: true,
                      title: Text(n.displayTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () => _openDetail(n),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
