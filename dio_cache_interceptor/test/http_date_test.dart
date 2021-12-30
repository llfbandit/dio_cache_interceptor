// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dio_cache_interceptor/src/util/http_date.dart';
import 'package:test/test.dart';

void testFormatParseHttpDate() {
  test(
    int year,
    int month,
    int day,
    int hours,
    int minutes,
    int seconds,
    String expectedFormatted,
  ) {
    final date = DateTime.utc(year, month, day, hours, minutes, seconds, 0);
    final formatted = HttpDate.format(date);
    expect(expectedFormatted, equals(formatted));
    expect(date, equals(HttpDate.parse(formatted)));
  }

  test(1999, DateTime.june, 11, 18, 46, 53, "Fri, 11 Jun 1999 18:46:53 GMT");
  test(1970, DateTime.january, 1, 0, 0, 0, "Thu, 01 Jan 1970 00:00:00 GMT");
  test(1970, DateTime.january, 1, 9, 9, 9, "Thu, 01 Jan 1970 09:09:09 GMT");
  test(2012, DateTime.march, 5, 23, 59, 59, "Mon, 05 Mar 2012 23:59:59 GMT");
}

void testParseHttpDate() {
  DateTime date;
  date = DateTime.utc(1999, DateTime.june, 11, 18, 46, 53, 0);
  expect(date, HttpDate.parse('Fri, 11 Jun 1999 18:46:53 GMT'));
  expect(date, HttpDate.parse('Friday, 11-Jun-1999 18:46:53 GMT'));
  expect(date, HttpDate.parse('Fri Jun 11 18:46:53 1999'));

  date = DateTime.utc(1970, DateTime.january, 1, 0, 0, 0, 0);
  expect(date, HttpDate.parse('Thu, 1 Jan 1970 00:00:00 GMT'));
  expect(date, HttpDate.parse('Thursday, 1-Jan-1970 00:00:00 GMT'));
  expect(date, HttpDate.parse('Thu Jan  1 00:00:00 1970'));

  date = DateTime.utc(2012, DateTime.march, 5, 23, 59, 59, 0);
  expect(date, HttpDate.parse('Mon, 5 Mar 2012 23:59:59 GMT'));
  expect(date, HttpDate.parse('Monday, 5-Mar-2012 23:59:59 GMT'));
  expect(date, HttpDate.parse('Mon Mar  5 23:59:59 2012'));
}

void testParseHttpDateFailures() {
  // The calls below can throw different exceptions based on the iteration of
  // the loop. This matcher catches all exceptions.
  final throws = throwsA(TypeMatcher<Object>());
  expect(() {
    HttpDate.parse('');
  }, throws);
  var valid = 'Mon, 5 Mar 2012 23:59:59 GMT';
  for (var i = 1; i < valid.length - 1; i++) {
    var tmp = valid.substring(0, i);
    expect(() {
      HttpDate.parse(tmp);
    }, throws);
    expect(() {
      HttpDate.parse(' $tmp');
    }, throws);
    expect(() {
      HttpDate.parse(' $tmp ');
    }, throws);
    expect(() {
      HttpDate.parse('$tmp ');
    }, throws);
  }
  expect(() {
    HttpDate.parse(' $valid');
  }, throws);
  expect(() {
    HttpDate.parse(' $valid ');
  }, throws);
  expect(() {
    HttpDate.parse('$valid ');
  }, throws);
}

void main() {
  test('formatParseHttpDate', testFormatParseHttpDate);
  test('parseHttpDate', testParseHttpDate);
  test('parseHttpDateFailures', testParseHttpDateFailures);
}
