import 'package:intl/intl.dart';

/// Model reprezentujący status subskrypcji użytkownika.
/// Pobierany z Edge Function `manage-subscription` (action: 'status').
class SubscriptionModel {
  final String status; // active | expired | trial | cancelled
  final String productId; // com.vitasense.monthly | com.vitasense.yearly
  final DateTime? expiresAt;
  final bool isTrialActive;
  final DateTime? trialEndsAt;
  final bool isFamilyPlan;

  const SubscriptionModel({
    required this.status,
    required this.productId,
    this.expiresAt,
    this.isTrialActive = false,
    this.trialEndsAt,
    this.isFamilyPlan = false,
  });

  // ─── JSON ──────────────────────────────────────────────────────────────────

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      status: json['status'] as String? ?? 'expired',
      productId: json['product_id'] as String? ?? '',
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
      isTrialActive: json['is_trial_active'] as bool? ?? false,
      trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.tryParse(json['trial_ends_at'] as String)
          : null,
      isFamilyPlan: json['is_family_plan'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'product_id': productId,
      'expires_at': expiresAt?.toIso8601String(),
      'is_trial_active': isTrialActive,
      'trial_ends_at': trialEndsAt?.toIso8601String(),
      'is_family_plan': isFamilyPlan,
    };
  }

  // ─── HELPER GETTERS ────────────────────────────────────────────────────────

  /// Subskrypcja jest aktywna (aktywna lub trial)
  bool get isActive => status == 'active' || isTrialActive;

  /// Nazwa planu dla UI
  String get planName =>
      productId.contains('yearly') ? 'Yearly Plan' : 'Monthly Plan';

  /// Wyświetlana cena
  String get priceLabel =>
      productId.contains('yearly') ? '\$59/year' : '\$9.99/month';

  /// Liczba dni pozostałych do wygaśnięcia (0 jeśli brak daty)
  int get daysRemaining =>
      expiresAt?.difference(DateTime.now()).inDays ?? 0;

  /// Liczba dni pozostałych do końca trialu (0 jeśli brak daty)
  int get trialDaysRemaining =>
      trialEndsAt?.difference(DateTime.now()).inDays ?? 0;

  /// Sformatowana data wygaśnięcia (np. "Jan 15, 2026")
  String get expiresAtFormatted => expiresAt != null
      ? DateFormat('MMM d, y').format(expiresAt!)
      : '—';

  /// Etykieta statusu dla UI
  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Active';
      case 'trial':
        return 'Trial';
      case 'expired':
        return 'Expired';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() =>
      'SubscriptionModel(status: $status, productId: $productId, '
      'expiresAt: $expiresAt, isTrialActive: $isTrialActive)';
}
