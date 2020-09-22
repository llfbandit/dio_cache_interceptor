import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import './model/cache_response.dart';
import './store/cache_store.dart';
import 'content_serialization.dart';
import 'model/cache_options.dart';

class DioCacheInterceptor extends Interceptor {
  static const String _getMethodName = 'GET';

  final CacheOptions options;
  final CacheStore _store;

  DioCacheInterceptor({@required this.options})
      : assert(options != null),
        _store = options.store;

  @override
  Future<dynamic> onRequest(RequestOptions request) async {
    if (_shouldSkipRequest(request.method)) {
      return super.onRequest(request);
    }

    final options = _getCacheOptions(request);

    if (options.policy == CachePolicy.refresh) {
      return super.onRequest(request);
    }

    final cacheResp = await _getCacheResponse(request);
    if (cacheResp != null) {
      if (options.policy == CachePolicy.cacheFirst ||
          options.policy == CachePolicy.cacheStoreForce) {
        return cacheResp.toResponse(request);
      }

      // Update request with cache directives
      _addCacheDirectives(request, cacheResp);
    }

    return super.onRequest(request);
  }

  @override
  Future<dynamic> onResponse(Response response) async {
    if (_shouldSkipRequest(response.request.method)) {
      return super.onResponse(response);
    }

    // Don't cache response
    if (response.statusCode != HttpStatus.ok) {
      return super.onResponse(response);
    }

    final cacheOptions = _getCacheOptions(response.request);
    if (cacheOptions.policy == CachePolicy.cacheStoreNo) {
      return super.onResponse(response);
    }

    // Cache response into store
    if (cacheOptions.policy == CachePolicy.cacheStoreForce ||
        _hasCacheDirectives(response)) {
      final cacheResp = await _buildCacheResponse(
        cacheOptions.keyBuilder(response.request),
        cacheOptions,
        response,
      );

      await cacheOptions.store.set(cacheResp);
    }

    return super.onResponse(response);
  }

  @override
  Future<dynamic> onError(DioError err) async {
    if (_shouldSkipRequest(err.request.method)) {
      return super.onError(err);
    }

    // Retrieve response from cache
    if (err.response.statusCode == HttpStatus.notModified) {
      return _getResponse(err.request);
    }

    final cacheOpts = _getCacheOptions(err.request);

    // Check if we can return cache on error
    if (cacheOpts.hitCacheOnErrorExcept != null) {
      if (err.type == DioErrorType.RESPONSE) {
        if (cacheOpts.hitCacheOnErrorExcept.contains(err.response.statusCode)) {
          return super.onError(err);
        }
      }

      return _getResponse(err.request);
    }

    return super.onError(err);
  }

  void _addCacheDirectives(RequestOptions request, CacheResponse response) {
    if (response.eTag != null) {
      request.headers[HttpHeaders.etagHeader] = response.eTag;
    }
    if (response.lastModified != null) {
      request.headers[HttpHeaders.ifModifiedSinceHeader] =
          response.lastModified;
    }
  }

  bool _hasCacheDirectives(Response response) {
    var result = response.headers[HttpHeaders.etagHeader] != null;
    result |= response.headers[HttpHeaders.lastModifiedHeader] != null;
    return result;
  }

  CacheOptions _getCacheOptions(RequestOptions request) {
    return CacheOptions.fromExtra(request) ?? options;
  }

  bool _shouldSkipRequest(String method) {
    return (method.toUpperCase() != _getMethodName);
  }

  Future<CacheResponse> _buildCacheResponse(
    String key,
    CacheOptions options,
    Response response,
  ) async {
    return CacheResponse(
      key: key,
      url: response.request.uri.toString(),
      eTag: response.headers[HttpHeaders.etagHeader]?.first,
      lastModified: response.headers[HttpHeaders.lastModifiedHeader]?.first,
      maxStale: options.maxStale,
      content: await serializeContent(
        response.request.responseType,
        response.data,
      ),
      headers: utf8.encode(jsonEncode(response.headers.map)),
      priority: options.priority,
    );
  }

  Future<CacheResponse> _getCacheResponse(RequestOptions request) {
    final cacheOpts = _getCacheOptions(request);

    final cacheKey = cacheOpts.keyBuilder(request);
    final store = cacheOpts.store ?? _store;

    return store.get(cacheKey);
  }

  Future<Response> _getResponse(RequestOptions request) async {
    final existing = await _getCacheResponse(request);
    return existing?.toResponse(request);
  }
}
