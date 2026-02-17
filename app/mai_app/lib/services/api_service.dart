import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/math_problem.dart';

class ApiService {
  // Render Backend URL
  static String baseUrl = 'https://mai-backend-e4hg.onrender.com/api';

  // Обновить URL (из настроек приложения)
  static void updateBaseUrl(String newUrl) {
    if (newUrl.endsWith('/api')) {
      baseUrl = newUrl;
    } else if (newUrl.endsWith('/')) {
      baseUrl = '${newUrl}api';
    } else {
      baseUrl = '$newUrl/api';
    }
  }

  Future<MathSolution> solveProblem(String problem) async {
    try {
      final url = Uri.parse('$baseUrl/Math/solve');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'problem': problem}),
          )
          .timeout(
            const Duration(seconds: 60), // Для холодного старта Render
            onTimeout: () =>
                throw Exception('Сервер не отвечает. Попробуй ещё раз!'),
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
      final response = await http.get(url).timeout(
            const Duration(seconds: 10),
          );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
