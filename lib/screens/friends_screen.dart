import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          AppStrings.friends,
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              // TODO: Show add friend dialog
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '${AppStrings.search}...',
                hintStyle: AppTextStyles.body2,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildFriendCard(
                  'Friend ${index + 1}',
                  'Last workout: ${index + 1} day(s) ago',
                  '${70 + index * 5} kg',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(String name, String lastWorkout, String weight) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(
            Icons.person,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        title: Text(name,
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(lastWorkout, style: AppTextStyles.caption),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.fitness_center,
                    size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('Weight: $weight', style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // TODO: Show friend options
          },
        ),
        onTap: () {
          // TODO: Navigate to friend profile
        },
      ),
    );
  }
}
