/// 백엔드 NoteEntity 와 1:1 대응하는 모델.
/// JSON: { "id": 1, "date": "2026-08-06", "title": "제목", "content": "내용" }
/// (title 은 없을 수 있음 — 구버전 데이터/미입력 시 null)
class Note {
  final int? id; // 생성 전엔 null, 서버가 저장하며 채워준다
  final DateTime date;
  final String? title;
  final String content;

  Note({this.id, required this.date, this.title, required this.content});

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as int?,
        date: DateTime.parse(json['date'] as String),
        title: json['title'] as String?,
        content: json['content'] as String,
      );

  bool get hasTitle => title != null && title!.trim().isNotEmpty;

  /// 리스트에 크게 보일 텍스트: 제목이 있으면 제목, 없으면 내용.
  String get displayTitle => hasTitle ? title! : content;
}
