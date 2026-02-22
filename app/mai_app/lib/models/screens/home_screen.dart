// ignore_for_file: deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mai_app/models/screens/history_screen.dart';
import 'package:mai_app/models/screens/subscription_screen.dart' as screens;
import 'package:mai_app/models/chat_message.dart';
import 'package:mai_app/services/api_service.dart';
import 'package:mai_app/services/history_service.dart';
import 'package:mai_app/services/subscription_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Сервисы
  final ApiService _apiService = ApiService();
  final HistoryService _historyService = HistoryService();
  final SubscriptionService _subscriptionService = SubscriptionService();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Загрузка истории при запуске
  Future<void> _loadHistory() async {
    final history = await _historyService.getHistory();
    setState(() {
      _messages.addAll(history.map((item) => ChatMessage(
            text: item.problem,
            isUser: true,
            timestamp: item.timestamp,
          )));

      // Добавляем ответы AI
      for (var item in history) {
        _messages.add(ChatMessage(
          text: item.solution,
          isUser: false,
          timestamp: item.timestamp,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1a1a1a),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _messages.isEmpty // ← ИСПРАВЬ!
                ? _buildEmptyState()
                : _buildChatList(),
          ),
          if (_isLoading) _buildLoadingIndicator(), // ← ДОБАВЬ!
          _buildInputBar(),
        ],
      ),
    );
  }

  // Пустое состояние (когда нет сообщений)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                color: const Color(0xFF2d2d2d),
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 14, 154, 197),
                    Color.fromARGB(255, 8, 124, 187)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to MAI',
            style: GoogleFonts.sourceSerif4(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ask MAI anything to begin',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          // Кнопка меню
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 12),

          // Название модели
          Text(
            'MAI v1.0',
            style: GoogleFonts.sourceSerif4(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          const Spacer(),

          // КНОПКА ПОДПИСОК ← НОВОЕ!
          IconButton(
            icon: const Icon(Icons.workspace_premium,
                color: Color(0xFFFFD700), size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => screens.SubscriptionScreen()),
              );
            },
          ),

          const SizedBox(width: 8),

          // Иконка профиля
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF2d2d2d),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person_outline,
                color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }

// Список сообщений
  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

// Пузырь сообщения
  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Сам пузырь
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF2d2d2d)
                    : const Color(0xFF2d2d2d).withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: message.isUser
                    ? Border.all(
                        color: const Color(0xFFCC785C).withOpacity(0.3))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Текст сообщения
                  Text(
                    message.text,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),

                  // Кнопка "Редактировать" для сообщений из OCR
                  if (message.isUser && message.isFromOCR) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _editMessage(message),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC785C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFCC785C).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: Color(0xFFCC785C),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Редактировать',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFFCC785C),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Время
            const SizedBox(height: 4),
            Text(
              _formatTime(message.dateTime),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

// Индикатор загрузки
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFCC785C),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'MAI думает...',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

// Редактировать сообщение
  Future<void> _editMessage(ChatMessage message) async {
    final controller = TextEditingController(text: message.text);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF2d2d2d),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                children: [
                  const Icon(Icons.edit, color: Color(0xFFCC785C)),
                  const SizedBox(width: 12),
                  Text(
                    'Редактирование',
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Поле редактирования
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1a1a),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Введите текст...',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Кнопки
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Отмена',
                      style: GoogleFonts.inter(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, controller.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCC785C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Сохранить',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null && result.isNotEmpty && result != message.text) {
      setState(() {
        message.text = result;

        // Удаляем старый ответ AI (если есть следующее сообщение)
        final index = _messages.indexOf(message);
        if (index != -1 && index + 1 < _messages.length) {
          if (!_messages[index + 1].isUser) {
            _messages.removeAt(index + 1);
          }
        }
      });

      // Отправляем отредактированное сообщение заново
      await _sendMessage(customText: result);
    }
  }

  // Показать меню вложений (камера, галерея, файл)
  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2d2d2d),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _buildAttachmentOption(
              icon: Icons.camera_alt,
              label: 'Камера',
              onTap: () {
                Navigator.pop(context);
                _openCamera();
              },
            ),
            _buildAttachmentOption(
              icon: Icons.photo_library,
              label: 'Галерея',
              onTap: () {
                Navigator.pop(context);
                _openGallery();
              },
            ),
            _buildAttachmentOption(
              icon: Icons.insert_drive_file,
              label: 'Файл',
              onTap: () {
                Navigator.pop(context);
                _openFilePicker();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF3d3d3d),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white70),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCamera() async {
    // TODO: Интегрировать реальный OCR
    // Временная заглушка с распознанным текстом:
    const recognizedText = '2x + 5 = 13';

    // Отправляем с пометкой isFromOCR = true
    await _sendMessage(customText: recognizedText, isFromOCR: true);
  }

// Галерея
  void _openGallery() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Галерея в разработке')),
    );
  }

// Файлы
  void _openFilePicker() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Выбор файла в разработке')),
    );
  }

// Голосовой ввод
  void _startVoiceInput() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Голосовой ввод в разработке')),
    );
  }

// Отправить сообщение
  Future<void> _sendMessage(
      {String? customText, bool isFromOCR = false}) async {
    final text = customText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    // Проверяем подписку и лимиты
    final subscription = await _subscriptionService.getSubscription();

    if (!await _subscriptionService.canMakeQuery()) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Достигнут лимит запросов (${subscription.dailyQueriesUsed}/${_subscriptionService.getDailyLimit(subscription.tier)}). '
            'Обновите подписку!',
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Подписка',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const screens.SubscriptionScreen()),
              );
            },
          ),
        ),
      );
      return;
    }

    // Добавляем сообщение пользователя
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        isFromOCR: isFromOCR,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();

    try {
      // Отправляем в AI
      final solution = await _apiService.solveProblem(text);

      if (!mounted) return;

      setState(() {
        _messages.add(ChatMessage(
          text: solution.solution,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      // Сохраняем в историю
      await _historyService.addToHistory(text, solution.solution);

      // Обновляем счётчик запросов
      await _subscriptionService.incrementQueryCount();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add(ChatMessage(
          text: 'Ошибка: ${e.toString()}',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

// Поле ввода внизу
  Widget _buildInputBar() {
    // Проверяем есть ли текст
    final hasText = _messageController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF1a1a1a),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // РЯД 1: Поле ввода
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2d2d2d),
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextField(
                controller: _messageController,
                onChanged: (value) =>
                    setState(() {}), // ← Обновляем UI при вводе
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: 'Chat with MAI...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 15,
                  ),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: 5,
                minLines: 1,
              ),
            ),

            const SizedBox(height: 12),

            // РЯД 2: Кнопки
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  // Кнопка плюс (слева) - показываем только если НЕТ текста
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2d2d2d),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add,
                          color: Colors.white70, size: 24),
                      padding: EdgeInsets.zero,
                      onPressed: _showAttachmentMenu,
                    ),
                  ),

                  const Spacer(),

                  // Кнопки справа
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Если НЕТ текста - показываем микрофон
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2d2d2d),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.mic_none,
                              color: Colors.white70, size: 24),
                          padding: EdgeInsets.zero,
                          onPressed: _startVoiceInput,
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Если ЕСТЬ текст - показываем кнопку отправки, иначе - волны
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: hasText
                              ? LinearGradient(
                                  colors: [
                                    const Color.fromARGB(255, 63, 160, 212),
                                    const Color.fromARGB(255, 92, 120, 204)
                                        .withOpacity(0.7),
                                  ],
                                )
                              : null,
                          color: hasText ? null : const Color(0xFF2d2d2d),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: IconButton(
                          icon: Icon(
                            hasText ? Icons.arrow_upward : Icons.graphic_eq,
                            color: Colors.white,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: hasText ? _sendMessage : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Боковое меню
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1a1a1a),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с кнопкой подписок
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MAI',
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  // КНОПКА ПОДПИСОК
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.workspace_premium,
                          color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context); // Закрываем drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  screens.SubscriptionScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Новый чат
            _buildMenuItem(
              icon: Icons.add_comment_outlined,
              label: 'New chat',
              color: const Color.fromARGB(223, 68, 118, 185),
              onTap: () {},
            ),

            const SizedBox(height: 8),

            // Чаты
            _buildMenuItem(
              icon: Icons.chat_bubble_outline,
              label: 'Chats',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HistoryScreen()),
                );
              },
            ),

            // Проекты
            _buildMenuItem(
              icon: Icons.folder_outlined,
              label: 'Projects',
              onTap: () {},
            ),

            // Artifacts
            _buildMenuItem(
              icon: Icons.grid_view_outlined,
              label: 'Artifacts',
              onTap: () {},
            ),

            _buildAITrainerMenuItem(),

            const SizedBox(height: 24),

            // Recents
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Recents',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // История чатов
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildHistoryItem('Решение уравнений'),
                  _buildHistoryItem('Производная функции'),
                  _buildHistoryItem('Интегралы'),
                ],
              ),
            ),

            // Профиль внизу
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2d2d2d),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'M',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Muhammad',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        color: Colors.white70),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAITrainerDialog() async {
    // Проверяем подписку
    final subscription = await SubscriptionService().getSubscription();
    final isPremium = subscription.tier == SubscriptionTier.premium;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2d2d2d),
                Color(0xFF1a1a1a),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFCC785C).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок с иконкой
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFCC785C),
                            const Color(0xFFCC785C).withOpacity(0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '🤖 AI Тренер',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Персональный помощник для обучения',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),

              // Особенности
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildFeatureItem('📊', 'Анализирует твои ошибки'),
                    _buildFeatureItem('📚', 'Составляет план обучения'),
                    _buildFeatureItem('💡', 'Даёт персональные советы'),
                    _buildFeatureItem('🎯', 'Отслеживает прогресс'),
                    _buildFeatureItem('🔥', 'Мотивирует и поддерживает'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Кнопка действия
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: isPremium
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCC785C),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Начать тренировку',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Открыть экран подписок
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const screens.SubscriptionScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: Color(0xFFFFD700),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.workspace_premium,
                                color: Color(0xFFFFD700)),
                            const SizedBox(width: 8),
                            Text(
                              'Получить Premium',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAITrainerMenuItem() {
    return InkWell(
      onTap: () => _showAITrainerDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFCC785C).withOpacity(0.1),
              const Color(0xFFCC785C).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFCC785C),
                    const Color(0xFFCC785C).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child:
                  const Icon(Icons.psychology, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'AI Тренер',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'Premium',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.white70, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: color ?? Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String title) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white70,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
