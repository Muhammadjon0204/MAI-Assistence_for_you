import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionTier { free, pro, premium }

class Subscription {
  final SubscriptionTier tier;
  final DateTime? expiryDate;
  final int dailyQueriesUsed;
  final DateTime lastQueryReset;

  Subscription({
    required this.tier,
    this.expiryDate,
    required this.dailyQueriesUsed,
    required this.lastQueryReset,
  });
}

class SubscriptionService {
  static const String _tierKey = 'subscription_tier';
  static const String _expiryKey = 'subscription_expiry';
  static const String _queriesKey = 'daily_queries_used';
  static const String _resetKey = 'last_query_reset';

  Future<Subscription> getSubscription() async {
    final prefs = await SharedPreferences.getInstance();

    final tierIndex = prefs.getInt(_tierKey) ?? 0;
    final tier = SubscriptionTier.values[tierIndex];

    final expiryString = prefs.getString(_expiryKey);
    final expiryDate =
        expiryString != null ? DateTime.parse(expiryString) : null;

    final dailyQueriesUsed = prefs.getInt(_queriesKey) ?? 0;

    final resetString = prefs.getString(_resetKey);
    final lastQueryReset =
        resetString != null ? DateTime.parse(resetString) : DateTime.now();

    if (expiryDate != null && DateTime.now().isAfter(expiryDate)) {
      await _setTier(SubscriptionTier.free);
      return Subscription(
        tier: SubscriptionTier.free,
        expiryDate: null,
        dailyQueriesUsed: dailyQueriesUsed,
        lastQueryReset: lastQueryReset,
      );
    }

    return Subscription(
      tier: tier,
      expiryDate: expiryDate,
      dailyQueriesUsed: dailyQueriesUsed,
      lastQueryReset: lastQueryReset,
    );
  }

  int getDailyLimit(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return 10;
      case SubscriptionTier.pro:
        return 100;
      case SubscriptionTier.premium:
        return 999999;
    }
  }

  Future<bool> canMakeQuery() async {
    final subscription = await getSubscription();

    final now = DateTime.now();
    final lastReset = subscription.lastQueryReset;

    if (now.difference(lastReset).inHours >= 24) {
      await _resetDailyQueries();
      return true;
    }

    final limit = getDailyLimit(subscription.tier);
    return subscription.dailyQueriesUsed < limit;
  }

  Future<void> incrementQueryCount() async {
    final prefs = await SharedPreferences.getInstance();
    final subscription = await getSubscription();

    final newCount = subscription.dailyQueriesUsed + 1;
    await prefs.setInt(_queriesKey, newCount);
  }

  Future<void> _resetDailyQueries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_queriesKey, 0);
    await prefs.setString(_resetKey, DateTime.now().toIso8601String());
  }

  Future<void> _setTier(SubscriptionTier tier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tierKey, tier.index);

    if (tier == SubscriptionTier.free) {
      await prefs.remove(_expiryKey);
    }
  }

  Future<void> purchaseSubscription({
    required SubscriptionTier tier,
    required int durationDays,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tierKey, tier.index);

    final expiryDate = DateTime.now().add(Duration(days: durationDays));
    await prefs.setString(_expiryKey, expiryDate.toIso8601String());
  }

  Future<void> grantSubscription({
    required SubscriptionTier tier,
    int? durationDays,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tierKey, tier.index);

    if (durationDays != null) {
      final expiryDate = DateTime.now().add(Duration(days: durationDays));
      await prefs.setString(_expiryKey, expiryDate.toIso8601String());
    } else {
      await prefs.remove(_expiryKey);
    }
  }

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
}
