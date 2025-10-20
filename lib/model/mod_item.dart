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
  
  late final String _formattedRatingsCount;
  late final String _formattedDownloadsCount;
  late final int _starsCount;

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
  }) {
    _starsCount = rating.round().clamp(1, 5);
    _formattedRatingsCount = _formatRatingsCount(ratingsCount);
    _formattedDownloadsCount = _formatDownloadsCount(downloadsCount);
  }
  
  static String _formatRatingsCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}К оценок';
    }
    return '$count оценок';
  }
  
  static String _formatDownloadsCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}М';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}К';
    }
    return count.toString();
  }

  factory ModItem.fromJson(Map<String, dynamic> json) {
    final createdAtValue = json['createdAt'] ?? json['created_at'] ?? 0;
    final int timestamp = createdAtValue is int ? createdAtValue : 0;
    
    return ModItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      ratingsCount: json['ratingsCount'] ?? 0,
      imageUrl: json['imageUrl']?.toString() ?? 'https://placehold.co/48x48',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
      createdAt: timestamp > 0 
        ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
        : DateTime.now(),
      authorId: json['authorId']?.toString() ?? json['author_id']?.toString() ?? '',
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

  int get starsCount => _starsCount;
  String get formattedRatingsCount => _formattedRatingsCount;
  String get formattedDownloadsCount => _formattedDownloadsCount;
}
