class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException($message, code: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache operation failed']);

  @override
  String toString() => 'CacheException($message)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Network unavailable']);

  @override
  String toString() => 'NetworkException($message)';
}
