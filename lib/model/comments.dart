class Comment {
  final String id;
  final String authorId;
  final String text;
  final int createdAt;

  Comment({
    required this.id,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'],
    authorId: json['author_id'],
    text: json['text'],
    createdAt: json['created_at'],
  );
}
