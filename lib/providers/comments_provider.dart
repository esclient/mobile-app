import 'package:flutter/foundation.dart';
import '../model/comments.dart';
import '../services/comments.dart';
import 'dart:developer';

class CommentsProvider extends ChangeNotifier {
    final CommentsService _commentsService;

    CommentsProvider(this._commentsService) {}

    // State variables
    List<CommentItem> _comments = [];
    bool _isLoading = false;
    String? _error;
    String? _currentModId;

    // Getters
    List<CommentItem> get comments => _comments;
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
            
            notifyListeners();
        } catch(e) {
            _setError('Failed to load comments: ${e.toString()}');
        } finally {
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