import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/subscription_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _subscriptionService = SubscriptionService();
  SubscriptionTier _currentTier = SubscriptionTier.free;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    final subscription = await _subscriptionService.getSubscription();
    setState(() {
      _currentTier = subscription.tier;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Подписки',
          style: GoogleFonts.sourceSerif4(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFCC785C)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  Text(
                    'Выберите план',
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Получите больше возможностей с MAI',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Free Plan
                  _buildTierCard(
                    tier: SubscriptionTier.free,
                    name: 'Free',
                    price: 'Бесплатно',
                    features: [
                      '10 запросов в день',
                      'Базовая модель AI',
                      'История запросов',
                      'OCR распознавание',
                    ],
                    color: const Color(0xFF2d2d2d),
                  ),

                  const SizedBox(height: 16),

                  // Pro Plan
                  _buildTierCard(
                    tier: SubscriptionTier.pro,
                    name: 'Pro',
                    price: '299₽/мес',
                    features: [
                      '100 запросов в день',
                      'Продвинутая модель AI',
                      'Приоритетная поддержка',
                      'Без рекламы',
                    ],
                    color: const Color(0xFF667eea),
                    isPopular: true,
                  ),

                  const SizedBox(height: 16),

                  // Premium Plan
                  _buildTierCard(
                    tier: SubscriptionTier.premium,
                    name: 'Premium',
                    price: '599₽/мес',
                    features: [
                      'Безлимитные запросы',
                      'Лучшая модель AI',
                      'AI Тренер',
                      'Эксклюзивные функции',
                    ],
                    color: const Color(0xFFFFD700),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Информация
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2d2d2d),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Color(0xFFCC785C)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Подписку можно отменить в любое время',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
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

  Widget _buildTierCard({
    required SubscriptionTier tier,
    required String name,
    required String price,
    required List<String> features,
    required Color color,
    Gradient? gradient,
    bool isPopular = false,
  }) {
    final bool isActive = _currentTier == tier;

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? color : null,
        borderRadius: BorderRadius.circular(20),
        border: isActive
            ? Border.all(color: const Color(0xFFCC785C), width: 3)
            : null,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название и бэйдж
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: gradient != null ? Colors.black : Colors.white,
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC785C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Активно',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Цена
                Text(
                  price,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: gradient != null ? Colors.black : Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Особенности
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: gradient != null
                                ? Colors.black
                                : const Color(0xFFCC785C),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: gradient != null
                                    ? Colors.black87
                                    : Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 16),

                // Кнопка
                if (!isActive)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleSubscribe(tier),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gradient != null
                            ? Colors.black
                            : const Color(0xFFCC785C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        tier == SubscriptionTier.free ? 'Выбрать' : 'Оформить',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Бэйдж "Популярно"
          if (isPopular)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🔥 Популярно',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleSubscribe(SubscriptionTier tier) async {
    if (tier == SubscriptionTier.free) {
      // Бесплатный план — просто активируем
      await _subscriptionService.grantSubscription(tier: tier);
      _loadSubscription();
      _showSuccess('Переключено на Free план');
      return;
    }

    // Платные планы — показываем заглушку
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2d2d2d),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Оплата',
          style: GoogleFonts.sourceSerif4(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.payment,
              size: 64,
              color: Color(0xFFCC785C),
            ),
            const SizedBox(height: 16),
            Text(
              'Интеграция с платёжной системой в разработке',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Закрыть',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFCC785C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
