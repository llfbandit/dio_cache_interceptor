/// Cache priority
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
