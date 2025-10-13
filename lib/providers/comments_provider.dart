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
}