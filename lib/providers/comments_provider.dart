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
        if (_isLoading) return;

        _setLoading(true);
        _error = null;

        try{
            final newComments = await _commentsService.fetchComments(modId);

            _comments = newComments;
            _currentModId = modId;
            
            log('Successfully loaded ${newComments.length} comments');
            notifyListeners();
        } catch(e) {
            log('Error loading comments: $e');
            _setError('Failed to load comments: ${e.toString()}');
        } finally {
            _setLoading(false);
        }
    }

    Future<void> deleteComment(String comment_id) async{
        if (_isLoading) return;

        _setLoading(true);
        _error = null;

        try{
            final success = await _commentsService.deleteComment(comment_id);
            log('Attempting to delete comment: $comment_id');
            if(success)
            {
                _comments.removeWhere((comment) => comment.id == comment_id);
                log('Successfully deleted comment: $comment_id');
                notifyListeners();
            }
            else{
                throw Exception("Failed to delete a comment");
            }

        }catch(e){
            _setError('Failed to delete a comment: ${e.toString()}');
        }finally{
            _setLoading(false);
        }

    }
    
    void _setLoading(bool loading) {
        _isLoading = loading;
        notifyListeners();
    }

    void _setError(String error) {
        _error = error;
        notifyListeners();
    }
}