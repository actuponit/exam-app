import 'package:dio/dio.dart';
import 'package:exam_app/core/di/cache_interceptor.dart';
import 'package:exam_app/core/services/hive_service.dart';
import 'package:injectable/injectable.dart';

@module
abstract class NetworkModule {
  @singleton
  Dio dio(HiveService hiveService) {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://ethioexamhub.com/api/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    final cacheBox = hiveService.cacheBox;

    // Add interceptors
    dio.interceptors.addAll([
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
      CacheInterceptor(cacheBox: cacheBox),
      InterceptorsWrapper(
        onError: (error, handler) {
          String errorMessage = 'An unexpected error occurred';

          if (error.type == DioExceptionType.connectionTimeout) {
            errorMessage =
                'Connection timed out. Please check your internet connection';
          } else if (error.type == DioExceptionType.sendTimeout) {
            errorMessage = 'Request timed out while sending data';
          } else if (error.type == DioExceptionType.receiveTimeout) {
            errorMessage = 'Request timed out while receiving data';
          } else if (error.type == DioExceptionType.badResponse) {
            if (error.response?.statusCode == 401) {
              errorMessage = 'Unauthorized access. Please login again';
            } else if (error.response?.statusCode == 404) {
              errorMessage = 'Requested resource not found';
            } else if (error.response?.statusCode == 500) {
              errorMessage = 'Server error. Please try again later';
            } else {
              errorMessage = 'Invalid server response';
            }
          } else if (error.type == DioExceptionType.cancel) {
            errorMessage = 'Request was cancelled';
          } else if (error.type == DioExceptionType.connectionError) {
            errorMessage =
                'No internet connection. Please check your network settings';
          }

          error = error.copyWith(message: errorMessage);
          return handler.next(error);
        },
      ),
    ]);

    return dio;
  }
}
