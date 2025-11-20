import '../models/product.dart';
import '../models/product_filter.dart';
import '../models/product_stats.dart';
import '../services/product_api_service.dart';

class ProductRepository {
  final ProductApiService _apiService;

  ProductRepository(this._apiService);

  Future<Product> createProduct(Map<String, dynamic> productData) async {
    return await _apiService.createProduct(productData);
  }

  Future<Map<String, dynamic>> getProducts({
    required String businessId,
    ProductFilter? filter,
  }) async {
    return await _apiService.getProducts(
      businessId: businessId,
      filter: filter,
    );
  }

  Future<Product> getProductById(String id) async {
    return await _apiService.getProductById(id);
  }

  Future<Product> updateProduct(String id, Map<String, dynamic> updates) async {
    return await _apiService.updateProduct(id, updates);
  }

  Future<void> deleteProduct(String id) async {
    return await _apiService.deleteProduct(id);
  }

  Future<Product> updateStock(String id, double quantity) async {
    return await _apiService.updateStock(id, quantity);
  }

  Future<Product> adjustStock(String id, double adjustment) async {
    return await _apiService.adjustStock(id, adjustment);
  }

  Future<Product> updateStatus(String id, ProductStatus status) async {
    return await _apiService.updateStatus(id, status);
  }

  Future<ProductStats> getProductStats(String businessId) async {
    return await _apiService.getProductStats(businessId);
  }

  Future<List<String>> getCategories(String businessId) async {
    return await _apiService.getCategories(businessId);
  }

  Future<List<String>> getBrands(String businessId) async {
    return await _apiService.getBrands(businessId);
  }

  Future<Product> uploadImage(String id, String imageUrl) async {
    return await _apiService.uploadImage(id, imageUrl);
  }

  Future<Product> removeImage(String id, String imageUrl) async {
    return await _apiService.removeImage(id, imageUrl);
  }
}
