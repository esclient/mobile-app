import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/comments_provider.dart';
import '../services/auth_service.dart';

class CommentInputWidget extends StatefulWidget {
  final String modId;
  
  const CommentInputWidget({
    super.key,
    required this.modId,
  });

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;
  bool _isFocused = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _controller.text.trim();
    
    if (text.isEmpty) {
      _showSnackBar(
        message: 'Комментарий не может быть пустым',
        icon: Icons.close_rounded,
        color: const Color(0xFFEF4444),
      );
      return;
    }
    
    const tempUserId = '999';
    final authService = context.read<AuthService>();
    
    if (!authService.isLoggedIn) {
      authService.login('test@example.com', userId: tempUserId);
    }
    
    setState(() {
      _isSending = true;
    });
    
    try {
      final commentsProvider = context.read<CommentsProvider>();
      final success = await commentsProvider.createComment(
        modId: widget.modId,
        authorId: authService.currentUserId!,
        text: text,
      );
      
      if (success) {
        _controller.clear();
        _focusNode.unfocus();
        
        if (mounted) {
          _showSnackBar(
            message: 'Комментарий успешно добавлен',
            icon: Icons.check_rounded,
            color: const Color(0xFF388E3C),
          );
        }
      } else {
        if (mounted) {
          _showSnackBar(
            message: commentsProvider.error ?? 'Ошибка при создании комментария',
            icon: Icons.close_rounded,
            color: const Color(0xFFEF4444),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _showSnackBar({
    required String message,
    required IconData icon,
    required Color color,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final characterCount = _controller.text.length;
    final isNearLimit = characterCount > 450;
    final isAtLimit = characterCount >= 500;
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        border: Border(
          top: BorderSide(
            color: _isFocused 
              ? const Color(0xFF374151)
              : const Color(0xFF374151).withOpacity(0.5),
            width: _isFocused ? 2 : 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: !_isSending,
                        maxLines: null,
                        minLines: 1,
                        maxLength: 500,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                          letterSpacing: 0.2,
                        ),
                        onChanged: (value) {
                          setState(() {}); // Trigger rebuild for character count
                        },
                        decoration: InputDecoration(
                          hintText: 'Написать комментарий...',
                          hintStyle: TextStyle(
                            color: const Color(0xFF9CA3AF).withOpacity(0.8),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: _isFocused 
                            ? const Color(0xFF181F2A)
                            : const Color(0xFF181F2A).withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Color(0xFF374151),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: _isFocused ? Color(0xFF388E3C) : Color(0xFF374151),
                              width: 1.5,
                            ),
                          ),
                          counterText: '', // <-- удаляет отображение рамки и чисел под полем
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: GestureDetector(
                      onTapDown: (_) => _animationController.forward(),
                      onTapUp: (_) {
                        _animationController.reverse();
                        if (!_isSending) _sendComment();
                      },
                      onTapCancel: () => _animationController.reverse(),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _isSending 
                              ? const Color(0xFF181F2A)
                              : const Color(0xFF388E3C),
                          shape: BoxShape.circle,
                        ),
                        child: _isSending
                            ? Padding(
                                padding: const EdgeInsets.all(14),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color(0xFF9CA3AF).withOpacity(0.6),
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              // Character counter (only show when focused or near limit)
              if (_isFocused || isNearLimit) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAtLimit
                            ? const Color(0xFFEF4444).withOpacity(0.2)
                            : isNearLimit
                                ? const Color(0xFFF59E0B).withOpacity(0.2)
                                : const Color(0xFF181F2A).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAtLimit
                              ? const Color(0xFFEF4444).withOpacity(0.4)
                              : isNearLimit
                                  ? const Color(0xFFF59E0B).withOpacity(0.4)
                                  : const Color(0xFF374151).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isNearLimit)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                isAtLimit ? Icons.error_rounded : Icons.warning_rounded,
                                size: 14,
                                color: isAtLimit
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFFF59E0B),
                              ),
                            ),
                          Text(
                            '$characterCount/500',
                            style: TextStyle(
                              color: isAtLimit
                                  ? const Color(0xFFEF4444)
                                  : isNearLimit
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFF9CA3AF),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

