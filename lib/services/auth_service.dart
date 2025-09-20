import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userEmail = '';
  String _userName = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userEmail => _userEmail;
  String get userName => _userName;

  // Авторизация пользователя
  void login(String email, {String? username}) {
    _isLoggedIn = true;
    _userEmail = email;
    _userName = username ?? email.split('@')[0]; // Используем часть email как имя по умолчанию
    notifyListeners();
  }

  // Регистрация пользователя
  void signup(String email) {
    _isLoggedIn = true;
    _userEmail = email;
    _userName = email.split('@')[0]; // Используем часть email как имя по умолчанию
    notifyListeners();
  }

  // Выход из аккаунта
  void logout() {
    _isLoggedIn = false;
    _userEmail = '';
    _userName = '';
    notifyListeners();
  }
}
