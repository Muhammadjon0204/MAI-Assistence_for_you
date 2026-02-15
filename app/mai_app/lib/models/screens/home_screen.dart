// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:mai_app/services/api_service.dart';
import 'package:mai_app/services/history_service.dart';
import 'package:mai_app/services/ocr_service.dart';
import 'package:mai_app/theme/mai_theme.dart';
import 'package:mai_app/widgets/message_bubble.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
  String napiKey = 'http://localhost:5284';
  // ignore: duplicate_ignore
  // ignore: unused_field
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
          const SizedBox(
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
      decoration: const BoxDecoration(
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
                  color: ClaudeColors.textHint.withValues(alpha: 0.5),
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
              onPressed: _isLoading ? null : () => _solveProblem(napiKey),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _solveProblem(String apiKey) async {
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
      final solution = await _apiService.solveProblem(problem, apiKey);
      // ОЧИСТКА ОТВЕТА ОТ MARKDOWN СИМВОЛОВ ← ДОБАВЬ ЭТО!
      String cleanedSolution = solution.solution
          .replaceAll('**', '') // Убираем жирный текст
          .replaceAll('*', '') // Убираем курсив
          .replaceAll('###', '') // Убираем заголовки H3
          .replaceAll('##', '') // Убираем заголовки H2
          .replaceAll('#', '') // Убираем заголовки H1
          .replaceAll('---', '') // Убираем разделители
          .replaceAll('```', '') // Убираем блоки кода
          .trim();
      // СОХРАНИТЬ В ИСТОРИЮ
      await _historyService.addToHistory(problem, solution.solution);

      setState(() {
        _messages.add(ChatMessage(
          text: cleanedSolution,
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
      barrierDismissible: false, // Нельзя закрыть случайным тапом
      builder: (context) => AlertDialog(
        backgroundColor: ClaudeColors.secondaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ClaudeColors.accentBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: ClaudeColors.accentBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Проверьте текст',
              style: TextStyle(
                color: ClaudeColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Превью фото
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    image: DecorationImage(
                      image: FileImage(imageFile),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Заголовок
              Row(
                children: [
                  Icon(
                    Icons.text_fields,
                    color: ClaudeColors.accentBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Распознанный текст:',
                    style: TextStyle(
                      color: ClaudeColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Редактируемое поле
              Container(
                decoration: BoxDecoration(
                  color: ClaudeColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ClaudeColors.accentBlue.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: editController,
                  maxLines: 6,
                  style: const TextStyle(
                    color: ClaudeColors.textPrimary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Исправьте если нужно...',
                    hintStyle: TextStyle(color: ClaudeColors.textHint),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  autofocus: true,
                ),
              ),
              const SizedBox(height: 16),

              // Подсказка с иконкой
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ClaudeColors.accentBlue.withOpacity(0.1),
                      ClaudeColors.accentPurple.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ClaudeColors.accentBlue.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: ClaudeColors.accentBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'OCR может ошибаться — проверьте и исправьте текст перед отправкой',
                        style: TextStyle(
                          color: ClaudeColors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
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
          // Кнопка "Переснять"
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _handleImagePick(); // Переснять фото
            },
            icon: const Icon(Icons.camera_alt, size: 18),
            label: const Text('Переснять'),
            style: TextButton.styleFrom(
              foregroundColor: ClaudeColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          // Кнопка "Отмена"
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Отмена',
              style: TextStyle(color: ClaudeColors.textSecondary),
            ),
          ),
          // Кнопка "Решить"
          ElevatedButton.icon(
            onPressed: () {
              final editedText = editController.text.trim();
              if (editedText.isEmpty) {
                // Показать ошибку
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Текст не может быть пустым'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              Navigator.pop(context);
              _problemController.text = editedText;
              _solveProblem(napiKey);
            },
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Решить'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ClaudeColors.accentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Версия 1.0\nMAI ИИ Ассистент',
                style: TextStyle(color: ClaudeColors.textSecondary),
              ),
              IconButton(
                  onPressed: _showInputKeyDialog, icon: const Icon(Icons.key))
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

  void _showInputKeyDialog() {
    final TextEditingController apiKeyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ClaudeColors.secondaryDark,
          title: const Text(
            'Введите API ключ',
            style: TextStyle(color: ClaudeColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Здесь вы можете ввести свой API ключ для доступа к сервису решения задач. Это позволит вам использовать приложение с вашим аккаунтом и сохранять историю решений.',
                style: TextStyle(color: ClaudeColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: apiKeyController,
                style: const TextStyle(color: ClaudeColors.textPrimary),
                decoration: InputDecoration(
                  hintText: (napiKey != '') ? napiKey : 'Введите ваш API ключ',
                  hintStyle: const TextStyle(color: ClaudeColors.textHint),
                  filled: true,
                  fillColor: ClaudeColors.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть',
                  style: TextStyle(color: ClaudeColors.accentBlue)),
            ),
            ElevatedButton(
              onPressed: () {
                final apiKey = apiKeyController.text.trim();
                if (apiKey.isNotEmpty) {
                  setState(
                    () {
                      napiKey =
                          apiKey; // Здесь вы можете сохранить ключ в состоянии или использовать его для настройки ApiService
                    },
                  );
                  // Save or use the API key here
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ClaudeColors.accentBlue,
              ),
              child: const Text('Сохранить'),
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
