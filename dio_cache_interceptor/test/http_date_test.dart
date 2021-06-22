// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dio_cache_interceptor/src/util/http_date.dart';
import 'package:test/test.dart';

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
  test('parseHttpDate', testParseHttpDate);
  test('parseHttpDateFailures', testParseHttpDateFailures);
}
