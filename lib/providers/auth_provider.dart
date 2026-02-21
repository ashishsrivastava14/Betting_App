import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../mock_data/mock_users.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  String? _pendingPhone;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  String? get pendingPhone => _pendingPhone;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';

  void sendOtp(String phone) {
    _pendingPhone = phone;
    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () {
      _isLoading = false;
      notifyListeners();
    });
  }

  bool verifyOtp(String otp) {
    if (_pendingPhone == null) return false;

    // Find user by phone or create a new one
    final existingUser = mockUsers.cast<UserModel?>().firstWhere(
      (u) => u!.phone == _pendingPhone,
      orElse: () => null,
    );

    if (existingUser != null) {
      _currentUser = existingUser;
    } else {
      // Create new user for unknown phones
      final newUser = UserModel(
        id: 'USR${DateTime.now().millisecondsSinceEpoch}',
        name: 'New User',
        phone: _pendingPhone!,
        dob: '2000-01-01',
        location: 'India',
        walletBalance: 5000.0,
        kycVerified: false,
        role: 'user',
      );
      mockUsers.add(newUser);
      _currentUser = newUser;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _pendingPhone = null;
    notifyListeners();
  }
}
