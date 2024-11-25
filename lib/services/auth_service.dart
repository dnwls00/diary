import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8000/api';
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'user_email';
  static String? _token;
  static String? _email;

  static String? get token => _token;
  static String? get email => _email;

  static Future<void> saveToken(String token, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_emailKey, email);
    _token = token;
    _email = email;
  }

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _email = prefs.getString(_emailKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    _token = null;
    _email = null;
  }

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      if (username.isEmpty) {
        return {'success': false, 'message': '아이디를 입력해주세요'};
      }

      if (password.isEmpty) {
        return {'success': false, 'message': '비밀번호를 입력해주세요'};
      }

      if (password.length < 6) {
        return {'success': false, 'message': '비밀번호는 6자리 이상이어야 합니다'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await saveToken(data['token'], username);
        return {'success': true, 'message': '로그인 성공'};
      }

      if (data['error'] == 'user_not_found') {
        return {'success': false, 'message': '존재하지 않는 아이디입니다'};
      } else if (data['error'] == 'wrong_password') {
        return {'success': false, 'message': '비밀번호가 올바르지 않습니다'};
      } else {
        return {'success': false, 'message': data['message'] ?? '로그인 실패'};
      }
    } catch (e) {
      return {'success': false, 'message': '서버 연결에 실패했습니다. 잠시 후 다시 시도해주세요.'};
    }
  }

  static Future<void> logout() async {
    await clearToken();
  }

  static Future<Map<String, dynamic>> register(
      String username, String password) async {
    try {
      if (username.isEmpty) {
        return {'success': false, 'message': '아이디를 입력해주세요'};
      }

      if (password.isEmpty) {
        return {'success': false, 'message': '비밀번호를 입력해주세요'};
      }

      if (password.length < 6) {
        return {'success': false, 'message': '비밀번호는 6자리 이상이어야 합니다'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': '회원가입 성공'};
      }

      if (data['error'] == 'user_exists') {
        return {'success': false, 'message': '이미 사용 중인 아이디입니다'};
      } else {
        return {'success': false, 'message': data['message'] ?? '회원가입 실패'};
      }
    } catch (e) {
      return {'success': false, 'message': '서버 연결에 실패했습니다. 잠시 후 다시 시도해주세요.'};
    }
  }

  static Future<bool> validateToken() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/validate-token/'),
        headers: {
          'Authorization': 'Token $_token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
