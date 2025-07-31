import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api;
  String? _loggedInUser;

  AuthProvider({ApiService? apiService}) : _api = apiService ?? ApiService();

  String? get loggedInUser => _loggedInUser;
  bool get isLoggedIn => _loggedInUser != null;

  Future<bool> login(String username, String password) async {
    bool ok = await _api.login(username, password);
    if (ok) {
      _loggedInUser = username;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _loggedInUser = null;
    notifyListeners();
  }
}
