import 'package:vitasense/core/supabase/supabase_client.dart';
import 'package:vitasense/features/family/data/models/family_model.dart';

class FamilyRepository {
  final SupabaseClientService _supabaseService;

  FamilyRepository({SupabaseClientService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseClientService.instance;

  Future<FamilyModel?> getMyFamily() async {
    try {
      final result = await _supabaseService.invokeFunction(
        'family-invite',
        body: {'action': 'my_family'},
      );
      if (result == null) return null;
      return FamilyModel.fromJson(result as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<FamilyModel> createFamily(String name) async {
    final result = await _supabaseService.invokeFunction(
      'family-invite',
      body: {
        'action': 'create',
        'name': name,
      },
    );
    return FamilyModel.fromJson(result as Map<String, dynamic>);
  }

  Future<FamilyModel> joinFamily(String inviteCode) async {
    final result = await _supabaseService.invokeFunction(
      'family-invite',
      body: {
        'action': 'join',
        'inviteCode': inviteCode,
      },
    );
    return FamilyModel.fromJson(result as Map<String, dynamic>);
  }

  Future<void> leaveFamily() async {
    await _supabaseService.invokeFunction(
      'family-invite',
      body: {'action': 'leave'},
    );
  }

  Future<void> deleteFamily() async {
    await _supabaseService.invokeFunction(
      'family-invite',
      body: {'action': 'delete'},
    );
  }

  Future<List<FamilyMemberModel>> getMembers() async {
    final result = await _supabaseService.invokeFunction(
      'family-invite',
      body: {'action': 'members'},
    );
    if (result == null) return [];
    final List<dynamic> data = result as List<dynamic>;
    return data
        .map((e) => FamilyMemberModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
