import 'package:universal_io/io.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import '../../../../core/utils/logger.dart';

/// سرویس آپلود تصاویر محصولات، تنوع‌ها و ویژگی‌ها
class ImageUploadService {
  final Dio _dio;

  ImageUploadService(this._dio);

  /// آپلود عکس اصلی محصول
  Future<Map<String, dynamic>> uploadProductMainImage({
    required String productId,
    required File imageFile,
    Uint8List? imageBytes, // برای وب
  }) async {
    try {
      Logger.info('=== Starting main image upload for product: $productId ===');
      Logger.info('Platform: ${kIsWeb ? "WEB" : "MOBILE"}');
      Logger.info('File path: ${imageFile.path}');

      final fileExtension = path.extension(imageFile.path).toLowerCase();
      final mimeType = _getMimeType(fileExtension);
      
      // برای وب، نام فایل بر اساس timestamp + extension
      final fileName = kIsWeb 
          ? 'image_${DateTime.now().millisecondsSinceEpoch}${fileExtension.isEmpty ? '.jpg' : fileExtension}'
          : path.basename(imageFile.path);
      
      Logger.info('File name: $fileName');
      Logger.info('MIME type: $mimeType');

      MultipartFile multipartFile;
      
      if (kIsWeb) {
        Logger.info('Creating multipart from bytes (WEB mode)');
        if (imageBytes == null) {
          throw Exception('imageBytes is required for web platform');
        }
        Logger.info('Bytes provided: ${imageBytes.length}');
        
        multipartFile = MultipartFile.fromBytes(
          imageBytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        );
        Logger.success('Multipart file created from bytes');
      } else {
        Logger.info('Creating multipart from file (MOBILE mode)');
        multipartFile = await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        );
        Logger.success('Multipart file created from path');
      }

      final formData = FormData.fromMap({
        'file': multipartFile,
      });
      
      Logger.info('Sending POST request to: /products/$productId/images/main');

      final response = await _dio.post(
        '/products/$productId/images/main',
        data: formData,
      );
      
      Logger.info('Response status: ${response.statusCode}');
      Logger.success('Main image uploaded successfully');
      
      return response.data;
    } catch (e, stackTrace) {
      Logger.error('Error uploading main image', e);
      Logger.error('Stack trace', stackTrace);
      rethrow;
    }
  }

  /// آپلود عکس‌های اضافی محصول (حداکثر 10 تا)
  Future<Map<String, dynamic>> uploadProductImages({
    required String productId,
    required List<File> imageFiles,
    List<Uint8List>? imageBytesList, // برای وب
  }) async {
    if (imageFiles.length > 10) {
      throw Exception('Maximum 10 images allowed for product');
    }

    try {
      Logger.info('=== Uploading ${imageFiles.length} images for product: $productId ===');
      Logger.info('Platform: ${kIsWeb ? "WEB" : "MOBILE"}');

      final files = <MultipartFile>[];
      for (var i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        final fileExtension = path.extension(imageFile.path).toLowerCase();
        final mimeType = _getMimeType(fileExtension);
        
        // برای وب، نام فایل بر اساس timestamp + extension
        final fileName = kIsWeb
            ? 'image_${DateTime.now().millisecondsSinceEpoch}_$i${fileExtension.isEmpty ? '.jpg' : fileExtension}'
            : path.basename(imageFile.path);
        
        Logger.info('Processing file ${i + 1}/${imageFiles.length}: $fileName');

        if (kIsWeb) {
          if (imageBytesList == null || i >= imageBytesList.length) {
            throw Exception('imageBytesList is required for web platform');
          }
          final bytes = imageBytesList[i];
          Logger.info('  Bytes provided: ${bytes.length}');
          
          files.add(MultipartFile.fromBytes(
            bytes,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ));
        } else {
          files.add(await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ));
        }
      }
      
      Logger.info('All files prepared, creating form data');

      final formData = FormData.fromMap({
        'files': files,
      });
      
      Logger.info('Sending POST request to: /products/$productId/images');

      final response = await _dio.post(
        '/products/$productId/images',
        data: formData,
      );
      
      Logger.info('Response status: ${response.statusCode}');
      Logger.success('Images uploaded successfully');
      
      return response.data;
    } catch (e, stackTrace) {
      Logger.error('Error uploading images', e);
      Logger.error('Stack trace', stackTrace);
      rethrow;
    }
  }

  /// حذف عکس اصلی محصول
  Future<void> deleteProductMainImage({required String productId}) async {
    try {
      Logger.info('Deleting main image for product: $productId');
      await _dio.delete('/products/$productId/images/main');
      Logger.success('Main image deleted successfully');
    } catch (e) {
      Logger.error('Error deleting main image', e);
      rethrow;
    }
  }

  /// حذف یک عکس خاص محصول
  Future<void> deleteProductImage({
    required String productId,
    required String filename,
  }) async {
    try {
      Logger.info('Deleting image $filename for product: $productId');
      await _dio.delete('/products/$productId/images/$filename');
      Logger.success('Image deleted successfully');
    } catch (e) {
      Logger.error('Error deleting image', e);
      rethrow;
    }
  }

  /// آپلود عکس اصلی تنوع
  Future<Map<String, dynamic>> uploadVariantMainImage({
    required String productId,
    required String variantId,
    required File imageFile,
    Uint8List? imageBytes, // برای وب
  }) async {
    try {
      Logger.info('=== Uploading main image for variant: $variantId ===');
      Logger.info('Platform: ${kIsWeb ? "WEB" : "MOBILE"}');
      Logger.info('File path: ${imageFile.path}');

      final fileExtension = path.extension(imageFile.path).toLowerCase();
      final mimeType = _getMimeType(fileExtension);
      
      final fileName = kIsWeb
          ? 'variant_${DateTime.now().millisecondsSinceEpoch}${fileExtension.isEmpty ? '.jpg' : fileExtension}'
          : path.basename(imageFile.path);
      
      Logger.info('File name: $fileName');

      MultipartFile multipartFile;
      
      if (kIsWeb) {
        Logger.info('Creating multipart from bytes (WEB mode)');
        if (imageBytes == null) {
          throw Exception('imageBytes is required for web platform');
        }
        Logger.info('Bytes provided: ${imageBytes.length}');
        
        multipartFile = MultipartFile.fromBytes(
          imageBytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        );
      } else {
        multipartFile = await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        );
      }

      final formData = FormData.fromMap({
        'file': multipartFile,
      });
      
      Logger.info('Sending POST request');

      final response = await _dio.post(
        '/products/$productId/variants/$variantId/images/main',
        data: formData,
      );
      
      Logger.info('Response status: ${response.statusCode}');
      Logger.success('Variant main image uploaded successfully');
      
      return response.data;
    } catch (e, stackTrace) {
      Logger.error('Error uploading variant main image', e);
      Logger.error('Stack trace', stackTrace);
      rethrow;
    }
  }

  /// آپلود عکس‌های اضافی تنوع (حداکثر 3 تا)
  Future<Map<String, dynamic>> uploadVariantImages({
    required String productId,
    required String variantId,
    required List<File> imageFiles,
    List<Uint8List>? imageBytesList, // برای وب
  }) async {
    if (imageFiles.length > 3) {
      throw Exception('Maximum 3 images allowed for variant');
    }

    try {
      Logger.info('=== Uploading ${imageFiles.length} images for variant: $variantId ===');
      Logger.info('Platform: ${kIsWeb ? "WEB" : "MOBILE"}');

      final files = <MultipartFile>[];
      for (var i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        final fileExtension = path.extension(imageFile.path).toLowerCase();
        final mimeType = _getMimeType(fileExtension);
        
        final fileName = kIsWeb
            ? 'variant_${DateTime.now().millisecondsSinceEpoch}_$i${fileExtension.isEmpty ? '.jpg' : fileExtension}'
            : path.basename(imageFile.path);
        
        Logger.info('Processing file ${i + 1}/${imageFiles.length}: $fileName');

        if (kIsWeb) {
          if (imageBytesList == null || i >= imageBytesList.length) {
            throw Exception('imageBytesList is required for web platform');
          }
          final bytes = imageBytesList[i];
          Logger.info('  Bytes provided: ${bytes.length}');
          
          files.add(MultipartFile.fromBytes(
            bytes,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ));
        } else {
          files.add(await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ));
        }
      }

      final formData = FormData.fromMap({
        'files': files,
      });
      
      Logger.info('Sending POST request');

      final response = await _dio.post(
        '/products/$productId/variants/$variantId/images',
        data: formData,
      );
      
      Logger.info('Response status: ${response.statusCode}');
      Logger.success('Variant images uploaded successfully');
      
      return response.data;
    } catch (e, stackTrace) {
      Logger.error('Error uploading variant images', e);
      Logger.error('Stack trace', stackTrace);
      rethrow;
    }
  }

  /// حذف عکس اصلی تنوع
  Future<void> deleteVariantMainImage({
    required String productId,
    required String variantId,
  }) async {
    try {
      Logger.info('Deleting main image for variant: $variantId');
      await _dio.delete(
        '/products/$productId/variants/$variantId/images/main',
      );
      Logger.success('Variant main image deleted successfully');
    } catch (e) {
      Logger.error('Error deleting variant main image', e);
      rethrow;
    }
  }

  /// حذف یک عکس خاص تنوع
  Future<void> deleteVariantImage({
    required String productId,
    required String variantId,
    required String filename,
  }) async {
    try {
      Logger.info('Deleting image $filename for variant: $variantId');
      await _dio.delete(
        '/products/$productId/variants/$variantId/images/$filename',
      );
      Logger.success('Variant image deleted successfully');
    } catch (e) {
      Logger.error('Error deleting variant image', e);
      rethrow;
    }
  }

  /// بدست آوردن URL کامل عکس
  String getImageUrl(String imagePath) {
    // اگر imagePath از قبل URL کامل است
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // اگر نه، از baseUrl استفاده کن
    final baseUrl = _dio.options.baseUrl;
    return '$baseUrl/$imagePath';
  }

  /// تعیین MIME Type بر اساس پسوند فایل
  String _getMimeType(String extension) {
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
