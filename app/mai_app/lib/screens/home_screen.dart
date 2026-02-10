// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/math_problem.dart';
import '../widgets/message_bubble.dart';
import '../theme/mai_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _problemController = TextEditingController();
  final ApiService _apiService = ApiService();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _problemController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: ClaudeColors.accentPurple),
            SizedBox(width: 8),
            Text(
              'МАИ Ассистент',
              style: TextStyle(
                color: ClaudeColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              _showSettingsDialog();
            },
            tooltip: 'Настройки',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(
                  message: _messages[index].text,
                  isUser: _messages[index].isUser,
                  timestamp: _messages[index].timestamp,
                );
              },
            ),
          ),
          if (_isLoading) _buildLoadingIndicator(),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ClaudeColors.accentPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          const Text(
            'МАИ думает...',
            style: TextStyle(color: ClaudeColors.textSecondary),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: ClaudeColors.accentBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ClaudeColors.secondaryDark,
        border: Border(
          top: BorderSide(color: ClaudeColors.borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file,
                color: ClaudeColors.textSecondary),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ClaudeColors.cardDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: ClaudeColors.borderColor, width: 0.5),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _problemController,
                      style: const TextStyle(color: ClaudeColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Задайте математическую задачу...',
                        hintStyle: TextStyle(color: ClaudeColors.textHint),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      maxLines: 4,
                      minLines: 1,
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ClaudeColors.accentBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    onPressed: _isLoading ? null : _solveProblem,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _solveProblem() async {
    final problem = _problemController.text.trim();
    if (problem.isEmpty) return;

    // Добавляем сообщение пользователя
    setState(() {
      _messages.add(ChatMessage(
        text: problem,
        isUser: true,
        timestamp: _formatTime(DateTime.now()),
      ));
      _problemController.clear();
      _isLoading = true;
    });

    // Прокрутка вниз
    _scrollToBottom();

    try {
      // Вызов API
      final solution = await _apiService.solveProblem(problem);

      // Добавляем ответ AI
      setState(() {
        _messages.add(ChatMessage(
          text: solution.solution,
          isUser: false,
          timestamp: _formatTime(DateTime.now()),
        ));
        _isLoading = false;
      });
    } catch (e) {
      // Обработка ошибки
      setState(() {
        _messages.add(ChatMessage(
          text: 'Ошибка: $e',
          isUser: false,
          timestamp: _formatTime(DateTime.now()),
        ));
        _isLoading = false;
      });
    }

    // Прокрутка вниз
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ClaudeColors.secondaryDark,
          title: const Text(
            'Настройки',
            style: TextStyle(color: ClaudeColors.textPrimary),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Версия 1.0\nМАИ Математический Ассистент',
                style: TextStyle(color: ClaudeColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть',
                  style: TextStyle(color: ClaudeColors.accentBlue)),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
