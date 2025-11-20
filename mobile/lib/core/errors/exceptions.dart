class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({
    required this.message,
    this.statusCode,
  });
}

class NetworkException implements Exception {}

class CacheException implements Exception {}

class UnauthorizedException implements Exception {}
