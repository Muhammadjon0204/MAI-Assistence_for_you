import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/math_problem.dart';

class ApiService {
  // Используем относительный путь, чтобы Nginx проксировал запросы
  // Это работает и локально (если настроен прокси), и в Docker
  static String baseUrl = '  https://mai-backend-e4hg.onrender.com/api';
  static void updateBaseUrl(String newUrl) {
    // Убираем /api если уже есть
    if (newUrl.endsWith('/api')) {
      baseUrl = newUrl;
    } else if (newUrl.endsWith('/')) {
      baseUrl = '${newUrl}api';
    } else {
      baseUrl = '$newUrl/api';
    }
  }

  Future<MathSolution> solveProblem(String problem, String apiKey) async {
    baseUrl = '$apiKey/api'; // Обновляем базовый URL на введенный пользователем
    try {
      final url = Uri.parse('$baseUrl/Math/solve');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'problem': problem}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MathSolution.fromJson(data);
      } else {
        throw Exception('Ошибка ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Не удалось подключиться к серверу: $e');
    }
  }

  Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$baseUrl/Math/test');
      final response = await http.get(url);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
