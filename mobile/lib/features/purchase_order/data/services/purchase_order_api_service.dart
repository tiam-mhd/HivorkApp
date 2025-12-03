import 'package:dio/dio.dart';
import '../dtos/purchase_order_dtos.dart';
import '../models/purchase_order_model.dart';

/// Purchase Order API Service
/// مطابق 100% با backend: purchase-order.controller.ts
class PurchaseOrderApiService {
  final Dio dio;

  PurchaseOrderApiService(this.dio);

  /// Create Purchase Order
  /// POST /api/purchase-orders?businessId={businessId}
  Future<PurchaseOrderModel> createPurchaseOrder(
    CreatePurchaseOrderDto dto,
    String businessId,
  ) async {
    final response = await dio.post(
      '/purchase-orders',
      data: dto.toJson(),
      queryParameters: {'businessId': businessId},
    );
    return PurchaseOrderModel.fromJson(response.data);
  }

  /// Get All Purchase Orders
  /// GET /api/purchase-orders?businessId={businessId}&[filters]
  Future<PurchaseOrderListResponse> getPurchaseOrders(
    String businessId, {
    String? supplierId,
    String? status,
    String? orderNumber,
    String? dateFrom,
    String? dateTo,
    double? minTotal,
    double? maxTotal,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = <String, dynamic>{
      'businessId': businessId,
      if (supplierId != null) 'supplierId': supplierId,
      if (status != null) 'status': status,
      if (orderNumber != null) 'orderNumber': orderNumber,
      if (dateFrom != null) 'dateFrom': dateFrom,
      if (dateTo != null) 'dateTo': dateTo,
      if (minTotal != null) 'minTotal': minTotal,
      if (maxTotal != null) 'maxTotal': maxTotal,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
    };

    final response = await dio.get(
      '/purchase-orders',
      queryParameters: queryParams,
    );
    return PurchaseOrderListResponse.fromJson(response.data);
  }

  /// Get Purchase Order Statistics
  /// GET /api/purchase-orders/stats?businessId={businessId}
  Future<PurchaseOrderStatsResponse> getPurchaseOrderStats(
    String businessId, {
    String? dateFrom,
    String? dateTo,
  }) async {
    final queryParams = <String, dynamic>{
      'businessId': businessId,
      if (dateFrom != null) 'dateFrom': dateFrom,
      if (dateTo != null) 'dateTo': dateTo,
    };

    final response = await dio.get(
      '/purchase-orders/stats',
      queryParameters: queryParams,
    );
    return PurchaseOrderStatsResponse.fromJson(response.data);
  }

  /// Get Purchase Order by Order Number
  /// GET /api/purchase-orders/by-number/:orderNumber?businessId={businessId}
  Future<PurchaseOrderModel> getPurchaseOrderByNumber(
    String orderNumber,
    String businessId,
  ) async {
    final response = await dio.get(
      '/purchase-orders/by-number/$orderNumber',
      queryParameters: {'businessId': businessId},
    );
    return PurchaseOrderModel.fromJson(response.data);
  }

  /// Get Purchase Order by ID
  /// GET /api/purchase-orders/:id?businessId={businessId}
  Future<PurchaseOrderModel> getPurchaseOrder(
    String id,
    String businessId,
  ) async {
    final response = await dio.get(
      '/purchase-orders/$id',
      queryParameters: {'businessId': businessId},
    );
    return PurchaseOrderModel.fromJson(response.data);
  }

  /// Update Purchase Order (only DRAFT)
  /// PATCH /api/purchase-orders/:id?businessId={businessId}
  Future<PurchaseOrderModel> updatePurchaseOrder(
    String id,
    String businessId,
    UpdatePurchaseOrderDto dto,
  ) async {
    final response = await dio.patch(
      '/purchase-orders/$id',
      data: dto.toJson(),
      queryParameters: {'businessId': businessId},
    );
    return PurchaseOrderModel.fromJson(response.data);
  }

  /// Delete Purchase Order (only DRAFT)
  /// DELETE /api/purchase-orders/:id?businessId={businessId}
  Future<void> deletePurchaseOrder(
    String id,
    String businessId,
  ) async {
    await dio.delete(
      '/purchase-orders/$id',
      queryParameters: {'businessId': businessId},
    );
  }

  /// Approve Purchase Order
  /// PATCH /api/purchase-orders/:id/approve?businessId={businessId}
  Future<PurchaseOrderModel> approvePurchaseOrder(
    String id,
    String businessId,
  ) async {
    final response = await dio.patch(
      '/purchase-orders/$id/approve',
      queryParameters: {'businessId': businessId},
    );
    return PurchaseOrderModel.fromJson(response.data);
  }

  /// Send Purchase Order to Supplier
  /// PATCH /api/purchase-orders/:id/send?businessId={businessId}
  Future<PurchaseOrderModel> sendPurchaseOrder(
    String id,
    String businessId,
  ) async {
    final response = await dio.patch(
      '/purchase-orders/$id/send',
      queryParameters: {'businessId': businessId},
    );
    return PurchaseOrderModel.fromJson(response.data);
  }

  /// Confirm Purchase Order with Supplier
  /// PATCH /api/purchase-orders/:id/confirm?businessId={businessId}
  Future<PurchaseOrderModel> confirmPurchaseOrder(
    String id,
    String businessId,
  ) async {
    final response = await dio.patch(
      '/purchase-orders/$id/confirm',
      queryParameters: {'businessId': businessId},
    );
    return PurchaseOrderModel.fromJson(response.data);
  }

  /// Cancel Purchase Order
  /// PATCH /api/purchase-orders/:id/cancel?businessId={businessId}&reason={reason}
  Future<PurchaseOrderModel> cancelPurchaseOrder(
    String id,
    String businessId,
    String reason,
  ) async {
    final response = await dio.patch(
      '/purchase-orders/$id/cancel',
      queryParameters: {
        'businessId': businessId,
        'reason': reason,
      },
    );
    return PurchaseOrderModel.fromJson(response.data);
  }

  /// Close Purchase Order
  /// PATCH /api/purchase-orders/:id/close?businessId={businessId}
  Future<PurchaseOrderModel> closePurchaseOrder(
    String id,
    String businessId,
  ) async {
    final response = await dio.patch(
      '/purchase-orders/$id/close',
      queryParameters: {'businessId': businessId},
    );
    return PurchaseOrderModel.fromJson(response.data);
  }
}

/// Purchase Order List Response
class PurchaseOrderListResponse {
  final List<PurchaseOrderModel> data;
  final PaginationMeta pagination;

  PurchaseOrderListResponse({
    required this.data,
    required this.pagination,
  });

  factory PurchaseOrderListResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderListResponse(
      data: (json['data'] as List)
          .map((e) => PurchaseOrderModel.fromJson(e))
          .toList(),
      pagination: PaginationMeta.fromJson(json['meta'] ?? json['pagination']),
    );
  }
}

/// Pagination Meta
class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPages: json['totalPages'],
    );
  }
}

/// Purchase Order Statistics Response
class PurchaseOrderStatsResponse {
  final int totalOrders;
  final StatusBreakdown byStatus;
  final String totalAmount;
  final String totalPaid;
  final String totalRemaining;
  final int totalItems;
  final String totalQuantity;
  final String receivedQuantity;
  final int activeSuppliers;

  PurchaseOrderStatsResponse({
    required this.totalOrders,
    required this.byStatus,
    required this.totalAmount,
    required this.totalPaid,
    required this.totalRemaining,
    required this.totalItems,
    required this.totalQuantity,
    required this.receivedQuantity,
    required this.activeSuppliers,
  });

  factory PurchaseOrderStatsResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderStatsResponse(
      totalOrders: json['totalOrders'],
      byStatus: StatusBreakdown.fromJson(json['byStatus']),
      totalAmount: json['totalAmount'].toString(),
      totalPaid: json['totalPaid'].toString(),
      totalRemaining: json['totalRemaining'].toString(),
      totalItems: json['totalItems'],
      totalQuantity: json['totalQuantity'].toString(),
      receivedQuantity: json['receivedQuantity'].toString(),
      activeSuppliers: json['activeSuppliers'],
    );
  }
}

/// Status Breakdown
class StatusBreakdown {
  final int draft;
  final int pending;
  final int approved;
  final int sent;
  final int confirmed;
  final int partiallyReceived;
  final int received;
  final int cancelled;
  final int closed;

  StatusBreakdown({
    required this.draft,
    required this.pending,
    required this.approved,
    required this.sent,
    required this.confirmed,
    required this.partiallyReceived,
    required this.received,
    required this.cancelled,
    required this.closed,
  });

  factory StatusBreakdown.fromJson(Map<String, dynamic> json) {
    return StatusBreakdown(
      draft: json['draft'] ?? 0,
      pending: json['pending'] ?? 0,
      approved: json['approved'] ?? 0,
      sent: json['sent'] ?? 0,
      confirmed: json['confirmed'] ?? 0,
      partiallyReceived: json['partiallyReceived'] ?? 0,
      received: json['received'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
      closed: json['closed'] ?? 0,
    );
  }
}
