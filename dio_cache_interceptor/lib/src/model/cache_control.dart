import 'package:dio_cache_interceptor/src/util/contants.dart';
import 'package:string_scanner/string_scanner.dart';

final _knownAttributes = RegExp(
  r'max-age|max-stale|min-fresh|must-revalidate|public|private|no-cache|no-store',
);

const _maxAgeHeader = 'max-age';
const _maxStaleHeader = 'max-stale';
const _minFreshHeader = 'min-fresh';
const _mustRevalidateHeader = 'must-revalidate';
const _privateHeader = 'private';
const _publicHeader = 'public';
const _noCacheHeader = 'no-cache';
const _noStoreHeader = 'no-store';

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

  /// Builds Cache Control from header values
  factory CacheControl.fromHeader(List<String>? headerValues) {
    // Parses single header value
    void parseHeaderValue(
      StringScanner scanner,
      Map<String, String> parameters,
      List<String> other,
    ) {
      scanner.scan(whitespace);
      scanner.expect(token);

      final attribute = scanner.lastMatch![0]!;

      if (_knownAttributes.hasMatch(attribute)) {
        if (scanner.scan('=')) {
          scanner.expect(token);
          parameters[attribute] = scanner.lastMatch![0]!;
        } else {
          parameters[attribute] = attribute;
        }
      } else {
        if (scanner.scan('=')) {
          scanner.expect(token);
          other.add('$attribute=${scanner.lastMatch![0]!}');
        } else {
          other.add(attribute);
        }
      }
    }

    headerValues ??= [];

    final parameters = <String, String>{};
    final other = <String>[];

    for (var value in headerValues) {
      if (value.isNotEmpty) {
        final scanner = StringScanner(value);
        parseHeaderValue(scanner, parameters, other);

        while (scanner.scan(',')) {
          parseHeaderValue(scanner, parameters, other);
        }
        scanner.expectDone();
      }
    }

    return CacheControl(
      maxAge: int.tryParse(parameters[_maxAgeHeader] ?? '') ?? -1,
      maxStale: int.tryParse(parameters[_maxStaleHeader] ?? '') ?? -1,
      minFresh: int.tryParse(parameters[_minFreshHeader] ?? '') ?? -1,
      mustRevalidate: parameters.containsKey(_mustRevalidateHeader),
      privacy: parameters[_publicHeader] ?? parameters[_privateHeader],
      noCache: parameters.containsKey(_noCacheHeader),
      noStore: parameters.containsKey(_noStoreHeader),
      other: other,
    );
  }

  /// Serialize cache-control values
  String toHeader() {
    final header = <String>[];

    if (maxAge != -1) header.add('$_maxAgeHeader=$maxAge');
    if (maxStale != -1) header.add('$_maxStaleHeader=$maxStale');
    if (minFresh != -1) header.add('$_minFreshHeader=$minFresh');
    if (mustRevalidate) header.add(_mustRevalidateHeader);
    if (privacy != null) header.add(privacy!);
    if (noCache) header.add(_noCacheHeader);
    if (noStore) header.add(_noStoreHeader);
    if (other.isNotEmpty) header.addAll(other);

    return header.join(', ');
  }
}
