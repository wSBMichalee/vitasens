import 'package:vitasense/core/supabase/supabase_client.dart';
import 'package:vitasense/features/subscription/data/models/subscription_model.dart';

class SubscriptionRepository {
  final SupabaseClientService _supabaseService;

  SubscriptionRepository({SupabaseClientService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseClientService.instance;

  Future<SubscriptionModel> getStatus() async {
    final result = await _supabaseService.invokeFunction(
      'manage-subscription',
      body: {'action': 'status'},
    );
    return SubscriptionModel.fromJson(result as Map<String, dynamic>);
  }

  Future<SubscriptionModel> syncSubscription() async {
    final result = await _supabaseService.invokeFunction(
      'manage-subscription',
      body: {'action': 'sync'},
    );
    return SubscriptionModel.fromJson(result as Map<String, dynamic>);
  }

  Future<void> cancelSubscription() async {
    await _supabaseService.invokeFunction(
      'manage-subscription',
      body: {'action': 'cancel'},
    );
  }
}
