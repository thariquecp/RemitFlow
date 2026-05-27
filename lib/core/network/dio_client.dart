import 'package:dio/dio.dart';
import 'package:fintech_app/core/constants/api_constants.dart';
import 'package:fintech_app/core/errors/exceptions.dart';

/// Configures and provides a [Dio] instance with timeout handling,
/// error interception, and optional request logging.
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      _ErrorInterceptor(),
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (obj) {
          assert(() {
            // ignore: avoid_print
            print('[Dio] $obj');
            return true;
          }());
        },
      ),
    ]);
  }

  Dio get dio => _dio;
}

/// Interceptor that normalizes Dio errors into our [ServerException] type.
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw ServerException(
          'Request timed out. Please try again.',
          statusCode: err.response?.statusCode,
        );

      case DioExceptionType.connectionError:
        throw const NetworkException('Unable to connect to server');

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        final data = err.response?.data;
        final message = data is Map ? data['message'] as String? : null;
        throw ServerException(
          message ?? 'Server returned error $statusCode',
          statusCode: statusCode,
        );

      default:
        throw ServerException(
          err.message ?? 'An unexpected error occurred',
          statusCode: err.response?.statusCode,
        );
    }
  }
}
