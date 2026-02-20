import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mai_app/models/screens/subscription_screen.dart';
import 'package:mai_app/services/subscription_service.dart';

class ClaudeStyleHome extends StatefulWidget {
  const ClaudeStyleHome({super.key});

  @override
  State<ClaudeStyleHome> createState() => _ClaudeStyleHomeState();
}

class _ClaudeStyleHomeState extends State<ClaudeStyleHome> {
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1a1a1a),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(child: _buildEmptyState()),
          _buildInputBar(),
        ],
      ),
    );
  }

  // AppBar как у Claude
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

  // Пустое состояние (когда нет сообщений)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Иконка (как у Claude)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 92, 127, 204),
                  const Color.fromARGB(255, 69, 94, 173).withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 40,
            ),
          ),

          const SizedBox(height: 32),

          // Приветствие
          Text(
            'Добрый день',
            textAlign: TextAlign.center,
            style: GoogleFonts.sourceSerif4(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

// Поле ввода внизу
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: const Color(0xFF1a1a1a), // Цвет фона
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // РЯД 1: Поле ввода
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2d2d2d), // Серый цвет как у кнопок
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 15,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: 'Chat with MAI...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    backgroundColor: const Color(0xFF2d2d2d),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  filled: false,
                  fillColor: const Color(0xFF2d2d2d),
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
              width: double.infinity, // На всю ширину контейнера
              child: Row(
                children: [
                  // Кнопка плюс (слева)
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
                      onPressed: () {},
                    ),
                  ),

                  const Spacer(),

                  // Кнопки справа
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Микрофон
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
                          onPressed: () {},
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Голосовые волны
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2d2d2d),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.graphic_eq,
                              color: Colors.white70, size: 24),
                          padding: EdgeInsets.zero,
                          onPressed: () {},
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
            // Заголовок
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'MAI',
                style: GoogleFonts.sourceSerif4(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            // Новый чат
            _buildMenuItem(
              icon: Icons.add_comment_outlined,
              label: 'New chat',
              color: const Color(0xFFCC785C),
              onTap: () {},
            ),

            const SizedBox(height: 8),

            // Чаты
            _buildMenuItem(
              icon: Icons.chat_bubble_outline,
              label: 'Chats',
              onTap: () {},
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
                          // TODO: Открыть чат с AI Тренером
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCC785C),
                          minimumSize: Size(double.infinity, 56),
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
                              builder: (context) => const SubscriptionScreen(),
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
