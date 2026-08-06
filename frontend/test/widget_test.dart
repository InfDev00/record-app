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
}
