import 'package:dio/dio.dart';
import '../dtos/receipt_dtos.dart';
import '../models/purchase_order_receipt_model.dart';

/// Receipt API Service
/// مطابق 100% با backend: receipt.controller.ts
class ReceiptApiService {
  final Dio dio;

  ReceiptApiService(this.dio);

  /// Create Receipt
  /// POST /api/purchase-orders/:purchaseOrderId/receipts?businessId={businessId}
  Future<PurchaseOrderReceiptModel> createReceipt(
    String purchaseOrderId,
    CreateReceiptDto dto,
    String businessId,
  ) async {
    final response = await dio.post(
      '/purchase-orders/$purchaseOrderId/receipts',
      data: dto.toJson(),
      queryParameters: {'businessId': businessId},
    );
    return PurchaseOrderReceiptModel.fromJson(response.data);
  }

  /// Get All Receipts for Purchase Order
  /// GET /api/purchase-orders/:purchaseOrderId/receipts
  Future<ReceiptListResponse> getReceipts(String purchaseOrderId) async {
    final response = await dio.get(
      '/purchase-orders/$purchaseOrderId/receipts',
    );
    return ReceiptListResponse.fromJson(response.data);
  }

  /// Get Receipt Statistics
  /// GET /api/purchase-orders/:purchaseOrderId/receipts/stats
  Future<ReceiptStatsResponse> getReceiptStats(String purchaseOrderId) async {
    final response = await dio.get(
      '/purchase-orders/$purchaseOrderId/receipts/stats',
    );
    return ReceiptStatsResponse.fromJson(response.data);
  }

  /// Get Receipt by ID
  /// GET /api/purchase-orders/:purchaseOrderId/receipts/:id
  Future<PurchaseOrderReceiptModel> getReceipt(
    String purchaseOrderId,
    String id,
  ) async {
    final response = await dio.get(
      '/purchase-orders/$purchaseOrderId/receipts/$id',
    );
    return PurchaseOrderReceiptModel.fromJson(response.data);
  }

  /// Update Receipt (only DRAFT)
  /// PATCH /api/purchase-orders/:purchaseOrderId/receipts/:id
  Future<PurchaseOrderReceiptModel> updateReceipt(
    String purchaseOrderId,
    String id,
    UpdateReceiptDto dto,
  ) async {
    final response = await dio.patch(
      '/purchase-orders/$purchaseOrderId/receipts/$id',
      data: dto.toJson(),
    );
    return PurchaseOrderReceiptModel.fromJson(response.data);
  }

  /// Delete Receipt (only DRAFT)
  /// DELETE /api/purchase-orders/:purchaseOrderId/receipts/:id
  Future<void> deleteReceipt(
    String purchaseOrderId,
    String id,
  ) async {
    await dio.delete(
      '/purchase-orders/$purchaseOrderId/receipts/$id',
    );
  }

  /// Complete Receipt
  /// PATCH /api/purchase-orders/:purchaseOrderId/receipts/:id/complete
  Future<PurchaseOrderReceiptModel> completeReceipt(
    String purchaseOrderId,
    String id,
  ) async {
    final response = await dio.patch(
      '/purchase-orders/$purchaseOrderId/receipts/$id/complete',
    );
    return PurchaseOrderReceiptModel.fromJson(response.data);
  }

  /// Cancel Receipt
  /// PATCH /api/purchase-orders/:purchaseOrderId/receipts/:id/cancel?reason={reason}
  Future<PurchaseOrderReceiptModel> cancelReceipt(
    String purchaseOrderId,
    String id,
    String reason,
  ) async {
    final response = await dio.patch(
      '/purchase-orders/$purchaseOrderId/receipts/$id/cancel',
      queryParameters: {'reason': reason},
    );
    return PurchaseOrderReceiptModel.fromJson(response.data);
  }
}

/// Receipt List Response
class ReceiptListResponse {
  final List<PurchaseOrderReceiptModel> data;
  final ReceiptSummary summary;

  ReceiptListResponse({
    required this.data,
    required this.summary,
  });

  factory ReceiptListResponse.fromJson(Map<String, dynamic> json) {
    return ReceiptListResponse(
      data: (json['data'] as List)
          .map((e) => PurchaseOrderReceiptModel.fromJson(e))
          .toList(),
      summary: ReceiptSummary.fromJson(json['summary']),
    );
  }
}

/// Receipt Summary
class ReceiptSummary {
  final int totalReceipts;
  final int totalItems;
  final String totalQuantity;

  ReceiptSummary({
    required this.totalReceipts,
    required this.totalItems,
    required this.totalQuantity,
  });

  factory ReceiptSummary.fromJson(Map<String, dynamic> json) {
    return ReceiptSummary(
      totalReceipts: json['totalReceipts'],
      totalItems: json['totalItems'],
      totalQuantity: json['totalQuantity'].toString(),
    );
  }
}

/// Receipt Statistics Response
class ReceiptStatsResponse {
  final int totalReceipts;
  final String totalReceived;
  final String totalRejected;
  final Map<String, dynamic> byStatus;

  ReceiptStatsResponse({
    required this.totalReceipts,
    required this.totalReceived,
    required this.totalRejected,
    required this.byStatus,
  });

  factory ReceiptStatsResponse.fromJson(Map<String, dynamic> json) {
    return ReceiptStatsResponse(
      totalReceipts: json['totalReceipts'],
      totalReceived: json['totalReceived'].toString(),
      totalRejected: json['totalRejected'].toString(),
      byStatus: json['byStatus'],
    );
  }
}
