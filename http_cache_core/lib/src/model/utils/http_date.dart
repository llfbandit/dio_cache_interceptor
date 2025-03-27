class HttpDate {
  /// Format a date according to
  /// [RFC-1123](http://tools.ietf.org/html/rfc1123 "RFC-1123"),
  /// e.g. `Thu, 1 Jan 1970 00:00:00 GMT`.
  static String format(DateTime date) {
    const wkday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const month = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final d = date.toUtc();
    final sb = StringBuffer()
      ..write(wkday[d.weekday - 1])
      ..write(', ')
      ..write(d.day <= 9 ? '0' : '')
      ..write(d.day.toString())
      ..write(' ')
      ..write(month[d.month - 1])
      ..write(' ')
      ..write(d.year.toString())
      ..write(d.hour <= 9 ? ' 0' : ' ')
      ..write(d.hour.toString())
      ..write(d.minute <= 9 ? ':0' : ':')
      ..write(d.minute.toString())
      ..write(d.second <= 9 ? ':0' : ':')
      ..write(d.second.toString())
      ..write(' GMT');
    return sb.toString();
  }

  /// Parse a date string in either of the formats
  /// [RFC-1123](http://tools.ietf.org/html/rfc1123 "RFC-1123"),
  /// [RFC-850](http://tools.ietf.org/html/rfc850 "RFC-850") or
  /// ANSI C's asctime() format. These formats are listed here.
  ///
  ///     Thu, 1 Jan 1970 00:00:00 GMT
  ///     Thursday, 1-Jan-1970 00:00:00 GMT
  ///     Thu Jan  1 00:00:00 1970
  ///
  /// For more information see [RFC-2616 section
  /// 3.1.1](http://tools.ietf.org/html/rfc2616#section-3.3.1
  /// "RFC-2616 section 3.1.1").
  ///
  static DateTime parse(String date) {
    final sp = 32;
    const wkdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final formatRfc1123 = 0;
    final formatRfc850 = 1;
    final formatAsctime = 2;

    var index = 0;
    String tmp;

    void expect(String s) {
      if (date.length - index < s.length) {
        throw Exception('Invalid HTTP date $date');
      }
      final tmp = date.substring(index, index + s.length);
      if (tmp != s) {
        throw Exception('Invalid HTTP date $date');
      }
      index += s.length;
    }

    int expectWeekday() {
      int weekday;
      // The formatting of the weekday signals the format of the date string.
      var pos = date.indexOf(',', index);
      if (pos == -1) {
        var pos = date.indexOf(' ', index);
        if (pos == -1) throw Exception('Invalid HTTP date $date');
        tmp = date.substring(index, pos);
        index = pos + 1;
        weekday = wkdays.indexOf(tmp);
        if (weekday != -1) {
          return formatAsctime;
        }
      } else {
        tmp = date.substring(index, pos);
        index = pos + 1;
        weekday = wkdays.indexOf(tmp);
        if (weekday != -1) {
          return formatRfc1123;
        }
        weekday = weekdays.indexOf(tmp);
        if (weekday != -1) {
          return formatRfc850;
        }
      }
      throw Exception('Invalid HTTP date $date');
    }

    int expectMonth(String separator) {
      var pos = date.indexOf(separator, index);
      if (pos - index != 3) throw Exception('Invalid HTTP date $date');
      tmp = date.substring(index, pos);
      index = pos + 1;
      var month = months.indexOf(tmp);
      if (month != -1) return month;
      throw Exception('Invalid HTTP date $date');
    }

    int expectNum(String separator) {
      int pos;
      if (separator.isNotEmpty) {
        pos = date.indexOf(separator, index);
      } else {
        pos = date.length;
      }
      var tmp = date.substring(index, pos);
      index = pos + separator.length;
      try {
        var value = int.parse(tmp);
        return value;
      } on FormatException {
        throw Exception('Invalid HTTP date $date');
      }
    }

    void expectEnd() {
      if (index != date.length) {
        throw Exception('Invalid HTTP date $date');
      }
    }

    var format = expectWeekday();
    int year;
    int month;
    int day;
    int hours;
    int minutes;
    int seconds;
    if (format == formatAsctime) {
      month = expectMonth(' ');
      if (date.codeUnitAt(index) == sp) index++;
      day = expectNum(' ');
      hours = expectNum(':');
      minutes = expectNum(':');
      seconds = expectNum(' ');
      year = expectNum('');
    } else {
      expect(' ');
      day = expectNum(format == formatRfc1123 ? ' ' : '-');
      month = expectMonth(format == formatRfc1123 ? ' ' : '-');
      year = expectNum(' ');
      hours = expectNum(':');
      minutes = expectNum(':');
      seconds = expectNum(' ');
      expect('GMT');
    }
    expectEnd();
    return DateTime.utc(year, month + 1, day, hours, minutes, seconds, 0);
  }
}
