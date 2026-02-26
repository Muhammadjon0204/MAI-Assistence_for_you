import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/math_problem.dart';

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
          problem: problem,
          solution: solution,
          timestamp: DateTime.now(),
          steps: '',
        ));

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
    final prefs = await SharedPreferences.getInstance();

    // ← ИСПРАВЛЕНИЕ: если старые данные в формате String — удаляем и начинаем заново
    try {
      final jsonList = prefs.getStringList(_historyKey);
      if (jsonList == null) return [];

      return jsonList.map((jsonString) {
        final json = jsonDecode(jsonString);
        return MathSolution(
          problem: json['problem'] ?? '',
          solution: json['solution'] ?? '',
          timestamp:
              DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
          steps: '',
        );
      }).toList();
    } catch (e) {
      // Старый формат данных — очищаем хранилище
      await prefs.remove(_historyKey);
      return [];
    }
  }

  // Удалить элемент
  Future<void> deleteItem(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final jsonList = prefs.getStringList(_historyKey) ?? [];
      jsonList.removeWhere((jsonString) {
        final data = jsonDecode(jsonString);
        final itemTime = DateTime.parse(data['timestamp']);
        return itemTime.isAtSameMomentAs(timestamp);
      });
      await prefs.setStringList(_historyKey, jsonList);
    } catch (e) {
      await prefs.remove(_historyKey);
    }
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
