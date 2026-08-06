/// 백엔드 NoteEntity 와 1:1 대응하는 모델.
/// JSON 모양: { "id": 1, "date": "2026-08-06", "content": "..." }
class Note {
  final int? id; // 생성 전엔 null, 서버가 저장하며 채워준다
  final DateTime date;
  final String content;

  Note({this.id, required this.date, required this.content});

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as int?,
        date: DateTime.parse(json['date'] as String),
        content: json['content'] as String,
      );
}
