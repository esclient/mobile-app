import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/comments.dart';
import '../providers/comments_provider.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final VoidCallback? onTap;
  final String? currentUserId;
  
  const CommentCard({
    super.key,
    required this.comment,
    this.onTap,
    this.currentUserId,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool _isEditing = false;
  late TextEditingController _editController;
  late FocusNode _editFocusNode;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.comment.text);
    _editFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _editController.dispose();
    _editFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tempTestUserId = '999';
    
    final isOwner = (widget.currentUserId != null && widget.currentUserId == widget.comment.authorId) ||
                    widget.comment.authorId == tempTestUserId;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF181F2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF374151),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1F2937),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_rounded,
                      size: 20,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.comment.authorId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (isOwner)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFF374151),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Вы',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isOwner && !_isEditing) ...[
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.edit_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _editFocusNode.requestFocus();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.delete_rounded,
                    iconColor: const Color(0xFFEF4444),
                    onPressed: () => _showDeleteDialog(context),
                  ),
                ],
                if (_isEditing) ...[
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.check_rounded,
                    iconColor: const Color(0xFF388E3C),
                    onPressed: () => _saveEdit(context),
                  ),
                  const SizedBox(width: 10),
                  _buildActionButton(
                    icon: Icons.close_rounded,
                    iconColor: const Color(0xFFEF4444),
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _editController.text = widget.comment.text;
                      });
                    },
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 14),
            
            if (_isEditing)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _editController,
                    focusNode: _editFocusNode,
                    maxLines: null,
                    minLines: 3,
                    maxLength: 500,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.6,
                      letterSpacing: 0.2,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(16),
                      counterText: '', // скрываем системный
                      hintText: 'Введите текст комментария...',
                      hintStyle: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFF374151),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _editFocusNode.hasFocus ? Color(0xFF388E3C) : Color(0xFF374151),
                          width: 1,
                        ),
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final characterCount = _editController.text.length;
                      final isNearLimit = characterCount > 450;
                      final isAtLimit = characterCount >= 500;
                      return Row(
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
                      );
                    },
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.comment.text,
                    style: const TextStyle(
                      color: Color(0xFFF3F4F6),
                      fontSize: 14,
                      height: 1.7,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (widget.comment.editedAt != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                size: 12,
                                color: const Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDateTime(widget.comment.editedAt!),
                                style: TextStyle(
                                  color: const Color(0xFF9CA3AF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF374151),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor ?? const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
  
  String _formatDateTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final commentDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (commentDate == today) {
      // Если сегодня, показываем только время
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return 'изменено $hour:$minute';
    } else {
      // Если не сегодня, показываем дату и время
      final day = dateTime.day;
      final month = _getMonthName(dateTime.month);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      
      // Если год отличается от текущего, добавляем год
      if (dateTime.year != now.year) {
        return 'изменено $day $month ${dateTime.year} г. $hour:$minute';
      } else {
        return 'изменено $day $month $hour:$minute';
      }
    }
  }
  
  String _getMonthName(int month) {
    const months = [
      'янв.', 'фев.', 'мар.', 'апр.', 'мая', 'июн.',
      'июл.', 'авг.', 'сен.', 'окт.', 'ноя.', 'дек.'
    ];
    return months[month - 1];
  }
  
  Future<void> _saveEdit(BuildContext context) async {
    final newText = _editController.text.trim();
    
    if (newText.isEmpty) {
      _showSnackBar(
        context: context,
        message: 'Комментарий не может быть пустым',
        icon: Icons.close_rounded,
        color: const Color(0xFFEF4444),
      );
      return;
    }
    
    if (newText == widget.comment.text) {
      setState(() {
        _isEditing = false;
      });
      return;
    }
    
    final commentsProvider = context.read<CommentsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      final success = await commentsProvider.editComment(
        commentId: widget.comment.id,
        text: newText,
      );
      
      if (success) {
        if (mounted) {
          setState(() {
            _isEditing = false;
          });
        }
        
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Комментарий успешно изменён',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF388E3C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    commentsProvider.error ?? 'Не удалось изменить комментарий',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ошибка: ${e.toString()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFF374151),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              const Expanded(
                child: Text(
                  'Удалить комментарий?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Это действие нельзя отменить. Комментарий будет удалён навсегда.',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Отмена',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Удалить',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
    
    if (confirmed == true && context.mounted) {
      await _deleteComment(context);
    }
  }
  
  Future<void> _deleteComment(BuildContext context) async {
    final commentsProvider = context.read<CommentsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      await commentsProvider.deleteComment(widget.comment.id);
      
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Комментарий удалён',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF388E3C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ошибка: ${e.toString()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  void _showSnackBar({
    required BuildContext context,
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
}
