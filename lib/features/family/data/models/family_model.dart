class FamilyMemberModel {
  final String userId;
  final String fullName;
  final String email;
  final String role; // 'owner' | 'member'
  final DateTime? joinedAt;
  final String? avatarUrl;

  const FamilyMemberModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    this.joinedAt,
    this.avatarUrl,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'member',
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'] as String)
          : null,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'role': role,
      'joined_at': joinedAt?.toIso8601String(),
      'avatar_url': avatarUrl,
    };
  }
}

class FamilyModel {
  final String id;
  final String name;
  final String ownerId;
  final String inviteCode;
  final List<FamilyMemberModel> members;
  final DateTime? createdAt;
  final int maxMembers;

  const FamilyModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.inviteCode,
    this.members = const [],
    this.createdAt,
    this.maxMembers = 6,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    final membersList = (json['members'] as List<dynamic>?) ?? [];
    return FamilyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['owner_id'] as String,
      inviteCode: json['invite_code'] as String,
      members: membersList
          .map((e) => FamilyMemberModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      maxMembers: json['max_members'] as int? ?? 6,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner_id': ownerId,
      'invite_code': inviteCode,
      'members': members.map((e) => e.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'max_members': maxMembers,
    };
  }

  bool get isFull => members.length >= maxMembers;
  int get memberCount => members.length;
  bool isOwner(String userId) => ownerId == userId;
}
