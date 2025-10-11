import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/comments.dart';
import '../components/interactive_widgets.dart';

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
            // Top row: Author and delete button
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Text(
                'Author: 123', // false value
                style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                ),
                ),
                IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                iconSize: 20,
                onPressed: () {
                    // TODO: Add delete functionality
                    print('Delete comment: ${comment.id}');
                },
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

}