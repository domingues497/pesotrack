import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>(
  (ref) => ProfileNotifier(),
);

class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier()
      : super(
          UserProfile(
            name: 'Rafael',
            initialWeight: 82.5,
            heightCm: 175,
            sex: BiologicalSex.male,
            birthDate: DateTime(1995, 7, 14),
            goalWeight: 75,
          ),
        );
}
