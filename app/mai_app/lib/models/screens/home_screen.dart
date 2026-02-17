// ignore_for_file: unused_field, unused_import

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: duplicate_ignore
// ignore: unused_import
import 'package:mai_app/models/screens/auth_screen.dart';
import 'package:mai_app/models/screens/subscription_screen.dart';
import 'package:mai_app/services/api_service.dart';
import 'package:mai_app/services/auth_service.dart';
import 'package:mai_app/services/history_service.dart';
import 'package:mai_app/services/ocr_service.dart';
import 'package:mai_app/services/subscription_service.dart';
import 'package:mai_app/theme/mai_theme.dart';
import 'package:mai_app/widgets/message_bubble.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  SubscriptionTier _currentTier = SubscriptionTier.free;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
    _loadApiUrl();
  }

  // Метод загрузки подписки
  Future<void> _loadSubscription() async {
    final subscription = await SubscriptionService().getSubscription();
    setState(() {
      _currentTier = subscription.tier;
    });
  }

  // Метод загрузки API URL
  Future<void> _loadApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('api_base_url');
    if (savedUrl != null) {
      setState(() {
        napiKey = savedUrl;
      });
    }
  }

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: ClaudeColors.accentPurple),
            const SizedBox(width: 8),
            const Text(
              'MAI Assistent',
              style: TextStyle(
                color: ClaudeColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            // Бэйдж подписки
            FutureBuilder<Subscription>(
              future: SubscriptionService().getSubscription(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final tier = snapshot.data!.tier;
                final tierName = SubscriptionService().getTierName(tier);

                Color badgeColor;
                Gradient? gradient;

                switch (tier) {
                  case SubscriptionTier.free:
                    badgeColor = Colors.grey;
                    break;
                  case SubscriptionTier.pro:
                    badgeColor = const Color(0xFF667eea);
                    break;
                  case SubscriptionTier.premium:
                    badgeColor = Colors.transparent;
                    gradient = const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    );
                    break;
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      color: gradient == null ? badgeColor : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tierName,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        centerTitle: true,
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
      final solution = await _apiService.solveProblem(problem);
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
                // ignore: deprecated_member_use
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
              const Row(
                children: [
                  Icon(
                    Icons.text_fields,
                    color: ClaudeColors.accentBlue,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
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
                    // ignore: deprecated_member_use
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
                      // ignore: deprecated_member_use
                      ClaudeColors.accentBlue.withOpacity(0.1),
                      // ignore: deprecated_member_use
                      ClaudeColors.accentPurple.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    // ignore: deprecated_member_use
                    color: ClaudeColors.accentBlue.withOpacity(0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: ClaudeColors.accentBlue,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
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
              // Подписки
              ListTile(
                leading: const Icon(Icons.workspace_premium,
                    color: Color(0xFFFFD700)),
                title: const Text('Подписки',
                    style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white54, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen()),
                  ).then((_) => _loadSubscription());
                },
              ),

              const Divider(color: Colors.white24),

              const Divider(color: Colors.white24),

              // СЕКРЕТНАЯ КНОПКА - Долгое нажатие на Версию
              GestureDetector(
                onLongPress: () {
                  Navigator.pop(context);
                  _showAdminDialog();
                },
                child: const ListTile(
                  title: Text(
                    'Версия 1.1',
                    style: TextStyle(color: ClaudeColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Text(
                    'МАИ Математический Ассистент',
                    style: TextStyle(
                        color: ClaudeColors.textSecondary, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const Divider(color: Colors.white24),
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

  // ADMIN панель (открывается долгим нажатием на версию)
  Future<void> _showAdminDialog() async {
    final TextEditingController codeController = TextEditingController();

    final authorized = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ClaudeColors.secondaryDark,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.red),
            SizedBox(width: 12),
            Text('ADMIN MODE', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Введите секретный код:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Код доступа',
                hintStyle: const TextStyle(color: Colors.white30),
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // Проверяем секретный код
              if (codeController.text == 'adminKosimovM4343') {
                // ← ТВОЙ СЕКРЕТНЫЙ КОД
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Неверный код!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Войти'),
          ),
        ],
      ),
    );

    if (authorized == true) {
      _showAdminPanel();
    }
  }

// ADMIN панель управления
  Future<void> _showAdminPanel() async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Row(
          children: [
            Icon(Icons.verified_user, color: Color(0xFFFFD700)),
            SizedBox(width: 12),
            Text('👑 ADMIN PANEL', style: TextStyle(color: Color(0xFFFFD700))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Дать себе Premium
            ListTile(
              leading:
                  const Icon(Icons.workspace_premium, color: Color(0xFFFFD700)),
              title: const Text('Дать себе Premium',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('Навсегда, бесплатно',
                  style: TextStyle(color: Colors.white60, fontSize: 12)),
              onTap: () => Navigator.pop(context, 'grant_premium'),
            ),

            const Divider(color: Colors.white24),

            // Дать себе Pro
            ListTile(
              leading: const Icon(Icons.stars, color: Color(0xFF667eea)),
              title: const Text('Дать себе Pro',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('На 30 дней',
                  style: TextStyle(color: Colors.white60, fontSize: 12)),
              onTap: () => Navigator.pop(context, 'grant_pro'),
            ),

            const Divider(color: Colors.white24),

            // Сбросить к Free
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.grey),
              title: const Text('Вернуться к Free',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, 'reset_free'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );

    // Выполняем действие
    final subscriptionService = SubscriptionService();

    switch (action) {
      case 'grant_premium':
        await subscriptionService.grantSubscription(
          tier: SubscriptionTier.premium,
          isLifetime: true,
        );
        _loadSubscription();
        _showSuccessSnackbar(
            '🎉 Premium активирован навсегда!', const Color(0xFFFFD700));
        break;

      case 'grant_pro':
        await subscriptionService.grantSubscription(
          tier: SubscriptionTier.pro,
          durationDays: 30,
        );
        _loadSubscription();
        _showSuccessSnackbar(
            '✨ Pro активирован на 30 дней!', const Color(0xFF667eea));
        break;

      case 'reset_free':
        await subscriptionService.grantSubscription(
            tier: SubscriptionTier.free);
        _loadSubscription();
        _showSuccessSnackbar('Возврат к Free плану', Colors.grey);
        break;
    }
  }

// Показать уведомление об успехе
  void _showSuccessSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ignore: unused_element
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
