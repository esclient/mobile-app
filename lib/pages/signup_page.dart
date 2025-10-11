import 'package:flutter/material.dart';

import '../components/interactive_widgets.dart';
import '../services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  final AuthService authService;

  const SignUpPage({super.key, required this.authService});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  bool _isLoading = false;
  bool _isEmailActive = false;
  bool _receiveUpdates = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      setState(() {
        _isEmailActive = _emailFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
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
        child: Column(
          children: [
            // Back button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
              child: GestureDetector(
                onTap: () {
                  // Возвращаемся к главному меню, минуя все промежуточные экраны
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: SvgIcon(
                    assetPath: 'lib/icons/return.svg',
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Main content - scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Add top spacing to center content
                    SizedBox(height: MediaQuery.of(context).size.height * 0.15),

                    // Logo section
                    const SvgIcon(
                      assetPath: 'lib/icons/logo.svg',
                      size: 80,
                      color: Color.fromRGBO(121, 121, 121, 1),
                    ),
                    const SizedBox(height: 40),

                    // Form section
                    Column(
                      children: [
                        // Email field
                        _buildInputField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          placeholder: 'Почта',
                          isActive: _isEmailActive,
                        ),
                        const SizedBox(height: 16),

                        // Checkbox section
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _receiveUpdates = !_receiveUpdates;
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Checkbox
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: _receiveUpdates
                                        ? const Color(0xFF388E3C)
                                        : const Color(0xFF797979),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  color: _receiveUpdates
                                      ? const Color(0xFF388E3C)
                                      : Colors.transparent,
                                ),
                                child: _receiveUpdates
                                    ? const Icon(
                                        Icons.check,
                                        size: 18,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),

                              // Text
                              Expanded(
                                child: Text(
                                  'Я хочу получать новости о моих модах на электронную почту',
                                  style: const TextStyle(
                                    color: Color(0xFFBBBBBB),
                                    fontSize: 15,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                    height: 1.33,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Sign up button
                        GestureDetector(
                          onTap: _isLoading ? null : _handleSignUp,
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
                                      'Зарегистрироваться',
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
                        ),

                        // Add spacing before bottom section
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.15,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom log in section - fixed at bottom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: const Color(0xFF388E3C),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Войти',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.emailAddress,
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
        onSubmitted: (_) => _handleSignUp(),
      ),
    );
  }

  void _handleSignUp() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, введите email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Простая проверка формата email
    if (!_emailController.text.contains('@') ||
        !_emailController.text.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, введите корректный email'),
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

      // Регистрируем пользователя
      widget.authService.signup(_emailController.text);

      // Показываем сообщение об успехе
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Регистрация успешна! Добро пожаловать!'),
          backgroundColor: const Color(0xFF388E3C),
          duration: const Duration(seconds: 3),
        ),
      );

      // Возвращаемся к главному меню
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
