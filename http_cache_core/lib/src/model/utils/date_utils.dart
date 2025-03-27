import 'http_date.dart';

DateTime? getExpiresHeaderValue(String? headerValue) {
  if (headerValue != null) {
    try {
      return HttpDate.parse(headerValue);
    } catch (_) {
      // Invalid date format => meaning something already expired
      return DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true);
    }
  }

  return null;
}

DateTime? getDateHeaderValue(String? headerValue) {
  if (headerValue case final date?) {
    try {
      return HttpDate.parse(date);
    } catch (_) {
      // Invalid date format => ignored
    }
  }

  return null;
}
