import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mai_app/services/subscription_service.dart';
import 'package:mai_app/theme/mai_theme.dart';
import 'package:path/path.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

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
      backgroundColor: ClaudeColors.primaryDark,
      appBar: AppBar(
        title: Text(
          'Подписки',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ClaudeColors.secondaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Выберите план',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Получите больше от MAI',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildTierCard(SubscriptionTier.free),
                  const SizedBox(height: 16),
                  _buildTierCard(SubscriptionTier.pro),
                  const SizedBox(height: 16),
                  _buildTierCard(SubscriptionTier.premium),
                ],
              ),
            ),
    );
  }

  Widget _buildTierCard(SubscriptionTier tier) {
    final isActive = _currentTier == tier;
    final tierName = _subscriptionService.getTierName(tier);
    final tierPrice = _subscriptionService.getTierPrice(tier);
    final features = _subscriptionService.getTierFeatures(tier);

    Color cardColor;
    Color accentColor;

    switch (tier) {
      case SubscriptionTier.free:
        cardColor = ClaudeColors.secondaryDark;
        accentColor = Colors.grey;
        break;
      case SubscriptionTier.pro:
        cardColor = ClaudeColors.secondaryDark;
        accentColor = const Color(0xFF667eea);
        break;
      case SubscriptionTier.premium:
        cardColor = ClaudeColors.secondaryDark;
        accentColor = const Color(0xFFFFD700);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? accentColor : Colors.white12,
          width: isActive ? 3 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Название и бэйдж
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: tier == SubscriptionTier.premium
                        ? const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          )
                        : null,
                    color:
                        tier != SubscriptionTier.premium ? accentColor : null,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tierName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                if (isActive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Активно',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Цена
            Text(
              tierPrice,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
                        color: accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 20),

            // Кнопка
            if (!isActive)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _handleSubscribe(tier),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    tier == SubscriptionTier.free
                        ? 'Вернуться к Free'
                        : 'Выбрать',
                    style: GoogleFonts.poppins(
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
    );
  }

  Future<void> _handleSubscribe(SubscriptionTier tier) async {
    if (tier == SubscriptionTier.free) {
      await _subscriptionService.grantSubscription(tier: tier);
      _loadSubscription();
      _showSuccess('Переведено на Free план');
      return;
    }

    // Показываем диалог подтверждения
    final confirmed = await showDialog<bool>(
      context: context as BuildContext,
      builder: (context) => AlertDialog(
        backgroundColor: ClaudeColors.secondaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Покупка подписки',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Вы выбрали: ${_subscriptionService.getTierName(tier)}',
              style: GoogleFonts.roboto(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _subscriptionService.getTierPrice(tier),
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Безопасная оплата через Stripe',
                      style: GoogleFonts.roboto(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Отмена',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Оплатить',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _processStripePayment(tier);
    }
  }

// ДОБАВЬ ЭТОТ НОВЫЙ МЕТОД:
  Future<void> _processStripePayment(SubscriptionTier tier) async {
    try {
      // Показываем индикатор загрузки
      showDialog(
        context: context as BuildContext,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ClaudeColors.secondaryDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF667eea)),
                SizedBox(height: 16),
                Text(
                  'Обработка платежа...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );

      // 1. Создаём Payment Intent на Backend
      final response = await http.post(
        Uri.parse(
            'https://mai-backend-e4hg.onrender.com/api/Stripe/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tier': tier == SubscriptionTier.pro ? 'pro' : 'premium',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка создания платежа');
      }

      final data = jsonDecode(response.body);
      final clientSecret = data['clientSecret'];

      // 2. Инициализируем Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'MAI Math AI',
          style: ThemeMode.dark,
        ),
      );

      // Закрываем индикатор загрузки
      Navigator.pop(context as BuildContext);

      // 3. Показываем Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Платёж успешен — активируем подписку
      await _subscriptionService.purchaseSubscription(
        tier: tier,
        durationDays: 30,
      );

      _loadSubscription();
      _showSuccess(
          '🎉 Подписка ${_subscriptionService.getTierName(tier)} активирована!');

      // ignore: unrelated_type_equality_checks
      if (confirmed == true) {
        await _subscriptionService.purchaseSubscription(
          tier: tier,
          durationDays: 30,
        );

        _loadSubscription();
        _showSuccess(
            'Подписка ${_subscriptionService.getTierName(tier)} активирована! ✨');
      }
    } on StripeException catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context as BuildContext); // Закрываем загрузку

      if (e.error.code == FailureCode.Canceled) {
        // Пользователь отменил
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(
            content: Text('Платёж отменён'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.error.message ?? "Неизвестная ошибка"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context as BuildContext); // Закрываем загрузку

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Показываем диалог оплаты
  Future<bool?> get confirmed async => await showDialog<bool>(
        context: context as BuildContext,
        builder: (context) => AlertDialog(
          backgroundColor: ClaudeColors.secondaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Покупка подписки',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Вы выбрали: ${_subscriptionService.getTierName(tier!)}',
                style: GoogleFonts.roboto(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _subscriptionService.getTierPrice(tier!),
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Это демо версия\nРеальная оплата не работает',
                        style: GoogleFonts.roboto(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Отмена',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Купить (Демо)',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  SubscriptionTier? get tier => null;
}

void _showSuccess(String message) {
  ScaffoldMessenger.of(context as BuildContext).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.green[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}
