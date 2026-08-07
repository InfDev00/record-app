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

  /// 생성은 항상 오늘 (백엔드가 날짜를 오늘로 설정).
  Future<Note> create(String title, String content) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/api/notes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'content': content}),
    );
    return Note.fromJson(jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
  }

  /// 수정 — 백엔드에 PUT /api/notes/{id} 필요.
  Future<Note> update(int id, String title, String content) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/api/notes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'content': content}),
    );
    return Note.fromJson(jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await http.delete(Uri.parse('$_baseUrl/api/notes/$id'));
  }

  /// 잔디 히트맵용: 기간 내 날짜별 기록 개수.
  /// 응답: [{"date":"2026-08-06","count":3}, ...] (기록 없는 날은 미포함)
  /// → 날짜(자정 기준)로 키를 정규화한 Map 으로 변환.
  Future<Map<DateTime, int>> fetchCounts(DateTime from, DateTime to) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/api/notes/counts?from=${_ymd(from)}&to=${_ymd(to)}'),
    );
    final list = jsonDecode(utf8.decode(res.bodyBytes)) as List;
    final counts = <DateTime, int>{};
    for (final e in list) {
      final d = DateTime.parse(e['date'] as String);
      counts[DateTime(d.year, d.month, d.day)] = (e['count'] as num).toInt();
    }
    return counts;
  }
}
