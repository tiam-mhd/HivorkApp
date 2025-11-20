class CustomerFilter {
  final String? search;
  final String? type;
  final String? status;
  final String? groupId;
  final String? category;
  final String? source;
  final String? city;
  final String? province;
  final String? tag;
  final double? minPurchases;
  final double? maxPurchases;
  final bool? hasDebt;
  final bool? hasCredit;
  final int page;
  final int limit;

  CustomerFilter({
    this.search,
    this.type,
    this.status,
    this.groupId,
    this.category,
    this.source,
    this.city,
    this.province,
    this.tag,
    this.minPurchases,
    this.maxPurchases,
    this.hasDebt,
    this.hasCredit,
    this.page = 1,
    this.limit = 20,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      if (search != null && search!.isNotEmpty) 'search': search,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (groupId != null) 'groupId': groupId,
      if (category != null) 'category': category,
      if (source != null) 'source': source,
      if (city != null) 'city': city,
      if (province != null) 'province': province,
      if (tag != null) 'tag': tag,
      if (minPurchases != null) 'minPurchases': minPurchases,
      if (maxPurchases != null) 'maxPurchases': maxPurchases,
      if (hasDebt != null) 'hasDebt': hasDebt,
      if (hasCredit != null) 'hasCredit': hasCredit,
      'page': page,
      'limit': limit,
    };
  }

  CustomerFilter copyWith({
    String? search,
    String? type,
    String? status,
    String? groupId,
    String? category,
    String? source,
    String? city,
    String? province,
    String? tag,
    double? minPurchases,
    double? maxPurchases,
    bool? hasDebt,
    bool? hasCredit,
    int? page,
    int? limit,
  }) {
    return CustomerFilter(
      search: search ?? this.search,
      type: type ?? this.type,
      status: status ?? this.status,
      groupId: groupId ?? this.groupId,
      category: category ?? this.category,
      source: source ?? this.source,
      city: city ?? this.city,
      province: province ?? this.province,
      tag: tag ?? this.tag,
      minPurchases: minPurchases ?? this.minPurchases,
      maxPurchases: maxPurchases ?? this.maxPurchases,
      hasDebt: hasDebt ?? this.hasDebt,
      hasCredit: hasCredit ?? this.hasCredit,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  bool get hasActiveFilters =>
      (search != null && search!.isNotEmpty) ||
      type != null ||
      status != null ||
      groupId != null ||
      category != null ||
      source != null ||
      city != null ||
      province != null ||
      tag != null ||
      minPurchases != null ||
      maxPurchases != null ||
      hasDebt != null ||
      hasCredit != null;
}
