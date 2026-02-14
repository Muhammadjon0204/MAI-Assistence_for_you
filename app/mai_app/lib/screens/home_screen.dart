import 'package:flutter/material.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../services/history_service.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ocr_service.dart';
import '../models/math_problem.dart';
import '../widgets/message_bubble.dart';
import '../theme/mai_theme.dart';
import 'history_screen.dart';

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
  final HistoryService _historyService = HistoryService();
  final OcrService _ocrService = OcrService();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  File? _selectedImage;
  String? _recognizedText;
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
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            );
          },
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: ClaudeColors.accentPurple),
            SizedBox(width: 8),
            Text(
              'MAI Assistent',
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
            'MAI thinking...',
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ClaudeColors.secondaryDark,
        border: Border(
          top: BorderSide(color: ClaudeColors.borderColor, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Кнопка скрепки
          // Кнопка скрепки - ДОБАВЛЯЕМ ДЕЙСТВИЕ!
          IconButton(
            icon: const Icon(Icons.attach_file,
                color: ClaudeColors.textSecondary),
            onPressed: _handleImagePick, // ← ИЗМЕНИЛИ!
            padding: const EdgeInsets.all(8),
          ),
          const SizedBox(width: 8),

          // Поле ввода
          Expanded(
            child: TextField(
              controller: _problemController,
              style: const TextStyle(
                  color: ClaudeColors.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Задайте свой вопрос...',
                hintStyle: TextStyle(
                  color: ClaudeColors.textHint.withOpacity(0.5),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              maxLines: 5,
              minLines: 1,
              textInputAction: TextInputAction.newline,
            ),
          ),

          const SizedBox(width: 8),

          // Кнопка отправки
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            child: IconButton(
              icon: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: _isLoading ? null : _solveProblem,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _solveProblem() async {
    final problem = _problemController.text.trim();
    if (problem.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: problem,
        isUser: true,
        timestamp: _formatTime(DateTime.now()),
      ));
      _problemController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final solution = await _apiService.solveProblem(problem);

      // СОХРАНИТЬ В ИСТОРИЮ
      await _historyService.addToHistory(problem, solution.solution);

      setState(() {
        _messages.add(ChatMessage(
          text: solution.solution,
          isUser: false,
          timestamp: _formatTime(DateTime.now()),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Ошибка: $e',
          isUser: false,
          timestamp: _formatTime(DateTime.now()),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  Future<void> _handleImagePick() async {
    // Показываем диалог: Камера или Галерея?
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ClaudeColors.secondaryDark,
        title: const Text(
          'Выберите источник',
          style: TextStyle(color: ClaudeColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.camera_alt, color: ClaudeColors.accentBlue),
              title: const Text('Камера',
                  style: TextStyle(color: ClaudeColors.textPrimary)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library,
                  color: ClaudeColors.accentPurple),
              title: const Text('Галерея',
                  style: TextStyle(color: ClaudeColors.textPrimary)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    setState(() => _isLoading = true);

    try {
      // Получаем фото
      final File? imageFile = source == ImageSource.camera
          ? await _ocrService.takePhoto()
          : await _ocrService.pickImage();

      if (imageFile == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Распознаём текст
      final recognizedText = await _ocrService.recognizeText(imageFile);

      setState(() {
        _selectedImage = imageFile;
        _recognizedText = recognizedText;
        _isLoading = false;
      });

      // Показываем редактируемую карточку
      _showEditableTextDialog(recognizedText, imageFile);
    } catch (e) {
      setState(() => _isLoading = false);

      // Показываем ошибку
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditableTextDialog(String initialText, File imageFile) {
    final TextEditingController editController =
        TextEditingController(text: initialText);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ClaudeColors.secondaryDark,
        title: Row(
          children: [
            const Icon(Icons.edit, color: ClaudeColors.accentBlue),
            const SizedBox(width: 8),
            const Text(
              'Проверьте текст',
              style: TextStyle(color: ClaudeColors.textPrimary),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Превью фото
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(imageFile),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Заголовок
              const Text(
                '📝 Распознанный текст:',
                style: TextStyle(
                  color: ClaudeColors.accentBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Редактируемое поле
              TextField(
                controller: editController,
                maxLines: 5,
                style: const TextStyle(color: ClaudeColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Исправьте если нужно...',
                  hintStyle: const TextStyle(color: ClaudeColors.textHint),
                  filled: true,
                  fillColor: ClaudeColors.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Подсказка
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ClaudeColors.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ClaudeColors.accentBlue.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: ClaudeColors.accentBlue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Проверьте и исправьте текст если OCR ошибся',
                        style: TextStyle(
                          color: ClaudeColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена',
                style: TextStyle(color: ClaudeColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final editedText = editController.text.trim();
              if (editedText.isNotEmpty) {
                Navigator.pop(context);
                _problemController.text = editedText;
                _solveProblem();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ClaudeColors.accentBlue,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 18),
                SizedBox(width: 4),
                Text('Решить'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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
                'Версия 1.0\nMAI ИИ Ассистент',
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
