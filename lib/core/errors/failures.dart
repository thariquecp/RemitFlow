/// Failure types used across the application.
sealed class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => 'Failure($message, statusCode: $statusCode)';
}

/// Failure originating from the remote API.
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

/// Failure when reading from or writing to local cache.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Failure when the device has no internet connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Failure when an API response cannot be parsed.
class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Failed to parse response']);
}

/// Failure when the cached data has expired.
class StaleDataFailure extends Failure {
  const StaleDataFailure([super.message = 'Cached data is stale']);
}
