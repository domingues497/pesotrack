import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../services/profile_service.dart';

final profileServiceProvider = Provider<ProfileService>(
  (ref) => const ProfileService(),
);

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(ref.read(profileServiceProvider)),
);

class ProfileState {
  const ProfileState({
    required this.isLoading,
    this.profile,
  });

  final bool isLoading;
  final UserProfile? profile;

  bool get hasProfile => profile != null;
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this._profileService)
      : super(const ProfileState(isLoading: true)) {
    unawaited(_loadProfile());
  }

  final ProfileService _profileService;

  Future<void> _loadProfile() async {
    final profile = await _profileService.loadProfile();
    state = ProfileState(
      isLoading: false,
      profile: profile,
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    state = ProfileState(
      isLoading: false,
      profile: profile,
    );
    await _profileService.saveProfile(profile);
  }

  Future<void> startNewGoal({
    required double startWeight,
    required double targetWeight,
    required DateTime startDate,
    required DateTime targetDate,
    required GoalStrategy strategy,
  }) async {
    final profile = state.profile;
    if (profile == null) {
      return;
    }

    final updatedProfile = profile.startNewGoal(
      startWeight: startWeight,
      targetWeight: targetWeight,
      startDate: startDate,
      targetDate: targetDate,
      strategy: strategy,
    );

    state = ProfileState(
      isLoading: false,
      profile: updatedProfile,
    );
    await _profileService.saveProfile(updatedProfile);
  }

  Future<void> endActiveGoal(GoalStatus status) async {
    final profile = state.profile;
    if (profile == null) {
      return;
    }

    final updatedProfile = profile.endActiveGoal(status);
    state = ProfileState(
      isLoading: false,
      profile: updatedProfile,
    );
    await _profileService.saveProfile(updatedProfile);
  }

  Future<void> clearProfile() async {
    state = const ProfileState(isLoading: false);
    await _profileService.clearProfile();
  }
}
