import 'package:equatable/equatable.dart';
import '../../data/models/product.dart';
import '../../data/models/product_filter.dart';
import '../../data/models/product_stats.dart';

// Events
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final String businessId;
  final ProductFilter? filter;

  const LoadProducts(this.businessId, {this.filter});

  @override
  List<Object?> get props => [businessId, filter];
}

class LoadProductById extends ProductEvent {
  final String id;

  const LoadProductById(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateProduct extends ProductEvent {
  final Map<String, dynamic> productData;

  const CreateProduct(this.productData);

  @override
  List<Object?> get props => [productData];
}

class UpdateProduct extends ProductEvent {
  final String id;
  final Map<String, dynamic> updates;

  const UpdateProduct(this.id, this.updates);

  @override
  List<Object?> get props => [id, updates];
}

class DeleteProduct extends ProductEvent {
  final String id;

  const DeleteProduct(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateProductStock extends ProductEvent {
  final String id;
  final double quantity;

  const UpdateProductStock(this.id, this.quantity);

  @override
  List<Object?> get props => [id, quantity];
}

class AdjustProductStock extends ProductEvent {
  final String id;
  final double adjustment;

  const AdjustProductStock(this.id, this.adjustment);

  @override
  List<Object?> get props => [id, adjustment];
}

class UpdateProductStatus extends ProductEvent {
  final String id;
  final ProductStatus status;

  const UpdateProductStatus(this.id, this.status);

  @override
  List<Object?> get props => [id, status];
}

class LoadProductStats extends ProductEvent {
  final String businessId;

  const LoadProductStats(this.businessId);

  @override
  List<Object?> get props => [businessId];
}

class LoadCategories extends ProductEvent {
  final String businessId;

  const LoadCategories(this.businessId);

  @override
  List<Object?> get props => [businessId];
}

class LoadBrands extends ProductEvent {
  final String businessId;

  const LoadBrands(this.businessId);

  @override
  List<Object?> get props => [businessId];
}

class ApplyFilter extends ProductEvent {
  final ProductFilter filter;

  const ApplyFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ClearFilter extends ProductEvent {}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadNextPage extends ProductEvent {}

class RefreshProducts extends ProductEvent {}

// States
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final int total;
  final int currentPage;
  final int totalPages;
  final ProductFilter? currentFilter;
  final bool hasMore;

  const ProductLoaded({
    required this.products,
    required this.total,
    required this.currentPage,
    required this.totalPages,
    this.currentFilter,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [
        products,
        total,
        currentPage,
        totalPages,
        currentFilter,
        hasMore,
      ];

  ProductLoaded copyWith({
    List<Product>? products,
    int? total,
    int? currentPage,
    int? totalPages,
    ProductFilter? currentFilter,
    bool? hasMore,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      currentFilter: currentFilter ?? this.currentFilter,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ProductDetailLoaded extends ProductState {
  final Product product;

  const ProductDetailLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductStatsLoaded extends ProductState {
  final ProductStats stats;

  const ProductStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class ProductCategoriesLoaded extends ProductState {
  final List<String> categories;

  const ProductCategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class ProductBrandsLoaded extends ProductState {
  final List<String> brands;

  const ProductBrandsLoaded(this.brands);

  @override
  List<Object?> get props => [brands];
}

class ProductOperationSuccess extends ProductState {
  final String message;
  final Product? product;

  const ProductOperationSuccess(this.message, {this.product});

  @override
  List<Object?> get props => [message, product];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductLoadingMore extends ProductState {
  final List<Product> currentProducts;

  const ProductLoadingMore(this.currentProducts);

  @override
  List<Object?> get props => [currentProducts];
}
