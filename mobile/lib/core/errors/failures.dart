class Failure {
  final String message;
  final int? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure()
      : super(message: 'خطا در برقراری ارتباط با سرور. لطفا اتصال اینترنت خود را بررسی کنید.');
}

class CacheFailure extends Failure {
  const CacheFailure()
      : super(message: 'خطا در دسترسی به حافظه محلی');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure()
      : super(
          message: 'دسترسی غیرمجاز. لطفا مجددا وارد شوید.',
          statusCode: 401,
        );
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
