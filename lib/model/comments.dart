class Comment {
  final String id;
  final String authorId;
  final String text;
  final int createdAt;
  final int? editedAt; 

  Comment({
    required this.id,
    required this.authorId,
    required this.text,
    required this.createdAt,
    this.editedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'].toString(),
      authorId: json['author_id'].toString(),
      text: json['text'] as String,
      createdAt: json['created_at'] as int,
      editedAt: json['edited_at'] as int?,
    );
  }
}