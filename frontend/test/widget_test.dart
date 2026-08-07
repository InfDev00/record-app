import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/note.dart';

void main() {
  test('Note.fromJson 이 백엔드 JSON 을 파싱한다', () {
    final note = Note.fromJson({
      'id': 1,
      'date': '2026-08-06',
      'content': '첫 기록',
    });

    expect(note.id, 1);
    expect(note.date, DateTime(2026, 8, 6));
    expect(note.content, '첫 기록');
  });

  test('displayTitle: 제목 있으면 제목, 없으면 내용', () {
    final titled = Note.fromJson({'id': 1, 'date': '2026-08-06', 'title': '제목', 'content': '내용'});
    expect(titled.hasTitle, true);
    expect(titled.displayTitle, '제목');

    final noTitle = Note.fromJson({'id': 2, 'date': '2026-08-06', 'content': '내용만'});
    expect(noTitle.hasTitle, false);
    expect(noTitle.displayTitle, '내용만');

    final blankTitle = Note.fromJson({'id': 3, 'date': '2026-08-06', 'title': '   ', 'content': '내용'});
    expect(blankTitle.hasTitle, false);
    expect(blankTitle.displayTitle, '내용');
  });
}
