# Leaderboard System Documentation

## Overview
The leaderboard system allows users to compete with each other based on various fitness metrics. Data is stored in Firebase Firestore for real-time synchronization across devices.

## Firebase Data Structure

### Collection: `user_stats`
Each document represents a user's aggregated statistics.

```json
{
  "userId": "string",
  "displayName": "string",
  "workoutCount": number,
  "totalWeightLifted": number,
  "currentStreak": number,
  "lastWorkoutDate": timestamp,
  "exerciseRecords": {
    "exerciseId1": number,
    "exerciseId2": number,
    ...
  },
  "isProfileHidden": boolean,
  "updatedAt": timestamp
}
```

### Field Descriptions

- **userId**: Firebase Auth user ID
- **displayName**: User's display name for leaderboards
- **workoutCount**: Total number of completed workouts
- **totalWeightLifted**: Sum of (weight × reps) across all sets
- **currentStreak**: Consecutive days with at least one workout
- **lastWorkoutDate**: Timestamp of most recent workout
- **exerciseRecords**: Map of exercise IDs to maximum weight lifted
- **isProfileHidden**: Whether user is hidden from public leaderboards
- **updatedAt**: Last sync timestamp

## Data Synchronization

### When Stats Are Updated
Statistics are automatically synchronized to Firebase:
1. **After completing a workout** - in `WorkoutExecutionScreen._finishWorkout()`
2. **When changing privacy settings** - in `SettingsService.setProfileHidden()`

### What Gets Calculated
- Workout count: Simple count of completed workouts
- Total weight: Sum of (weight × reps) for all sets
- Streak: Consecutive days with workouts (allows 1 rest day)
- Exercise records: Maximum weight per exercise across all history

## Privacy Controls

Users can hide themselves from leaderboards:
1. Go to Settings → Privacy → "Hide from Leaderboards"
2. When enabled, user's stats are filtered out from queries
3. User can still see their own stats in the app
4. Changing this setting immediately updates Firebase

## Leaderboard Categories

### 1. Workouts
Ranks users by total number of completed workouts.

**Query**: `user_stats` ordered by `workoutCount DESC`

### 2. Total Weight
Ranks users by total weight lifted (weight × reps).

**Query**: `user_stats` ordered by `totalWeightLifted DESC`

### 3. Records
Ranks users by maximum weight for a specific exercise.

**Features**:
- User selects an exercise from dropdown
- Shows only users who have performed that exercise
- Ranks by weight value in `exerciseRecords[exerciseId]`

**Query**: Client-side filtering and sorting of `user_stats` by `exerciseRecords[selectedExerciseId]`

### 4. Streak
Ranks users by current workout streak.

**Query**: `user_stats` ordered by `currentStreak DESC`

**Streak Calculation**:
- Consecutive days with at least one workout
- Allows up to 1 rest day between workouts (difference <= 2)
- Resets if more than 1 rest day

### 5. Progress (Coming Soon)
Will rank users by improvement percentage over time.

## Performance Optimization

### Minimal Data Transfer
Instead of downloading entire user database, we use Firestore queries:
- Only fetch top 100 users per category
- Filter by `isProfileHidden = false` on server side
- Use Firestore indexes for efficient sorting

### Firestore Indexes Required
Create these indexes in Firebase Console:
1. `user_stats` → `isProfileHidden` ASC, `workoutCount` DESC
2. `user_stats` → `isProfileHidden` ASC, `totalWeightLifted` DESC
3. `user_stats` → `isProfileHidden` ASC, `currentStreak` DESC

## Code Architecture

### Services
- **LeaderboardService** (`lib/services/leaderboard_service.dart`)
  - Syncs user stats to Firebase
  - Provides streams for leaderboard queries
  - Calculates statistics from workout history

### Models
- **UserStats** (`lib/models/user_stats.dart`)
  - Data class for Firebase user statistics
  - Includes JSON serialization for Firestore

### UI
- **CommunityLeaderboardScreen** (`lib/screens/community_leaderboard_screen.dart`)
  - 5 tabs for different leaderboard categories
  - Real-time updates via StreamBuilder
  - Exercise selector for Records tab

## Usage Example

```dart
// Get LeaderboardService from Provider
final leaderboardService = Provider.of<LeaderboardService>(context);

// Fetch workouts leaderboard
Stream<List<UserStats>> stream = leaderboardService.getWorkoutCountLeaderboard(
  limit: 100,
  scope: 'Global',
);

// Display in UI
StreamBuilder<List<UserStats>>(
  stream: stream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final users = snapshot.data!;
      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user.displayName),
            subtitle: Text('${user.workoutCount} workouts'),
          );
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

## Future Enhancements

1. **Regional Leaderboards** - Filter by country/city using user location
2. **Friends-Only Leaderboards** - Show only friends from social features
3. **Time-Period Filters** - Weekly/monthly leaderboards instead of all-time
4. **Progress Ranking** - Calculate improvement percentage over time
5. **Badges and Achievements** - Award badges for leaderboard positions
6. **Leaderboard Notifications** - Notify when someone passes your rank

## Testing

To test leaderboards with mock data:
1. Create multiple test accounts in Firebase Auth
2. Complete workouts in each account
3. Verify stats appear correctly in Firestore Console
4. Check leaderboard rankings in the app
5. Test privacy toggle (hide/show profile)

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /user_stats/{userId} {
      // Users can read all non-hidden profiles
      allow read: if resource.data.isProfileHidden == false || request.auth.uid == userId;
      
      // Users can only write their own stats
      allow write: if request.auth.uid == userId;
    }
  }
}
```

## Troubleshooting

### Stats Not Updating
- Check Firebase Auth user is logged in
- Verify Firestore permissions
- Check console for error messages
- Ensure workout history exists locally

### Leaderboard Empty
- Verify other users have completed workouts
- Check Firestore indexes are created
- Confirm privacy settings (not all users hidden)
- Check network connectivity

### Performance Issues
- Limit leaderboard queries to top 100
- Use pagination for large result sets
- Check Firestore quota usage
- Optimize indexes
