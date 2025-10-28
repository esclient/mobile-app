import 'package:flutter/foundation.dart';
import '../model/comments.dart';
import '../services/comments.dart';
import 'dart:developer';

class CommentsProvider extends ChangeNotifier {
  final CommentService _commentsService;
  CommentsProvider(this._commentsService);

  List<Comment> _comments = [];
  bool _isLoading = false;
  String? _error;
  String? _currentModId;
  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentModId => _currentModId;

  Future<void> loadComments(String modId) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
        final newComments = await _commentsService.fetchComments(modId);
        _comments = newComments;
        _currentModId = modId;
    } catch (e) {
        _error = 'Failed to load comments: ${e.toString()}';
        _comments = [];
    } finally {
        _isLoading = false;
        notifyListeners();
    }
    }



  Future<void> deleteComment(String commentId) async {
    try {
      log('Attempting to delete comment: $commentId');
      
      // Optimistic update: remove comment immediately
      final removedIndex = _comments.indexWhere((c) => c.id == commentId);
      Comment? removedComment;
      
      if (removedIndex != -1) {
        removedComment = _comments.removeAt(removedIndex);
        notifyListeners();
      }
      
      // Send delete request to server
      final success = await _commentsService.deleteComment(commentId);
     
      if (success) {
        log('Successfully deleted comment: $commentId');
      } else {
        // Rollback: restore comment if server request failed
        if (removedComment != null && removedIndex != -1) {
          _comments.insert(removedIndex, removedComment);
          notifyListeners();
        }
        throw Exception("Failed to delete a comment");
      }
    } catch (e) {
      log('Error deleting comment: $e');
      _error = 'Failed to delete a comment: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> createComment({
    required String modId,
    required String authorId,
    required String text,
  }) async {
    // Validate input
    if (text.trim().isEmpty) {
      _error = 'Комментарий не может быть пустым';
      notifyListeners();
      return false;
    }
   
    _error = null;
    
    // Create temporary comment with temporary ID
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempComment = Comment(
      id: tempId,
      authorId: authorId,
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
    
    // Optimistic update: add comment immediately
    _comments.insert(0, tempComment);
    notifyListeners();
    
    try {
      final commentId = await _commentsService.createComment(
        modId: modId,
        authorId: authorId,
        text: text,
      );
      
      // Replace temporary comment with real one
      final tempIndex = _comments.indexWhere((c) => c.id == tempId);
      if (tempIndex != -1) {
        _comments[tempIndex] = Comment(
          id: commentId,
          authorId: authorId,
          text: text,
          createdAt: _comments[tempIndex].createdAt,
        );
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      // Rollback: remove temporary comment if server request failed
      _comments.removeWhere((c) => c.id == tempId);
      _error = 'Не удалось создать комментарий: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> editComment({
    required String commentId,
    required String text,
  }) async {
    // Validate input
    if (text.trim().isEmpty) {
      _error = 'Комментарий не может быть пустым';
      notifyListeners();
      return false;
    }
  
    _error = null;
    
    // Find the comment to edit
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index == -1) {
      _error = 'Комментарий не найден';
      notifyListeners();
      return false;
    }
    
    // Store original comment for rollback
    final originalComment = _comments[index];
    
    // Optimistic update: update comment immediately
    _comments[index] = Comment(
      id: originalComment.id,
      authorId: originalComment.authorId,
      text: text,
      createdAt: originalComment.createdAt,
      editedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
    notifyListeners();
    
    try {
      final success = await _commentsService.editComment(
        commentId: commentId,
        text: text,
      );
      
      if (!success) {
        // Rollback: restore original comment if server request failed
        _comments[index] = originalComment;
        _error = 'Не удалось изменить комментарий';
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      // Rollback: restore original comment if error occurred
      _comments[index] = originalComment;
      _error = 'Не удалось изменить комментарий: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}