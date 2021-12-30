/// Cache-Control header subset representation
class CacheControl {
  /// How long the response can be used from the time it was requested (in seconds).
  /// https://datatracker.ietf.org/doc/html/rfc7234#section-5.2.2.8
  final int maxAge;

  /// 'public' / 'private'.
  /// https://datatracker.ietf.org/doc/html/rfc7234#section-5.2.2.5
  final String? privacy;

  /// Must first submit a validation request to an origin server.
  /// https://datatracker.ietf.org/doc/html/rfc7234#section-5.2.2.2
  final bool noCache;

  /// Disallow cache, overriding any other directives (Etag, Last-Modified)
  /// https://datatracker.ietf.org/doc/html/rfc7234#section-5.2.2.3
  final bool noStore;

  /// The "max-stale" request directive indicates that the client is
  /// willing to accept a response that has exceeded its freshness
  /// lifetime.
  /// https://datatracker.ietf.org/doc/html/rfc7234#section-5.2.1.2
  final int maxStale;

  /// The "min-fresh" request directive indicates that the client is
  /// willing to accept a response whose freshness lifetime is no less than
  /// its current age.
  /// https://datatracker.ietf.org/doc/html/rfc7234#section-5.2.1.3
  final int minFresh;

  /// The "must-revalidate" response directive indicates that once it has
  /// become stale, a cache MUST NOT use the response to satisfy subsequent
  /// requests without successful validation on the origin server.
  /// https://datatracker.ietf.org/doc/html/rfc7234#section-5.2.2.1
  final bool mustRevalidate;

  /// Other attributes not parsed
  final List<String> other;

  CacheControl({
    this.maxAge = -1,
    this.privacy,
    this.maxStale = -1,
    this.minFresh = -1,
    this.mustRevalidate = false,
    this.noCache = false,
    this.noStore = false,
    this.other = const [],
  });

  static CacheControl fromHeader(List<String>? headerValues) {
    headerValues ??= [];

    int? maxAge;
    int? maxStale;
    int? minFresh;
    bool? mustRevalidate;
    String? privacy;
    bool? noCache;
    bool? noStore;
    final other = <String>[];

    for (var value in headerValues) {
      // Expand values since dio does not do it !
      for (var expandedValue in value.split(',')) {
        expandedValue = expandedValue.trim();
        if (expandedValue == 'no-cache') {
          noCache = true;
        } else if (expandedValue == 'no-store') {
          noStore = true;
        } else if (expandedValue == 'public' || expandedValue == 'private') {
          privacy = expandedValue;
        } else if (expandedValue == 'must-revalidate') {
          mustRevalidate = true;
        } else if (expandedValue.startsWith('max-age')) {
          maxAge = int.tryParse(
            expandedValue.substring(expandedValue.indexOf('=') + 1),
          );
        } else if (expandedValue.startsWith('max-stale')) {
          maxStale = int.tryParse(
            expandedValue.substring(expandedValue.indexOf('=') + 1),
          );
        } else if (expandedValue.startsWith('min-fresh')) {
          minFresh = int.tryParse(
            expandedValue.substring(expandedValue.indexOf('=') + 1),
          );
        } else {
          other.add(expandedValue);
        }
      }
    }

    return CacheControl(
      maxAge: maxAge ?? -1,
      maxStale: maxStale ?? -1,
      minFresh: minFresh ?? -1,
      mustRevalidate: mustRevalidate ?? false,
      privacy: privacy,
      noCache: noCache ?? false,
      noStore: noStore ?? false,
      other: other,
    );
  }

  /// Serialize cache-control values
  String toHeader() {
    final strBuff = StringBuffer();
    if (maxAge != -1) strBuff.write('max-age=$maxAge, ');
    if (maxStale != -1) strBuff.write('max-stale=$maxStale, ');
    if (minFresh != -1) strBuff.write('min-fresh=$minFresh, ');
    if (mustRevalidate) strBuff.write('must-revalidate, ');
    if (privacy != null) strBuff.write('$privacy, ');
    if (noCache) strBuff.write('no-cache, ');
    if (noStore) strBuff.write('no-store, ');
    if (other.isNotEmpty) strBuff.write(other.join(', '));

    final str = strBuff.toString();
    if (str.isNotEmpty) str.substring(0, str.length - 2);

    return str;
  }
}
