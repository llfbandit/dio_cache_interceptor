const cacheControlHeader = 'cache-control';
const ageHeader = 'age';
const dateHeader = 'date';
const etagHeader = 'etag';
const expiresHeader = 'expires';
const contentLocationHeader = 'content-location';
const varyHeader = 'vary';
const ifModifiedSinceHeader = 'if-modified-since';
const ifNoneMatchHeader = 'if-none-match';
const lastModifiedHeader = 'last-modified';

/// An HTTP token.
final token = RegExp(r'[^()<>@,;:"\\/[\]?={} \t\x00-\x1F\x7F]+');

/// Linear whitespace.
final _lws = RegExp(r'(?:\r\n)?[ \t]+');

/// A regular expression matching any number of [_lws] productions in a row.
final whitespace = RegExp('(?:${_lws.pattern})*');
