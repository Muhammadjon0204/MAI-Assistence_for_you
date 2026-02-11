import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/math_problem.dart';

class ApiService {
  // Измени на свой IP адрес компьютера!
  // Для Windows: ipconfig -> IPv4 Address
  // Для эмулятора Android: 10.0.2.2
  static const String baseUrl = 'http://localhost:5284/api';
  Future<MathSolution> solveProblem(String problem) async {
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
