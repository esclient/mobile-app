import 'package:flutter/material.dart';
import '../components/interactive_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Logo section (можно добавить ваш логотип)
              SvgIcon(
                assetPath: 'lib/icons/logo.svg',
                size: 80,
                color: const Color(0xFF388E3C),
              ),
              const SizedBox(height: 40),

              // Login form
              Column(
                spacing: 20,
                children: [
                  // Username field
                  _buildInputField(
                    controller: _usernameController,
                    focusNode: _usernameFocus,
                    placeholder: 'Username or email',
                    isActive: _isUsernameActive,
                  ),
                  
                  // Password field
                  _buildInputField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    placeholder: 'Password',
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
                      content: Text('Восстановление пароля пока не реализовано'),
                      backgroundColor: Color(0xFF388E3C),
                    ),
                  );
                },
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: Color(0xFF388E3C),
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              // Sign up button
              _buildSignUpButton(),
              const SizedBox(height: 20),
            ],
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: isActive 
            ? const Color(0xFF374151) 
            : const Color(0x7F374151),
        borderRadius: BorderRadius.circular(14),
        border: isActive 
            ? Border.all(color: const Color(0xFF388E3C), width: 1)
            : null,
      ),
      child: Center(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: isPassword,
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
              fontWeight: FontWeight.w600,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onSubmitted: (_) {
            if (!isPassword && _passwordController.text.isEmpty) {
              _passwordFocus.requestFocus();
            } else {
              _handleLogin();
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFF388E3C),
          borderRadius: BorderRadius.circular(14),
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
                  'Log in',
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Регистрация пока не реализована'),
            backgroundColor: Color(0xFF388E3C),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            width: 2,
            color: const Color(0xFF388E3C),
          ),
        ),
        child: const Center(
          child: Text(
            'Sign up',
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

      // Имитируем успешный логин
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Добро пожаловать, ${_usernameController.text}!'),
          backgroundColor: const Color(0xFF388E3C),
        ),
      );

      // Возвращаемся на главную страницу
      Navigator.of(context).pop();
    }
  }
}
