/// Cache priority.
///
/// Could be useful if you have multiple levels of cache.
/// This allows to separate entries and ease cleanup.
enum CachePriority {
  /// Cache defined as low priority
  low,

  /// Cache defined as normal priority
  normal,

  /// Cache defined as high priority
  high,
}

extension CachePriorityToString on CachePriority {
  String toShortString() {
    return toString().split('.').last;
  }
}
