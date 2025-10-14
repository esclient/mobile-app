import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userEmail = '';
  String _userName = '';
  String? _currentUserId; 
  
  bool get isLoggedIn => _isLoggedIn;
  String get userEmail => _userEmail;
  String get userName => _userName;
  String? get currentUserId => _currentUserId; 
  
  // Авторизация пользователя
  void login(String email, {String? username, String? userId}) {
    _isLoggedIn = true;
    _userEmail = email;
    _userName = username ?? email.split('@')[0];
    _currentUserId = userId ?? email; 
    notifyListeners();
  }
  
  // Регистрация пользователя
  void signup(String email, {String? userId}) {
    _isLoggedIn = true;
    _userEmail = email;
    _userName = email.split('@')[0];
    _currentUserId = userId ?? email; // Use email as fallback ID
    notifyListeners();
  }
  
  // Выход из аккаунта
  void logout() {
    _isLoggedIn = false;
    _userEmail = '';
    _userName = '';
    _currentUserId = null;
    notifyListeners();
  }
  
  // Helper method to check if user owns a comment
  bool isCommentOwner(String authorId) {
    return _currentUserId != null && _currentUserId == authorId;
  }
}