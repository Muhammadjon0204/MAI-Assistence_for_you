import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/math_problem.dart'; // ← ДОБАВЬ ЭТОТ ИМПОРТ!

class HistoryService {
  static const String _historyKey = 'mai_history';
  static const String _usernameKey = 'mai_username';

  // Сохранить запрос в историю
  Future<void> addToHistory(String problem, String solution) async {
    final prefs = await SharedPreferences.getInstance();

    final history = await getHistory();
    history.insert(
        0,
        MathSolution(
          // ← ИЗМЕНЕНО!
          problem: problem,
          solution: solution,
          timestamp: DateTime.now(), solver: '', success: true, steps: [],
        ));

    // Ограничим до 50 последних запросов
    if (history.length > 50) {
      history.removeLast();
    }

    final jsonList = history
        .map((item) => jsonEncode({
              'problem': item.problem,
              'solution': item.solution,
              'timestamp': item.timestamp.toIso8601String(),
            }))
        .toList();

    await prefs.setStringList(_historyKey, jsonList);
  }

  // Получить всю историю
  Future<List<MathSolution>> getHistory() async {
    // ← ИЗМЕНЕНО!
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey);

    if (jsonList == null) return [];

    return jsonList.map((jsonString) {
      final json = jsonDecode(jsonString);
      return MathSolution(
        // ← ИЗМЕНЕНО!
        problem: json['problem'],
        solution: json['solution'],
        timestamp: DateTime.parse(json['timestamp']), solver: '', success: true, steps: [],
      );
    }).toList();
  }

  // Удалить элемент
  Future<void> deleteItem(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];

    // Удаляем по timestamp
    jsonList.removeWhere((jsonString) {
      final data = jsonDecode(jsonString);
      final itemTime = DateTime.parse(data['timestamp']);
      return itemTime.isAtSameMomentAs(timestamp);
    });

    await prefs.setStringList(_historyKey, jsonList);
  }

  // Очистить историю
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // Сохранить никнейм
  Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  // Получить никнейм
  Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? 'Гость';
  }
}
