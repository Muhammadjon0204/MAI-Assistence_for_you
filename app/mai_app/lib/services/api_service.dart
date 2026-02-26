import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/math_problem.dart';

class ApiService {
  // Render Backend URL https://mai-backend-e4hg.onrender.com/api
  static String baseUrl =
      'https://mai-backend-e4hg.onrender.com/api'.trim().toString();

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
            const Duration(seconds: 120), // Увеличили для Render
            onTimeout: () =>
                throw Exception('Сервер не отвечает. Попробуй ещё раз!'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ИСПРАВЛЕНИЕ: обрабатываем разные форматы ответа
        String solution;
        if (data['solution'] is String) {
          solution = data['solution'];
        } else if (data['solution'] is List) {
          solution = (data['solution'] as List).join('\n');
        } else {
          solution = data['solution'].toString();
        }

        // Обрабатываем steps
        List<String> steps = [];
        if (data['steps'] != null) {
          if (data['steps'] is String) {
            steps = [data['steps']];
          } else if (data['steps'] is List) {
            steps = (data['steps'] as List).cast<String>();
          }
        }

        return MathSolution(
          problem: problem,
          solution: solution,
          timestamp: DateTime.now(),
          steps: steps.join('\n'),
        );
      } else {
        throw Exception('Ошибка ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Не удалось подключиться к серверу: $e');
    }
  }

  Stream<String> solveProblemStream(String problem) async* {
    final client = http.Client();
    try {
      final uri = Uri.parse(
          '$baseUrl/Math/stream?problem=${Uri.encodeComponent(problem)}');
      final request = http.Request('GET', uri);
      final response = await client.send(request).timeout(
            const Duration(seconds: 120),
          );

      await for (final line in response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data == '[DONE]') break;
          try {
            final text = jsonDecode(data) as String;
            yield text;
          } catch (_) {}
        }
      }
    } finally {
      client.close();
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
