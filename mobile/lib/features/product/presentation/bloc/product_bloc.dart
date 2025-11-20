import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product.dart';
import '../../data/models/product_filter.dart';
import '../../data/repositories/product_repository.dart';
import 'product_event.dart';

export 'product_event.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;
  String? _currentBusinessId;
  ProductFilter? _currentFilter;

  ProductBloc(this.repository) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductById>(_onLoadProductById);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<UpdateProductStock>(_onUpdateStock);
    on<AdjustProductStock>(_onAdjustStock);
    on<UpdateProductStatus>(_onUpdateStatus);
    on<LoadProductStats>(_onLoadStats);
    on<LoadCategories>(_onLoadCategories);
    on<LoadBrands>(_onLoadBrands);
    on<ApplyFilter>(_onApplyFilter);
    on<ClearFilter>(_onClearFilter);
    on<SearchProducts>(_onSearchProducts);
    on<LoadNextPage>(_onLoadNextPage);
    on<RefreshProducts>(_onRefreshProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      _currentBusinessId = event.businessId;
      _currentFilter = event.filter;

      final result = await repository.getProducts(
        businessId: event.businessId,
        filter: event.filter,
      );

      final products = (result['data'] as List).cast<Product>();
      final total = result['total'] as int;
      final page = result['page'] as int;
      final limit = result['limit'] as int;
      final totalPages = (total / limit).ceil();
      final hasMore = page < totalPages;

      emit(ProductLoaded(
        products: products,
        total: total,
        currentPage: page,
        totalPages: totalPages,
        currentFilter: event.filter,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadProductById(
    LoadProductById event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      final product = await repository.getProductById(event.id);
      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      final product = await repository.createProduct(event.productData);
      emit(ProductOperationSuccess('محصول با موفقیت ایجاد شد', product: product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      final product = await repository.updateProduct(event.id, event.updates);
      emit(ProductOperationSuccess('محصول با موفقیت بروزرسانی شد', product: product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      await repository.deleteProduct(event.id);
      emit(const ProductOperationSuccess('محصول با موفقیت حذف شد'));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onUpdateStock(
    UpdateProductStock event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      final product = await repository.updateStock(event.id, event.quantity);
      emit(ProductOperationSuccess('موجودی بروزرسانی شد', product: product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onAdjustStock(
    AdjustProductStock event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      final product = await repository.adjustStock(event.id, event.adjustment);
      emit(ProductOperationSuccess('موجودی تنظیم شد', product: product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateProductStatus event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      final product = await repository.updateStatus(event.id, event.status);
      emit(ProductOperationSuccess('وضعیت بروزرسانی شد', product: product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadStats(
    LoadProductStats event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final stats = await repository.getProductStats(event.businessId);
      emit(ProductStatsLoaded(stats));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final categories = await repository.getCategories(event.businessId);
      emit(ProductCategoriesLoaded(categories));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadBrands(
    LoadBrands event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final brands = await repository.getBrands(event.businessId);
      emit(ProductBrandsLoaded(brands));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onApplyFilter(
    ApplyFilter event,
    Emitter<ProductState> emit,
  ) async {
    if (_currentBusinessId == null) return;

    try {
      emit(ProductLoading());
      _currentFilter = event.filter;

      final result = await repository.getProducts(
        businessId: _currentBusinessId!,
        filter: event.filter,
      );

      final products = (result['data'] as List).cast<Product>();
      final total = result['total'] as int;
      final page = result['page'] as int;
      final limit = result['limit'] as int;
      final totalPages = (total / limit).ceil();
      final hasMore = page < totalPages;

      emit(ProductLoaded(
        products: products,
        total: total,
        currentPage: page,
        totalPages: totalPages,
        currentFilter: event.filter,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onClearFilter(
    ClearFilter event,
    Emitter<ProductState> emit,
  ) async {
    if (_currentBusinessId == null) return;

    try {
      emit(ProductLoading());
      _currentFilter = null;

      final result = await repository.getProducts(
        businessId: _currentBusinessId!,
      );

      final products = (result['data'] as List).cast<Product>();
      final total = result['total'] as int;
      final page = result['page'] as int;
      final limit = result['limit'] as int;
      final totalPages = (total / limit).ceil();
      final hasMore = page < totalPages;

      emit(ProductLoaded(
        products: products,
        total: total,
        currentPage: page,
        totalPages: totalPages,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (_currentBusinessId == null) return;

    try {
      emit(ProductLoading());
      final filter = ProductFilter(search: event.query);
      _currentFilter = filter;

      final result = await repository.getProducts(
        businessId: _currentBusinessId!,
        filter: filter,
      );

      final products = (result['data'] as List).cast<Product>();
      final total = result['total'] as int;
      final page = result['page'] as int;
      final limit = result['limit'] as int;
      final totalPages = (total / limit).ceil();
      final hasMore = page < totalPages;

      emit(ProductLoaded(
        products: products,
        total: total,
        currentPage: page,
        totalPages: totalPages,
        currentFilter: filter,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadNextPage(
    LoadNextPage event,
    Emitter<ProductState> emit,
  ) async {
    if (state is! ProductLoaded || _currentBusinessId == null) return;

    final currentState = state as ProductLoaded;
    if (!currentState.hasMore) return;

    try {
      emit(ProductLoadingMore(currentState.products));

      final nextPage = currentState.currentPage + 1;
      final filter = _currentFilter?.copyWith(page: nextPage) ??
          ProductFilter(page: nextPage);

      final result = await repository.getProducts(
        businessId: _currentBusinessId!,
        filter: filter,
      );

      final newProducts = (result['data'] as List).cast<Product>();
      final total = result['total'] as int;
      final page = result['page'] as int;
      final limit = result['limit'] as int;
      final totalPages = (total / limit).ceil();
      final hasMore = page < totalPages;

      emit(ProductLoaded(
        products: [...currentState.products, ...newProducts],
        total: total,
        currentPage: page,
        totalPages: totalPages,
        currentFilter: _currentFilter,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (_currentBusinessId == null) return;

    try {
      final result = await repository.getProducts(
        businessId: _currentBusinessId!,
        filter: _currentFilter,
      );

      final products = (result['data'] as List).cast<Product>();
      final total = result['total'] as int;
      final page = result['page'] as int;
      final limit = result['limit'] as int;
      final totalPages = (total / limit).ceil();
      final hasMore = page < totalPages;

      emit(ProductLoaded(
        products: products,
        total: total,
        currentPage: page,
        totalPages: totalPages,
        currentFilter: _currentFilter,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
