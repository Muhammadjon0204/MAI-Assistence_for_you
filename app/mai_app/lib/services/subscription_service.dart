import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum SubscriptionTier {
  free,
  pro,
  premium,
}

class Subscription {
  final SubscriptionTier tier;
  final DateTime? expiryDate;
  final bool isLifetime;

  Subscription({
    required this.tier,
    this.expiryDate,
    this.isLifetime = false,
  });

  bool get isActive {
    if (tier == SubscriptionTier.free) return true;
    if (isLifetime) return true;
    if (expiryDate == null) return false;
    return DateTime.now().isBefore(expiryDate!);
  }

  Map<String, dynamic> toJson() => {
        'tier': tier.toString(),
        'expiryDate': expiryDate?.toIso8601String(),
        'isLifetime': isLifetime,
      };

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        tier: SubscriptionTier.values.firstWhere(
          (e) => e.toString() == json['tier'],
          orElse: () => SubscriptionTier.free,
        ),
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'])
            : null,
        isLifetime: json['isLifetime'] ?? false,
      );
}

class SubscriptionService {
  static const String _subscriptionKey = 'mai_subscription';

  // Получить текущую подписку
  Future<Subscription> getSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_subscriptionKey);

    if (jsonString == null) {
      return Subscription(tier: SubscriptionTier.free);
    }

    final sub = Subscription.fromJson(jsonDecode(jsonString));

    // Проверяем активна ли подписка
    if (!sub.isActive && sub.tier != SubscriptionTier.free) {
      // Подписка истекла, возвращаем Free
      await _saveSubscription(Subscription(tier: SubscriptionTier.free));
      return Subscription(tier: SubscriptionTier.free);
    }

    return sub;
  }

  // Сохранить подписку
  Future<void> _saveSubscription(Subscription subscription) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_subscriptionKey, jsonEncode(subscription.toJson()));
  }

  // ADMIN: Дать подписку пользователю (ручной контроль)
  Future<void> grantSubscription({
    required SubscriptionTier tier,
    bool isLifetime = false,
    int? durationDays,
  }) async {
    DateTime? expiryDate;

    if (!isLifetime && durationDays != null) {
      expiryDate = DateTime.now().add(Duration(days: durationDays));
    }

    final subscription = Subscription(
      tier: tier,
      expiryDate: expiryDate,
      isLifetime: isLifetime,
    );

    await _saveSubscription(subscription);
  }

  // Купить подписку (вызывается после успешной оплаты)
  Future<void> purchaseSubscription({
    required SubscriptionTier tier,
    required int durationDays,
  }) async {
    final expiryDate = DateTime.now().add(Duration(days: durationDays));

    final subscription = Subscription(
      tier: tier,
      expiryDate: expiryDate,
      isLifetime: false,
    );

    await _saveSubscription(subscription);
  }

  // Получить лимит запросов
  int getDailyQueryLimit(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return 10;
      case SubscriptionTier.pro:
        return 100;
      case SubscriptionTier.premium:
        return -1; // Unlimited
    }
  }

  // Получить модель AI
  String getAIModel(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return 'gemini-2.0-flash'; // Быстрая модель
      case SubscriptionTier.pro:
        return 'gemini-2.5-flash'; // Лучше
      case SubscriptionTier.premium:
        return 'gemini-2.5-pro'; // Самая точная
    }
  }

  // Получить максимум токенов для ответа
  int getMaxTokens(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return 1000;
      case SubscriptionTier.pro:
        return 2000;
      case SubscriptionTier.premium:
        return 4000;
    }
  }

  // Получить temperature для AI (точность)
  double getTemperature(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return 0.7; // Средняя точность
      case SubscriptionTier.pro:
        return 0.5; // Выше точность
      case SubscriptionTier.premium:
        return 0.3; // Максимальная точность
    }
  }

  // Название тира
  String getTierName(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.pro:
        return 'Pro';
      case SubscriptionTier.premium:
        return 'Premium';
    }
  }

  // Цена тира
  String getTierPrice(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return 'Бесплатно';
      case SubscriptionTier.pro:
        return '299₽/мес';
      case SubscriptionTier.premium:
        return '599₽/мес';
    }
  }

  // Описание тира
  List<String> getTierFeatures(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return [
          '10 запросов в день',
          'Базовая точность',
          'Стандартные объяснения',
        ];
      case SubscriptionTier.pro:
        return [
          '100 запросов в день',
          'Высокая точность (95%)',
          'Подробные объяснения',
          'Без рекламы',
        ];
      case SubscriptionTier.premium:
        return [
          'Неограниченные запросы',
          'Максимальная точность (99%)',
          'AI-тренер',
          'Приоритетная поддержка',
          'Доступ к новым функциям',
        ];
    }
  }
}
