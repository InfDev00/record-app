import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import 'note.dart';

/// 실행 환경별 백엔드 주소.
/// - Android 에뮬레이터: localhost 는 에뮬레이터 자신이라 10.0.2.2 로 PC 접근
/// - iOS 시뮬레이터 / 웹 / 데스크톱: localhost 그대로
String get _baseUrl {
  if (kIsWeb) return 'http://localhost:8080';
  if (Platform.isAndroid) return 'http://10.0.2.2:8080';
  return 'http://localhost:8080';
}

/// 백엔드 /api/notes CRUD 호출.
class NoteApi {
  String _ymd(DateTime d) => d.toIso8601String().split('T').first; // YYYY-MM-DD

  Future<List<Note>> fetchByDate(DateTime date) async {
    final res = await http.get(Uri.parse('$_baseUrl/api/notes?date=${_ymd(date)}'));
    // 한글 깨짐 방지: charset 미지정 응답을 명시적으로 UTF-8 디코드
    final list = jsonDecode(utf8.decode(res.bodyBytes)) as List;
    return list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Note> create(DateTime date, String content) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/api/notes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'date': _ymd(date), 'content': content}),
    );
    return Note.fromJson(jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await http.delete(Uri.parse('$_baseUrl/api/notes/$id'));
  }
}
