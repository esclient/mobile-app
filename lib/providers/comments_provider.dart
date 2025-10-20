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
    if (_isLoading) return;
   
    try {
      log('Attempting to delete comment: $commentId');
      final removedIndex = _comments.indexWhere((c) => c.id == commentId);
      Comment? removedComment;
      if (removedIndex != -1) {
        removedComment = _comments.removeAt(removedIndex);
        notifyListeners();
      }
      
      final success = await _commentsService.deleteComment(commentId);
     
      if (success) {
        log('Successfully deleted comment: $commentId');
      } else {
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
    if (_isLoading) return false;
    
    // Validate input
    if (text.trim().isEmpty) {
      _error = 'Комментарий не может быть пустым';
      notifyListeners();
      return false;
    }
   
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final commentId = await _commentsService.createComment(
        modId: modId,
        authorId: authorId,
        text: text,
      );
      
      final newComment = Comment(
        id: commentId,
        authorId: authorId,
        text: text,
        createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );
      
      _comments.insert(0, newComment);
      
      return true;
    } catch (e) {
      _error = 'Не удалось создать комментарий: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> editComment({
    required String commentId,
    required String text,
  }) async {
    if (_isLoading) return false;
    
    // Validate input
    if (text.trim().isEmpty) {
      _error = 'Комментарий не может быть пустым';
      notifyListeners();
      return false;
    }
  
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final success = await _commentsService.editComment(
        commentId: commentId,
        text: text,
      );
      
      if (success) {
        final index = _comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          _comments[index] = Comment(
            id: _comments[index].id,
            authorId: _comments[index].authorId,
            text: text,
            createdAt: _comments[index].createdAt,
            editedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          );
        }
      }
      
      return success;
    } catch (e) {
      _error = 'Не удалось изменить комментарий: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}