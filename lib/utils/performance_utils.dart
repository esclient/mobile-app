import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// Performance utilities for optimizing app performance
class PerformanceUtils {
  /// Run task in next frame to avoid blocking current frame
  static void runInNextFrame(VoidCallback callback) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }
  
  /// Run task with idle priority
  static void runWhenIdle(VoidCallback callback) {
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      callback();
    }, rescheduling: false);
  }
  
  /// Debounce function calls to reduce frequency
  static Timer? _debounceTimer;
  static void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 300)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }
  
  /// Throttle function calls to limit frequency
  static DateTime? _lastThrottleTime;
  static void throttle(VoidCallback callback, {Duration interval = const Duration(milliseconds: 100)}) {
    final now = DateTime.now();
    if (_lastThrottleTime == null || now.difference(_lastThrottleTime!) > interval) {
      _lastThrottleTime = now;
      callback();
    }
  }
  
  /// Run heavy computation in isolate
  static Future<T> runInIsolate<T>(ComputeCallback<dynamic, T> callback, dynamic message) {
    return compute(callback, message);
  }
  
  /// Batch operations for better performance
  static final List<VoidCallback> _batchedOperations = [];
  static Timer? _batchTimer;
  
  static void batchOperation(VoidCallback operation, {Duration batchDelay = const Duration(milliseconds: 100)}) {
    _batchedOperations.add(operation);
    
    _batchTimer?.cancel();
    _batchTimer = Timer(batchDelay, () {
      final operations = List<VoidCallback>.from(_batchedOperations);
      _batchedOperations.clear();
      
      for (final op in operations) {
        op();
      }
    });
  }
  
  /// Memory-aware loading
  static bool shouldLoadMore() {
    // Check if we have enough memory to load more items
    // This is a simplified check - in production you'd want more sophisticated logic
    return true;
  }
  
  /// Frame budget manager
  // static const Duration _frameBudget = Duration(milliseconds: 16); // 60fps
  
  static Future<void> yieldToRenderer() async {
    await Future.delayed(Duration.zero);
  }
  
  /// Chunk large operations
  static Future<void> processInChunks<T>(
    List<T> items,
    Future<void> Function(T) processor, {
    int chunkSize = 10,
  }) async {
    for (int i = 0; i < items.length; i += chunkSize) {
      final end = (i + chunkSize < items.length) ? i + chunkSize : items.length;
      final chunk = items.sublist(i, end);
      
      for (final item in chunk) {
        await processor(item);
      }
      
      // Yield to renderer between chunks
      await yieldToRenderer();
    }
  }
}

/// Widget that only builds when idle
class IdleBuilder extends StatefulWidget {
  final WidgetBuilder builder;
  final Widget placeholder;
  
  const IdleBuilder({
    super.key,
    required this.builder,
    this.placeholder = const SizedBox.shrink(),
  });
  
  @override
  State<IdleBuilder> createState() => _IdleBuilderState();
}

class _IdleBuilderState extends State<IdleBuilder> {
  bool _isBuilt = false;
  
  @override
  void initState() {
    super.initState();
    PerformanceUtils.runWhenIdle(() {
      if (mounted) {
        setState(() {
          _isBuilt = true;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return _isBuilt ? widget.builder(context) : widget.placeholder;
  }
}
