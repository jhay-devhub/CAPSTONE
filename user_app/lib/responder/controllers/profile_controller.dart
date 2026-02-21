import 'package:flutter/foundation.dart';
import '../models/user_profile_model.dart';

/// Manages the current user's profile data and settings state.
class ProfileController extends ChangeNotifier {
  ProfileController() {
    _loadProfile();
  }

  // ── State ─────────────────────────────────────────────────────────────────
  UserProfileModel _profile = UserProfileModel.empty;
  bool _notificationsEnabled = true;
  bool _locationAccessEnabled = true;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfileModel get profile => _profile;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get locationAccessEnabled => _locationAccessEnabled;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Public actions ─────────────────────────────────────────────────────────

  void toggleNotifications({required bool value}) {
    _notificationsEnabled = value;
    // TODO: Persist to shared_preferences
    notifyListeners();
  }

  void toggleLocationAccess({required bool value}) {
    _locationAccessEnabled = value;
    // TODO: Persist to shared_preferences
    notifyListeners();
  }

  Future<void> updateProfile(UserProfileModel updated) async {
    try {
      // TODO: Send to backend / local storage
      _profile = updated;
      notifyListeners();
    } catch (e) {
      debugPrint('[ProfileController] updateProfile error: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Load from local storage / backend
      await Future<void>.delayed(const Duration(milliseconds: 200));
      _profile = const UserProfileModel(
        id: 'user_001',
        fullName: 'Name Surname',
        phoneNumber: '+63 912 345 6789',
        email: 'name@example.com',
      );
    } catch (e) {
      debugPrint('[ProfileController] _loadProfile error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
