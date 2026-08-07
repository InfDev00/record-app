import 'package:flutter/material.dart';

import 'note.dart';
import 'note_actions.dart';
import 'note_api.dart';

/// 넓은 화면용: 선택된 날짜의 기록 목록(읽기 전용)을 옆에서 보여주는 패널.
/// 항목을 누르면 공용 모달로 상세/수정/삭제. 추가는 캘린더 우상단 작성 버튼.
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

  void _onChanged() {
    _reload();
    widget.onChanged();
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
                      onTap: () => showNoteDetailDialog(context, n, _onChanged),
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
