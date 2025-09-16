class ModItem {
  final String id;
  final String title;
  final String description;
  final double rating;
  final int ratingsCount;
  final String imageUrl;
  final List<String> tags;
  final DateTime createdAt;
  final String authorId;
  final int downloadsCount;

  ModItem({
    required this.id,
    required this.title,
    required this.description,
    required this.rating,
    required this.ratingsCount,
    required this.imageUrl,
    required this.tags,
    required this.createdAt,
    required this.authorId,
    required this.downloadsCount,
  });

  factory ModItem.fromJson(Map<String, dynamic> json) {
    return ModItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      ratingsCount: json['ratingsCount'] ?? 0,
      imageUrl: json['imageUrl'] ?? 'https://placehold.co/48x48',
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['createdAt'] ?? 0) * 1000,
      ),
      authorId: json['authorId'] ?? '',
      downloadsCount: json['downloadsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'rating': rating,
      'ratingsCount': ratingsCount,
      'imageUrl': imageUrl,
      'tags': tags,
      'createdAt': createdAt.millisecondsSinceEpoch ~/ 1000,
      'authorId': authorId,
      'downloadsCount': downloadsCount,
    };
  }

  // Метод для получения количества звезд для отображения
  int get starsCount {
    return rating.round().clamp(1, 5);
  }

  // Форматированное количество оценок
  String get formattedRatingsCount {
    if (ratingsCount >= 1000) {
      return '${(ratingsCount / 1000).toStringAsFixed(1)}К оценок';
    }
    return '$ratingsCount оценок';
  }

  // Форматированное количество загрузок
  String get formattedDownloadsCount {
    if (downloadsCount >= 1000000) {
      return '${(downloadsCount / 1000000).toStringAsFixed(1)}М';
    } else if (downloadsCount >= 1000) {
      return '${(downloadsCount / 1000).toStringAsFixed(1)}К';
    }
    return downloadsCount.toString();
  }
}
