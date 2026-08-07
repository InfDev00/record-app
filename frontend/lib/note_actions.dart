import 'package:flutter/material.dart';

import 'compose_page.dart';
import 'note.dart';
import 'note_api.dart';

final _api = NoteApi();

/// 기록 상세 모달: 제목(있을 때만)·내용 + 삭제/수정/닫기.
/// 수정·삭제가 성공하면 [onChanged] 를 호출한다(목록·잔디 갱신용).
void showNoteDetailDialog(BuildContext context, Note n, VoidCallback onChanged) {
  showDialog<void>(
    context: context,
    builder: (dctx) => AlertDialog(
      title: n.hasTitle ? Text(n.title!) : null, // 제목 없으면 제목 칸 생략
      content: SingleChildScrollView(child: Text(n.content)),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(dctx).pop();
            if (n.id != null) {
              await _api.delete(n.id!);
              onChanged();
            }
          },
          child: const Text('삭제', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () async {
            final nav = Navigator.of(context);
            Navigator.of(dctx).pop();
            final saved = await nav.push<bool>(
              MaterialPageRoute(builder: (_) => ComposePage(existing: n)),
            );
            if (saved == true) onChanged();
          },
          child: const Text('수정'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dctx).pop(),
          child: const Text('닫기'),
        ),
      ],
    ),
  );
}
