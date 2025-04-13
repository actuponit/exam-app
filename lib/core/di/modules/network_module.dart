import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class NetworkModule {
  @singleton
  Dio get dio {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://ethioexamhub.com/api/',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

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
      InterceptorsWrapper(
        onError: (error, handler) {
          // Handle errors here
          return handler.next(error);
        },
      ),
    ]);

    return dio;
  }
} 