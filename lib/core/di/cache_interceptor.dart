import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'cache_item.dart';

class CacheInterceptor extends Interceptor {
  final Box<CacheItem> cacheBox;

  CacheInterceptor({required this.cacheBox});

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final cacheKey = options.uri.toString();
    final useCache = options.extra['useCache'] ?? false;
    final cacheDuration = options.extra['cacheDuration'];

    if (useCache && cacheBox.containsKey(cacheKey)) {
      final cached = cacheBox.get(cacheKey)!;

      final isExpired = cacheDuration != null &&
          DateTime.now().difference(cached.timestamp) > cacheDuration;

      if (!isExpired) {
        debugPrint("🚀 [useCache=true] Serving from cache: $cacheKey");
        final data = jsonDecode(cached.data);
        return handler.resolve(Response(
          requestOptions: options,
          data: data,
          statusCode: 200,
        ));
      } else if (isExpired) {
        debugPrint("⏰ [Cache expired] Removing: $cacheKey");
        await cacheBox.delete(cacheKey);
      }
      handler.next(options.copyWith(extra: {
        'cacheResponse': true,
      }));
      return;
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final cacheKey = response.requestOptions.uri.toString();
    final shouldCache = response.requestOptions.extra['cacheResponse'] ?? false;

    if (shouldCache) {
      final dataString = jsonEncode(response.data);
      final cacheItem = CacheItem(
        key: cacheKey,
        data: dataString,
        timestamp: DateTime.now(),
      );
      await cacheBox.put(cacheKey, cacheItem);
      debugPrint("💾 [cacheResponse=true] Cached: $cacheKey");
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final cacheKey = err.requestOptions.uri.toString();
    final useCache = err.requestOptions.extra['useCache'] ?? false;

    if (useCache && cacheBox.containsKey(cacheKey)) {
      final cached = cacheBox.get(cacheKey)!;
      final data = jsonDecode(cached.data);
      debugPrint("📡 [Offline fallback] Serving cached response: $cacheKey");
      return handler.resolve(Response(
        requestOptions: err.requestOptions,
        data: data,
        statusCode: 200,
      ));
    }

    handler.next(err);
  }
}
