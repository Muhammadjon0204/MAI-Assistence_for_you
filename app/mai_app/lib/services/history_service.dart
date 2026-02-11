import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryItem {
  final String problem;
  final String solution;
  final DateTime timestamp;

  HistoryItem({
    required this.problem,
    required this.solution,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'problem': problem,
        'solution': solution,
        'timestamp': timestamp.toIso8601String(),
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        problem: json['problem'],
        solution: json['solution'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class HistoryService {
  static const String _historyKey = 'mai_history';
  static const String _usernameKey = 'mai_username';

  // Сохранить запрос в историю
  Future<void> addToHistory(String problem, String solution) async {
    final prefs = await SharedPreferences.getInstance();

    final history = await getHistory();
    history.insert(
        0,
        HistoryItem(
          problem: problem,
          solution: solution,
          timestamp: DateTime.now(),
        ));

    // Ограничим до 50 последних запросов
    if (history.length > 50) {
      history.removeLast();
    }

    final jsonList = history.map((item) => item.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  // Получить всю историю
  Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);

    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => HistoryItem.fromJson(json)).toList();
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
