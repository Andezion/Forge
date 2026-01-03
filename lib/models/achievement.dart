import 'package:flutter/material.dart';

enum AchievementCategory { workouts, strength, consistency, social, special }

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementCategory category;
  final int requiredValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.requiredValue,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
  });

  double get progressPercentage {
    if (isUnlocked) return 1.0;
    return (currentProgress / requiredValue).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'requiredValue': requiredValue,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'currentProgress': currentProgress,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: Icons.emoji_events, // Default icon
      color: Colors.amber, // Default color
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AchievementCategory.special,
      ),
      requiredValue: json['requiredValue'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      currentProgress: json['currentProgress'] ?? 0,
    );
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    AchievementCategory? category,
    int? requiredValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentProgress,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      requiredValue: requiredValue ?? this.requiredValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }
}

// Predefined achievements
class Achievements {
  static List<Achievement> getAll() {
    return [
      // Workout achievements
      Achievement(
        id: 'first_workout',
        title: 'First Steps',
        description: 'Complete your first workout',
        icon: Icons.fitness_center,
        color: Colors.green,
        category: AchievementCategory.workouts,
        requiredValue: 1,
      ),
      Achievement(
        id: 'workout_10',
        title: 'Getting Started',
        description: 'Complete 10 workouts',
        icon: Icons.fitness_center,
        color: Colors.blue,
        category: AchievementCategory.workouts,
        requiredValue: 10,
      ),
      Achievement(
        id: 'workout_50',
        title: 'Dedicated',
        description: 'Complete 50 workouts',
        icon: Icons.fitness_center,
        color: Colors.purple,
        category: AchievementCategory.workouts,
        requiredValue: 50,
      ),
      Achievement(
        id: 'workout_100',
        title: 'Century',
        description: 'Complete 100 workouts',
        icon: Icons.emoji_events,
        color: Colors.amber,
        category: AchievementCategory.workouts,
        requiredValue: 100,
      ),
      Achievement(
        id: 'workout_500',
        title: 'Legend',
        description: 'Complete 500 workouts',
        icon: Icons.emoji_events,
        color: Colors.deepOrange,
        category: AchievementCategory.workouts,
        requiredValue: 500,
      ),

      // Strength achievements
      Achievement(
        id: 'total_weight_1000',
        title: 'Lightweight',
        description: 'Lift 1,000 kg total',
        icon: Icons.fitness_center,
        color: Colors.green,
        category: AchievementCategory.strength,
        requiredValue: 1000,
      ),
      Achievement(
        id: 'total_weight_10000',
        title: 'Heavy Lifter',
        description: 'Lift 10,000 kg total',
        icon: Icons.fitness_center,
        color: Colors.blue,
        category: AchievementCategory.strength,
        requiredValue: 10000,
      ),
      Achievement(
        id: 'total_weight_100000',
        title: 'Iron Warrior',
        description: 'Lift 100,000 kg total',
        icon: Icons.fitness_center,
        color: Colors.purple,
        category: AchievementCategory.strength,
        requiredValue: 100000,
      ),
      Achievement(
        id: 'wilks_300',
        title: 'Strong',
        description: 'Reach 300 Wilks coefficient',
        icon: Icons.trending_up,
        color: Colors.orange,
        category: AchievementCategory.strength,
        requiredValue: 300,
      ),
      Achievement(
        id: 'wilks_400',
        title: 'Elite Strength',
        description: 'Reach 400 Wilks coefficient',
        icon: Icons.emoji_events,
        color: Colors.amber,
        category: AchievementCategory.strength,
        requiredValue: 400,
      ),

      // Consistency achievements
      Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Train 7 days in a row',
        icon: Icons.local_fire_department,
        color: Colors.orange,
        category: AchievementCategory.consistency,
        requiredValue: 7,
      ),
      Achievement(
        id: 'streak_30',
        title: 'Monthly Master',
        description: 'Train 30 days in a row',
        icon: Icons.local_fire_department,
        color: Colors.deepOrange,
        category: AchievementCategory.consistency,
        requiredValue: 30,
      ),
      Achievement(
        id: 'streak_100',
        title: 'Unstoppable',
        description: 'Train 100 days in a row',
        icon: Icons.local_fire_department,
        color: Colors.red,
        category: AchievementCategory.consistency,
        requiredValue: 100,
      ),
      Achievement(
        id: 'early_bird',
        title: 'Early Bird',
        description: 'Complete 10 workouts before 8 AM',
        icon: Icons.wb_sunny,
        color: Colors.yellow,
        category: AchievementCategory.consistency,
        requiredValue: 10,
      ),
      Achievement(
        id: 'night_owl',
        title: 'Night Owl',
        description: 'Complete 10 workouts after 8 PM',
        icon: Icons.nightlight_round,
        color: Colors.indigo,
        category: AchievementCategory.consistency,
        requiredValue: 10,
      ),

      // Social achievements
      Achievement(
        id: 'first_friend',
        title: 'Social',
        description: 'Add your first friend',
        icon: Icons.people,
        color: Colors.blue,
        category: AchievementCategory.social,
        requiredValue: 1,
      ),
      Achievement(
        id: 'friends_10',
        title: 'Popular',
        description: 'Have 10 friends',
        icon: Icons.people,
        color: Colors.purple,
        category: AchievementCategory.social,
        requiredValue: 10,
      ),
      Achievement(
        id: 'challenge_winner',
        title: 'Champion',
        description: 'Win your first challenge',
        icon: Icons.emoji_events,
        color: Colors.amber,
        category: AchievementCategory.social,
        requiredValue: 1,
      ),
      Achievement(
        id: 'challenge_5',
        title: 'Competitor',
        description: 'Complete 5 challenges',
        icon: Icons.emoji_events,
        color: Colors.deepOrange,
        category: AchievementCategory.social,
        requiredValue: 5,
      ),

      // Special achievements
      Achievement(
        id: 'new_year',
        title: 'New Year, New Me',
        description: 'Train on New Year\'s Day',
        icon: Icons.celebration,
        color: Colors.pink,
        category: AchievementCategory.special,
        requiredValue: 1,
      ),
      Achievement(
        id: 'birthday',
        title: 'Birthday Gains',
        description: 'Train on your birthday',
        icon: Icons.cake,
        color: Colors.pink,
        category: AchievementCategory.special,
        requiredValue: 1,
      ),
      Achievement(
        id: 'perfect_week',
        title: 'Perfect Week',
        description: 'Complete all planned workouts in a week',
        icon: Icons.star,
        color: Colors.amber,
        category: AchievementCategory.special,
        requiredValue: 1,
      ),
    ];
  }
}
