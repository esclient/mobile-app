import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// App-wide configuration for performance optimization
class AppConfig {
  /// Initialize performance configurations
  static Future<void> initialize() async {
    // Configure image caching
    _configureImageCache();
    
    // Configure network cache manager
    _configureCacheManager();
  }
  
  /// Configure image cache settings for better performance
  static void _configureImageCache() {
    // Increase image cache size (default is 1000)
    PaintingBinding.instance.imageCache.maximumSize = 200; // Reduce to save memory
    
    // Increase image cache size in bytes (default is 100MB)
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB
    
    // Clear cache if needed
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
  
  /// Configure cache manager for network images
  static void _configureCacheManager() {
    // This is handled automatically by CachedNetworkImage
    // But we can create a custom cache manager if needed
  }
  
  /// Custom cache manager for app
  static final customCacheManager = CacheManager(
    Config(
      'esclient_cache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
      repo: JsonCacheInfoRepository(databaseName: 'esclient_cache'),
      fileService: HttpFileService(),
    ),
  );
  
  /// Performance settings
  static const performanceSettings = PerformanceSettings(
    enablePrefetch: true,
    maxConcurrentRequests: 3,
    imageQuality: ImageQuality.medium,
    enableLazyLoading: true,
    scrollCacheExtent: 1000.0,
    debounceDelay: Duration(milliseconds: 300),
    throttleInterval: Duration(milliseconds: 100),
  );
}

/// Performance settings configuration
class PerformanceSettings {
  final bool enablePrefetch;
  final int maxConcurrentRequests;
  final ImageQuality imageQuality;
  final bool enableLazyLoading;
  final double scrollCacheExtent;
  final Duration debounceDelay;
  final Duration throttleInterval;
  
  const PerformanceSettings({
    required this.enablePrefetch,
    required this.maxConcurrentRequests,
    required this.imageQuality,
    required this.enableLazyLoading,
    required this.scrollCacheExtent,
    required this.debounceDelay,
    required this.throttleInterval,
  });
}

/// Image quality settings
enum ImageQuality {
  low(0.5),
  medium(0.7),
  high(1.0);
  
  final double compressionRatio;
  const ImageQuality(this.compressionRatio);
  
  int getMemCacheSize(int originalSize) {
    return (originalSize * compressionRatio).round();
  }
}

/// Optimized image widget
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  
  const OptimizedImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });
  
  @override
  Widget build(BuildContext context) {
    final quality = AppConfig.performanceSettings.imageQuality;
    final cacheWidth = quality.getMemCacheSize(width.toInt() * 3);
    final cacheHeight = quality.getMemCacheSize(height.toInt() * 3);
    
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        maxWidthDiskCache: cacheWidth,
        maxHeightDiskCache: cacheHeight,
        fadeInDuration: const Duration(milliseconds: 100),
        fadeOutDuration: const Duration(milliseconds: 50),
        cacheManager: AppConfig.customCacheManager,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: const Color(0xFF374151),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: const Color(0xFF374151),
          child: const Icon(
            Icons.image_not_supported,
            color: Color(0xFF9CA3AF),
          ),
        ),
      );
    }
    
    return Image.asset(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      gaplessPlayback: true,
    );
  }
}
