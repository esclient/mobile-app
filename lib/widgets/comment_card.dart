import 'package:flutter/material.dart';
import '../model/comments.dart';

class CommentCard extends StatelessWidget{
    final Comment comment;
    final VoidCallback? onTap;

    const CommentCard({
        super.key,
        required this.comment,
        this.onTap,
    });

    @override
    Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
        color: const Color(0xFF181F2A), // Dark background like ModCard
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF374151),
            width: 1,
        ),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Top row: Avatar + author name (no label, no delete)
            Row(
            children: [
                Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF374151), width: 1),
                ),
                child: ClipOval(
                    child: _buildAvatar(comment.authorId),
                ),
                ),
                const SizedBox(width: 8),
                Expanded(
                child: Text(
                    comment.authorId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    ),
                ),
                ),
            ],
            ),
            
            const SizedBox(height: 8),
            
            // Comment text
            Text(
            comment.text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
            ),
            ),
        ],
        ),
    );
    }

    Widget _buildAvatar(String authorId) {
        // Placeholder avatar; if you have user avatars URL, replace with CachedNetworkImage
        return Container(
            color: const Color(0xFF1F2937),
            child: const Icon(
                Icons.person,
                size: 16,
                color: Color(0xFF9CA3AF),
            ),
        );
    }

}