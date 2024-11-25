import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class DiaryService {
  static const String baseUrl = 'http://localhost:8000/api';

  static Future<List<Diary>> getDiaries() async {
    final response = await http.get(
      Uri.parse('$baseUrl/diaries/'),
      headers: {'Authorization': 'Token ${AuthService.token}'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Diary.fromJson(json)).toList();
    }
    throw Exception('Failed to load diaries');
  }

  static Future<void> saveDiary(String date, String content) async {
    final existingDiary = await getDiary(date);

    final response = existingDiary != null
        ? await http.put(
            Uri.parse('$baseUrl/diaries/$date/'),
            headers: {
              'Authorization': 'Token ${AuthService.token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'date': date,
              'content': content,
            }),
          )
        : await http.post(
            Uri.parse('$baseUrl/diaries/'),
            headers: {
              'Authorization': 'Token ${AuthService.token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'date': date,
              'content': content,
            }),
          );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save diary');
    }
  }

  static Future<void> deleteDiary(String date) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/diaries/$date/'),
      headers: {'Authorization': 'Token ${AuthService.token}'},
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete diary: ${response.statusCode}');
    }
  }

  static Future<Diary?> getDiary(String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/diaries/$date/'),
        headers: {'Authorization': 'Token ${AuthService.token}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Diary.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      }
      return null;
    } catch (e) {
      print('Error in getDiary: $e');
      return null;
    }
  }
}

class Diary {
  final String date;
  final String content;

  Diary({required this.date, required this.content});

  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      date: json['date'],
      content: json['content'],
    );
  }
}
