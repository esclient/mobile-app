import 'package:flutter/material.dart';
import '../components/interactive_widgets.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

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
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  children: [
                    // Back button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: SvgIcon(
                            assetPath: 'lib/icons/Return.svg',
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Main content positioned in center
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo section
                          const SvgIcon(
                            assetPath: 'lib/icons/logo.svg',
                            size: 80,
                            color: Color.fromRGBO(121, 121, 121, 1),
                          ),
                          const SizedBox(height: 40),

                          // Form section
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Email field section
                              Container(
                                height: 124,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Email input
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Container(
                                        width: double.infinity,
                                        height: 54,
                                        padding: const EdgeInsets.symmetric(horizontal: 15),
                                        decoration: BoxDecoration(
                                          color: _isEmailActive 
                                              ? const Color(0xFF374151) 
                                              : const Color(0x7F374151),
                                          borderRadius: BorderRadius.circular(14),
                                          border: _isEmailActive 
                                              ? Border.all(color: const Color(0xFF388E3C), width: 1)
                                              : null,
                                        ),
                                        child: TextField(
                                          controller: _emailController,
                                          focusNode: _emailFocus,
                                          keyboardType: TextInputType.emailAddress,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                          ),
                                          decoration: const InputDecoration(
                                            hintText: 'Email',
                                            hintStyle: TextStyle(
                                              color: Color(0xBF9B9B9B),
                                              fontSize: 16,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w600,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          onSubmitted: (_) => _handleSignUp(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Checkbox section
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _receiveUpdates = !_receiveUpdates;
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
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
                                                'I want to receive news about my modifications (such as uploads, updates, ban and deleting) and also about new version of the app',
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
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Sign up button
                              Container(
                                height: 54,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: GestureDetector(
                                  onTap: _isLoading ? null : _handleSignUp,
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
                                              'Sign up',
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
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Bottom log in section
                    Container(
                      width: double.infinity,
                      height: 94,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: double.infinity,
                                height: 54,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: const Color(0xFF388E3C),
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Log in',
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
                  ],
                ),
              ),
            );
          },
        ),
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
    if (!_emailController.text.contains('@') || !_emailController.text.contains('.')) {
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

      // Имитируем успешную регистрацию
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Регистрация успешна! Проверьте почту ${_emailController.text}',
          ),
          backgroundColor: const Color(0xFF388E3C),
          duration: const Duration(seconds: 3),
        ),
      );

      // Возвращаемся на страницу логина
      Navigator.of(context).pop();
    }
  }
}
