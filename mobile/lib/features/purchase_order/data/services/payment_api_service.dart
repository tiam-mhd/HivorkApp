import 'package:dio/dio.dart';
import '../dtos/payment_dtos.dart';
import '../models/purchase_order_payment_model.dart';

/// Payment API Service
/// مطابق 100% با backend: payment.controller.ts
class PaymentApiService {
  final Dio dio;

  PaymentApiService(this.dio);

  /// Create Payment
  /// POST /api/purchase-orders/:purchaseOrderId/payments?businessId={businessId}
  Future<PurchaseOrderPaymentModel> createPayment(
    String purchaseOrderId,
    CreatePaymentDto dto,
    String businessId,
  ) async {
    final response = await dio.post(
      '/purchase-orders/$purchaseOrderId/payments',
      data: dto.toJson(),
      queryParameters: {'businessId': businessId},
    );
    return PurchaseOrderPaymentModel.fromJson(response.data);
  }

  /// Get All Payments for Purchase Order
  /// GET /api/purchase-orders/:purchaseOrderId/payments
  Future<PaymentListResponse> getPayments(String purchaseOrderId) async {
    final response = await dio.get(
      '/purchase-orders/$purchaseOrderId/payments',
    );
    return PaymentListResponse.fromJson(response.data);
  }

  /// Get Payment Statistics
  /// GET /api/purchase-orders/:purchaseOrderId/payments/stats
  Future<PaymentStatsResponse> getPaymentStats(String purchaseOrderId) async {
    final response = await dio.get(
      '/purchase-orders/$purchaseOrderId/payments/stats',
    );
    return PaymentStatsResponse.fromJson(response.data);
  }

  /// Get Payment by ID
  /// GET /api/purchase-orders/:purchaseOrderId/payments/:id
  Future<PurchaseOrderPaymentModel> getPayment(
    String purchaseOrderId,
    String id,
  ) async {
    final response = await dio.get(
      '/purchase-orders/$purchaseOrderId/payments/$id',
    );
    return PurchaseOrderPaymentModel.fromJson(response.data);
  }

  /// Update Payment (only PENDING)
  /// PATCH /api/purchase-orders/:purchaseOrderId/payments/:id
  Future<PurchaseOrderPaymentModel> updatePayment(
    String purchaseOrderId,
    String id,
    UpdatePaymentDto dto,
  ) async {
    final response = await dio.patch(
      '/purchase-orders/$purchaseOrderId/payments/$id',
      data: dto.toJson(),
    );
    return PurchaseOrderPaymentModel.fromJson(response.data);
  }

  /// Delete Payment (only PENDING)
  /// DELETE /api/purchase-orders/:purchaseOrderId/payments/:id
  Future<void> deletePayment(
    String purchaseOrderId,
    String id,
  ) async {
    await dio.delete(
      '/purchase-orders/$purchaseOrderId/payments/$id',
    );
  }

  /// Complete Payment
  /// PATCH /api/purchase-orders/:purchaseOrderId/payments/:id/complete
  Future<PurchaseOrderPaymentModel> completePayment(
    String purchaseOrderId,
    String id,
  ) async {
    final response = await dio.patch(
      '/purchase-orders/$purchaseOrderId/payments/$id/complete',
    );
    return PurchaseOrderPaymentModel.fromJson(response.data);
  }

  /// Mark Payment as Failed
  /// PATCH /api/purchase-orders/:purchaseOrderId/payments/:id/fail?reason={reason}
  Future<PurchaseOrderPaymentModel> failPayment(
    String purchaseOrderId,
    String id,
    String reason,
  ) async {
    final response = await dio.patch(
      '/purchase-orders/$purchaseOrderId/payments/$id/fail',
      queryParameters: {'reason': reason},
    );
    return PurchaseOrderPaymentModel.fromJson(response.data);
  }

  /// Cancel Payment
  /// PATCH /api/purchase-orders/:purchaseOrderId/payments/:id/cancel?reason={reason}
  Future<PurchaseOrderPaymentModel> cancelPayment(
    String purchaseOrderId,
    String id,
    String reason,
  ) async {
    final response = await dio.patch(
      '/purchase-orders/$purchaseOrderId/payments/$id/cancel',
      queryParameters: {'reason': reason},
    );
    return PurchaseOrderPaymentModel.fromJson(response.data);
  }
}

/// Payment List Response
class PaymentListResponse {
  final List<PurchaseOrderPaymentModel> data;
  final PaymentSummary summary;

  PaymentListResponse({
    required this.data,
    required this.summary,
  });

  factory PaymentListResponse.fromJson(Map<String, dynamic> json) {
    return PaymentListResponse(
      data: (json['data'] as List)
          .map((e) => PurchaseOrderPaymentModel.fromJson(e))
          .toList(),
      summary: PaymentSummary.fromJson(json['summary']),
    );
  }
}

/// Payment Summary
class PaymentSummary {
  final String totalPaid;
  final String totalPending;
  final String totalCompleted;
  final String remainingAmount;

  PaymentSummary({
    required this.totalPaid,
    required this.totalPending,
    required this.totalCompleted,
    required this.remainingAmount,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      totalPaid: json['totalPaid'].toString(),
      totalPending: json['totalPending'].toString(),
      totalCompleted: json['totalCompleted'].toString(),
      remainingAmount: json['remainingAmount'].toString(),
    );
  }
}

/// Payment Statistics Response
class PaymentStatsResponse {
  final Map<String, dynamic> byMethod;
  final String totalAmount;
  final int totalCount;

  PaymentStatsResponse({
    required this.byMethod,
    required this.totalAmount,
    required this.totalCount,
  });

  factory PaymentStatsResponse.fromJson(Map<String, dynamic> json) {
    return PaymentStatsResponse(
      byMethod: json['byMethod'],
      totalAmount: json['totalAmount'].toString(),
      totalCount: json['totalCount'],
    );
  }
}
