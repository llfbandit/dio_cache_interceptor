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
const contentTypeHeader = 'content-type';

const jsonContentType = 'application/json';

/// An HTTP token.
final token = RegExp(r'[^()<>@,;:\\/[\]?={} \t\x00-\x1F\x7F]+');

/// Linear whitespace.
final _lws = RegExp(r'(?:\r\n)?[ \t]+');

/// A regular expression matching any number of [_lws] productions in a row.
final whitespace = RegExp('(?:${_lws.pattern})*');

/// "token" as defined in RFC 2616, 2.2
/// See https://datatracker.ietf.org/doc/html/rfc2616#section-2.2
const tokenChars = r"!#$%&'*+\-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ^_`"
    'abcdefghijklmnopqrstuvwxyz|~';

/// Splits comma-seperated header values.
var headerSplitter = RegExp(r'[ \t]*,[ \t]*');

/// Splits comma-seperated "Set-Cookie" header values.
///
/// Set-Cookie strings can contain commas. In particular, the following
/// productions defined in RFC-6265, section 4.1.1:
/// - `<sane-cookie-date>` e.g. "Expires=Sun, 06 Nov 1994 08:49:37 GMT"
/// - `<path-value>` e.g. "Path=somepath,"
/// - `<extension-av>` e.g. "AnyString,Really,"
///
/// Some values are ambiguous e.g.
/// "Set-Cookie: lang=en; Path=/foo/"
/// "Set-Cookie: SID=x23"
/// and:
/// "Set-Cookie: lang=en; Path=/foo/,SID=x23"
/// would both be result in `response.headers` => "lang=en; Path=/foo/,SID=x23"
///
/// The idea behind this regex is that `,<valid token>=` is more likely to
/// start a new `<cookie-pair>` than be part of `<path-value>` or
/// `<extension-av>`.
///
/// See https://datatracker.ietf.org/doc/html/rfc6265#section-4.1.1
var setCookieSplitter = RegExp(r'[ \t]*,[ \t]*(?=[' + tokenChars + r']+=)');
