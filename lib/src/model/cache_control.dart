/// Cache-Control header subset representation
class CacheControl {
  /// How long the response can be used from the time it was requested (in seconds).
  /// https://tools.ietf.org/html/rfc7234#section-5.2.2.8
  final int maxAge;

  /// 'public' / 'private'.
  /// https://tools.ietf.org/html/rfc7234#section-5.2.2.5
  final String privacy;

  /// Must first submit a validation request to an origin server.
  /// https://tools.ietf.org/html/rfc7234#section-5.2.2.2
  final bool noCache;

  /// Disallow cache, overriding any other directives (Etag, Last-Modified)
  /// https://tools.ietf.org/html/rfc7234#section-5.2.2.3
  final bool noStore;

  /// Other attributes not parsed
  final List<String> other;

  CacheControl({
    this.maxAge = 0,
    this.privacy = '',
    this.noCache = false,
    this.noStore = false,
    List<String> otherAttrs = const [],
  }) : other = otherAttrs;

  factory CacheControl.fromHeader(List<String> headerValues) {
    if (headerValues.isEmpty) return CacheControl();

    var maxAge = 0;
    var privacy = '';
    var noCache = false;
    var noStore = false;
    final other = <String>[];

    for (var value in headerValues) {
      if (value == 'no-cache') {
        noCache = true;
      } else if (value == 'no-store') {
        noStore = true;
      } else if (value == 'public' || value == 'private') {
        privacy = value;
      } else if (value.startsWith('max-age')) {
        maxAge = int.tryParse(value.substring(value.indexOf('=') + 1)) ?? 0;
      } else {
        other.add(value);
      }
    }

    return CacheControl(
      maxAge: maxAge,
      privacy: privacy,
      noCache: noCache,
      noStore: noStore,
      otherAttrs: other,
    );
  }

  /// Serialize cache-control values
  String toHeader() {
    final values = <String>[]
      ..add(maxAge != 0 ? 'max-age=$maxAge' : '')
      ..add(privacy)
      ..add(noCache ? 'no-cache' : '')
      ..add(noStore ? 'no-store' : '')
      ..addAll(other);

    return values.join(', ');
  }

  /// Check if cache-control fields invalidates cache entry.
  ///
  /// [responseDate] given is from response absolute time.
  /// [date] given is from Date response header.
  /// [expires] given is from Expires response header.
  bool isStale(DateTime responseDate, DateTime? date, DateTime? expires) {
    if (noCache || other.contains('must-revalidate')) {
      return true;
    }

    if (maxAge == 0) {
      if (date != null && expires != null) {
        return expires.difference(date).isNegative;
      }

      return false;
    }

    final maxDate = responseDate.add(Duration(seconds: maxAge));
    return maxDate.isBefore(DateTime.now());
  }
}
