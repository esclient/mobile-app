import 'package:flutter/material.dart';

import '../components/interactive_widgets.dart';
import '../services/auth_service.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  final AuthService authService;

  const LoginPage({super.key, required this.authService});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _isLoading = false;
  bool _isUsernameActive = false;
  bool _isPasswordActive = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _usernameFocus.addListener(() {
      setState(() {
        _isUsernameActive = _usernameFocus.hasFocus;
      });
    });
    _passwordFocus.addListener(() {
      setState(() {
        _isPasswordActive = _passwordFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1F2937),
        body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Back button
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Возвращаемся к главному меню, минуя все промежуточные экраны
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(
                                top: 10,
                                bottom: 10,
                                right: 10,
                              ),
                              child: SvgIcon(
                                assetPath: 'lib/icons/return.svg',
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),

                      // Flexible spacer
                      const Spacer(),

                      // Logo section
                      const SvgIcon(
                        assetPath: 'lib/icons/logo.svg',
                        size: 80,
                        color: Color.fromRGBO(121, 121, 121, 1),
                      ),
                      const SizedBox(height: 40),

                      // Login form
                      Column(
                        children: [
                          // Username field
                          _buildInputField(
                            controller: _usernameController,
                            focusNode: _usernameFocus,
                            placeholder: 'Логин или почта',
                            isActive: _isUsernameActive,
                          ),
                          const SizedBox(height: 16),

                          // Password field
                          _buildInputField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            placeholder: 'Пароль',
                            isActive: _isPasswordActive,
                            isPassword: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Login button
                      _buildLoginButton(),
                      const SizedBox(height: 15),

                      // Forgot password
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Восстановление пароля пока не реализовано',
                              ),
                              backgroundColor: Color(0xFF388E3C),
                            ),
                          );
                        },
                        child: const Text(
                          'Забыли пароль?',
                          style: TextStyle(
                            color: Color(0xFF388E3C),
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Flexible spacer
                      const Spacer(),

                      // Sign up button
                      _buildSignUpButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String placeholder,
    required bool isActive,
    bool isPassword = false,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword && !_isPasswordVisible,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(
            color: Color(0xBF9B9B9B),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
          suffixIcon: isPassword
              ? AnimatedOpacity(
                  opacity: isActive ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: isActive
                        ? () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          }
                        : null,
                    child: Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(10.0),
                      child: SvgIcon(
                        assetPath: 'lib/icons/login/hide_show_toggle.svg',
                        size: 22,
                        color: _isPasswordVisible
                            ? const Color(0xFF388E3C)
                            : const Color(0xFF374151),
                      ),
                    ),
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF374151), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF374151), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF388E3C), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          fillColor: Colors.transparent,
          filled: true,
        ),
        onSubmitted: (_) {
          if (!isPassword && _passwordController.text.isEmpty) {
            _passwordFocus.requestFocus();
          } else {
            _handleLogin();
          }
        },
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF388E3C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Войти',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpPage(authService: widget.authService),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 2, color: const Color(0xFF388E3C)),
        ),
        child: const Center(
          child: Text(
            'Зарегистрироваться',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, заполните все поля'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Имитируем запрос к серверу
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Авторизуем пользователя
      widget.authService.login(_usernameController.text);

      // Показываем сообщение об успехе
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Добро пожаловать, ${_usernameController.text}!'),
          backgroundColor: const Color(0xFF388E3C),
        ),
      );

      // Возвращаемся к главному меню
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
