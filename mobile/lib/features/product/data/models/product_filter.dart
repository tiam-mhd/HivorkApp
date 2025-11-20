import 'product.dart';

class _NoValue {
  const _NoValue();
}

class ProductFilter {
  final String? search;
  final ProductType? type;
  final ProductStatus? status;
  final ProductUnit? unit;
  final String? category;
  final String? brand;
  final double? minPrice;
  final double? maxPrice;
  final bool? lowStock;
  final bool? outOfStock;
  final int page;
  final int limit;

  ProductFilter({
    this.search,
    this.type,
    this.status,
    this.unit,
    this.category,
    this.brand,
    this.minPrice,
    this.maxPrice,
    this.lowStock,
    this.outOfStock,
    this.page = 1,
    this.limit = 20,
  });

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (type != null) params['type'] = type!.name;
    if (status != null) params['status'] = _statusToString(status!);
    if (unit != null) params['unit'] = _unitToString(unit!);
    if (category != null) params['category'] = category;
    if (brand != null) params['brand'] = brand;
    if (minPrice != null) params['minPrice'] = minPrice.toString();
    if (maxPrice != null) params['maxPrice'] = maxPrice.toString();
    if (lowStock == true) params['lowStock'] = 'true';
    if (outOfStock == true) params['outOfStock'] = 'true';

    return params;
  }

  String _statusToString(ProductStatus status) {
    switch (status) {
      case ProductStatus.active:
        return 'active';
      case ProductStatus.inactive:
        return 'inactive';
      case ProductStatus.outOfStock:
        return 'out_of_stock';
    }
  }

  String _unitToString(ProductUnit unit) {
    switch (unit) {
      case ProductUnit.piece:
        return 'piece';
      case ProductUnit.kilogram:
        return 'kilogram';
      case ProductUnit.gram:
        return 'gram';
      case ProductUnit.liter:
        return 'liter';
      case ProductUnit.meter:
        return 'meter';
      case ProductUnit.squareMeter:
        return 'square_meter';
      case ProductUnit.cubicMeter:
        return 'cubic_meter';
      case ProductUnit.box:
        return 'box';
      case ProductUnit.carton:
        return 'carton';
      case ProductUnit.pack:
        return 'pack';
      case ProductUnit.hour:
        return 'hour';
      case ProductUnit.day:
        return 'day';
      case ProductUnit.month:
        return 'month';
    }
  }

  ProductFilter copyWith({
    String? search,
    ProductType? type,
    ProductStatus? status,
    ProductUnit? unit,
    Object? category = const _NoValue(),
    String? brand,
    double? minPrice,
    double? maxPrice,
    bool? lowStock,
    bool? outOfStock,
    int? page,
    int? limit,
  }) {
    return ProductFilter(
      search: search ?? this.search,
      type: type ?? this.type,
      status: status ?? this.status,
      unit: unit ?? this.unit,
      category: category is _NoValue ? this.category : category as String?,
      brand: brand ?? this.brand,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      lowStock: lowStock ?? this.lowStock,
      outOfStock: outOfStock ?? this.outOfStock,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  ProductFilter clearFilters() {
    return ProductFilter(page: 1, limit: limit);
  }
}
