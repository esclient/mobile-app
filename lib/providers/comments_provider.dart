import 'package:flutter/foundation.dart';
import '../model/comments.dart';
import '../services/comments.dart';
import 'dart:developer';

class CommentsProvider extends ChangeNotifier {
  final CommentService _commentsService;
  CommentsProvider(this._commentsService);

  // State variables
  List<Comment> _comments = [];
  bool _isLoading = false;
  String? _error;
  String? _currentModId;

  // Getters
  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentModId => _currentModId;

  Future<void> loadComments(String modId) async {
    print('🔵 CommentsProvider: loadComments called for modId: $modId');

    if (_isLoading) {
        print('⚠️ Already loading, skipping');
        return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
        print('🔵 Calling service.fetchComments...');
        final newComments = await _commentsService.fetchComments(modId);
        _comments = newComments;
        _currentModId = modId;
        print('🟢 Successfully loaded ${newComments.length} comments');
    } catch (e) {
        print('🔴 Error in provider: $e');
        _error = 'Failed to load comments: ${e.toString()}';
        _comments = []; // Clear comments on error
    } finally {
        _isLoading = false;
        notifyListeners();
    }
    }



  Future<void> deleteComment(String commentId) async {
    if (_isLoading) return;
   
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      log('Attempting to delete comment: $commentId');
      final success = await _commentsService.deleteComment(commentId);
     
      if (success) {
        _comments.removeWhere((comment) => comment.id == commentId);
        log('Successfully deleted comment: $commentId');
      } else {
        throw Exception("Failed to delete a comment");
      }
    } catch (e) {
      log('Error deleting comment: $e');
      _error = 'Failed to delete a comment: ${e.toString()}';
    } finally {
      _isLoading = false;
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
      print('🔵 CommentsProvider: Creating comment for mod $modId');
      
      // Call service to create comment
      final commentId = await _commentsService.createComment(
        modId: modId,
        authorId: authorId,
        text: text,
      );
      
      // Create new comment object and add to list
      final newComment = Comment(
        id: commentId,
        authorId: authorId,
        text: text,
        createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );
      
      // Add to beginning of list (newest first)
      _comments.insert(0, newComment);
      print('🟢 Comment created successfully with ID: $commentId');
      
      return true;
    } catch (e) {
      print('🔴 Error creating comment: $e');
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
      print('🔵 CommentsProvider: Editing comment $commentId');
      
      // Call service to edit comment
      final success = await _commentsService.editComment(
        commentId: commentId,
        text: text,
      );
      
      if (success) {
        // Update the comment in the local list
        final index = _comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          // Create updated comment with new text and edited timestamp
          _comments[index] = Comment(
            id: _comments[index].id,
            authorId: _comments[index].authorId,
            text: text,
            createdAt: _comments[index].createdAt,
            editedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          );
        }
        print('🟢 Comment edited successfully');
      }
      
      return success;
    } catch (e) {
      print('🔴 Error editing comment: $e');
      _error = 'Не удалось изменить комментарий: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}