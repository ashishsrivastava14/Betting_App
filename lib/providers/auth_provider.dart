import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../mock_data/mock_users.dart';

/// Holds KYC data collected during registration before OTP verification.
class _PendingKyc {
  final String name;
  final String dob;
  final String location;
  final String? email;
  final String? gender;

  const _PendingKyc({
    required this.name,
    required this.dob,
    required this.location,
    this.email,
    this.gender,
  });
}

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  String? _pendingPhone;
  bool _isLoading = false;
  _PendingKyc? _pendingKyc; // non-null when in registration flow

  UserModel? get currentUser => _currentUser;
  String? get pendingPhone => _pendingPhone;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isRegistering => _pendingKyc != null;

  void sendOtp(String phone) {
    _pendingPhone = phone;
    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () {
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Call this (instead of [sendOtp]) when registering a new user.
  /// Stores KYC data so that [verifyOtp] uses it to create the profile.
  void startRegistration({
    required String phone,
    required String name,
    required String dob,
    required String location,
    String? email,
    String? gender,
  }) {
    _pendingPhone = phone;
    _pendingKyc = _PendingKyc(
      name: name,
      dob: dob,
      location: location,
      email: email,
      gender: gender,
    );
    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () {
      _isLoading = false;
      notifyListeners();
    });
  }

  bool verifyOtp(String otp) {
    if (_pendingPhone == null) return false;

    if (_pendingKyc != null) {
      // ── Registration flow: create brand-new user with KYC data ──
      final kyc = _pendingKyc!;
      final newUser = UserModel(
        id: 'USR${DateTime.now().millisecondsSinceEpoch}',
        name: kyc.name,
        phone: _pendingPhone!,
        dob: kyc.dob,
        location: kyc.location,
        walletBalance: 5000.0,
        kycVerified: true,
        role: 'user',
      );
      mockUsers.add(newUser);
      _currentUser = newUser;
      _pendingKyc = null;
    } else {
      // ── Login flow: find user by phone or create a minimal record ──
      final existingUser = mockUsers.cast<UserModel?>().firstWhere(
        (u) => u!.phone == _pendingPhone,
        orElse: () => null,
      );

      if (existingUser != null) {
        _currentUser = existingUser;
      } else {
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

  /// Call this after any external mutation of the current user's wallet balance
  /// so that all widgets watching AuthProvider rebuild with the updated value.
  void refreshBalance() {
    notifyListeners();
  }
}
