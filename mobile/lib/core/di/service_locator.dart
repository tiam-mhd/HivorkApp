import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  FlutterSecureStorage? _secureStorage;
  Dio? _dio;

  void init(FlutterSecureStorage secureStorage, Dio dio) {
    _secureStorage = secureStorage;
    _dio = dio;
  }

  FlutterSecureStorage get secureStorage {
    if (_secureStorage == null) {
      throw Exception('ServiceLocator not initialized. Call init() first.');
    }
    return _secureStorage!;
  }

  Dio get dio {
    if (_dio == null) {
      throw Exception('ServiceLocator not initialized. Call init() first.');
    }
    return _dio!;
  }
}
