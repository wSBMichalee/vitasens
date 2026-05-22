class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final bool onboardingCompleted;
  final String? subscriptionStatus;
  final String? goalType;
  final int? dailyCalorieTarget;
  final int? dailyProteinTarget;
  final int? dailyCarbsTarget;
  final int? dailyFatTarget;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.onboardingCompleted = false,
    this.subscriptionStatus,
    this.goalType,
    this.dailyCalorieTarget,
    this.dailyProteinTarget,
    this.dailyCarbsTarget,
    this.dailyFatTarget,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      onboardingCompleted: (json['onboarding_completed'] as bool?) ?? false,
      subscriptionStatus: json['subscription_status'] as String?,
      goalType: json['goal_type'] as String?,
      dailyCalorieTarget: json['daily_calorie_target'] as int?,
      dailyProteinTarget: json['daily_protein_target'] as int?,
      dailyCarbsTarget: json['daily_carbs_target'] as int?,
      dailyFatTarget: json['daily_fat_target'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'onboarding_completed': onboardingCompleted,
      'subscription_status': subscriptionStatus,
      'goal_type': goalType,
      'daily_calorie_target': dailyCalorieTarget,
      'daily_protein_target': dailyProteinTarget,
      'daily_carbs_target': dailyCarbsTarget,
      'daily_fat_target': dailyFatTarget,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    bool? onboardingCompleted,
    String? subscriptionStatus,
    String? goalType,
    int? dailyCalorieTarget,
    int? dailyProteinTarget,
    int? dailyCarbsTarget,
    int? dailyFatTarget,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      goalType: goalType ?? this.goalType,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      dailyProteinTarget: dailyProteinTarget ?? this.dailyProteinTarget,
      dailyCarbsTarget: dailyCarbsTarget ?? this.dailyCarbsTarget,
      dailyFatTarget: dailyFatTarget ?? this.dailyFatTarget,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserModel(id: $id, email: $email, fullName: $fullName)';
}
