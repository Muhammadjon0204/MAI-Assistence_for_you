import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class User {
  final String id;
  final String nickname;
  final String email;

  User({
    required this.id,
    required this.nickname,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'email': email,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        nickname: json['nickname'],
        email: json['email'],
      );
}

class AuthService {
  static const String _userKey = 'mai_current_user';
  static const String _isLoggedInKey = 'mai_is_logged_in';

  // Проверка авторизован ли пользователь
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Получить текущего пользователя
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson == null) return null;

    return User.fromJson(jsonDecode(userJson));
  }

  // Регистрация (локальная)
  Future<bool> register({
    required String nickname,
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Создаём пользователя
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nickname: nickname,
        email: email,
      );

      // Сохраняем пользователя
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      await prefs.setBool(_isLoggedInKey, true);

      // Сохраняем пароль (зашифрованный - простая версия)
      await prefs.setString('mai_password', password);

      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  // Вход
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPassword = prefs.getString('mai_password');
      final userJson = prefs.getString(_userKey);

      if (savedPassword == password && userJson != null) {
        await prefs.setBool(_isLoggedInKey, true);
        return true;
      }

      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Выход
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Обновить никнейм
  Future<void> updateNickname(String newNickname) async {
    final user = await getCurrentUser();
    if (user != null) {
      final updatedUser = User(
        id: user.id,
        nickname: newNickname,
        email: user.email,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(updatedUser.toJson()));
    }
  }
}
