import 'package:dio/dio.dart';
import '../models/invoice.dart';

class InvoiceService {
  final Dio dio;

  InvoiceService(this.dio);

  /// دریافت لیست فاکتورها
  Future<Map<String, dynamic>> getInvoices({
    required String businessId,
    int page = 1,
    int limit = 20,
    String? search,
    InvoiceType? type,
    InvoiceStatus? status,
    PaymentStatus? paymentStatus,
    ShippingStatus? shippingStatus,
    String? customerId,
    DateTime? fromDate,
    DateTime? toDate,
    double? minAmount,
    double? maxAmount,
    String sortBy = 'createdAt',
    String sortOrder = 'DESC',
  }) async {
    try {
      final queryParams = {
        'businessId': businessId,
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (type != null) 'type': type.value,
        if (status != null) 'status': status.value,
        if (paymentStatus != null) 'paymentStatus': paymentStatus.value,
        if (shippingStatus != null) 'shippingStatus': shippingStatus.value,
        if (customerId != null) 'customerId': customerId,
        if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
        if (toDate != null) 'toDate': toDate.toIso8601String(),
        if (minAmount != null) 'minAmount': minAmount,
        if (maxAmount != null) 'maxAmount': maxAmount,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      final response = await dio.get(
        '/invoices',
        queryParameters: queryParams,
      );

      return {
  'data': (response.data['data'] as List)
      .map((json) {
        try {
          return Invoice.fromJson(json);
        } catch (e, stack) {
          print('❌ Error parsing invoice: $json');
          print('❌ Exception: $e');
          print('❌ Stack: $stack');
          rethrow;
        }
      })
      .toList(),
  'total': response.data['total'],
  'page': response.data['page'],
  'limit': response.data['limit'],
};
    } catch (e) {
      rethrow;
    }
  }

  /// ایجاد فاکتور جدید
  Future<Invoice> createInvoice({
    required String businessId,
    required Map<String, dynamic> data,
  }) async {
    try {
      print('🔵 [INVOICE] Creating invoice for business: $businessId');
      print('🔵 [INVOICE] Data: $data');
      
      final response = await dio.post(
        '/invoices',
        data: data,
        queryParameters: {'businessId': businessId},
      );
      
      print('✅ [INVOICE] Invoice created successfully');
      return Invoice.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [INVOICE] DioException: ${e.response?.statusCode}');
      print('❌ [INVOICE] Error data: ${e.response?.data}');
      print('❌ [INVOICE] Headers sent: ${e.requestOptions.headers}');
      rethrow;
    } catch (e) {
      print('❌ [INVOICE] Unknown error: $e');
      rethrow;
    }
  }

  /// جزئیات فاکتور
  Future<Invoice> getInvoiceDetails({
    required String id,
    required String businessId,
  }) async {
    try {
      final response = await dio.get(
        '/invoices/$id',
        queryParameters: {'businessId': businessId},
      );
      return Invoice.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// ویرایش فاکتور
  Future<Invoice> updateInvoice({
    required String id,
    required String businessId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.patch(
        '/invoices/$id',
        data: data,
        queryParameters: {'businessId': businessId},
      );
      return Invoice.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// حذف فاکتور
  Future<void> deleteInvoice({
    required String id,
    required String businessId,
  }) async {
    try {
      await dio.delete(
        '/invoices/$id',
        queryParameters: {'businessId': businessId},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// نهایی کردن فاکتور
  Future<Invoice> finalizeInvoice({
    required String id,
    required String businessId,
  }) async {
    try {
      final response = await dio.post(
        '/invoices/$id/finalize',
        queryParameters: {'businessId': businessId},
      );
      return Invoice.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// لغو فاکتور
  Future<Invoice> cancelInvoice({
    required String id,
    required String businessId,
    String? reason,
  }) async {
    try {
      final response = await dio.post(
        '/invoices/$id/cancel',
        data: {'reason': reason},
        queryParameters: {'businessId': businessId},
      );
      return Invoice.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// تبدیل پیش‌فاکتور به فاکتور فروش
  Future<Invoice> convertToSales({
    required String id,
    required String businessId,
  }) async {
    try {
      final response = await dio.post(
        '/invoices/$id/convert-to-sales',
        queryParameters: {'businessId': businessId},
      );
      return Invoice.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// ثبت پرداخت جدید
  Future<InvoicePayment> addPayment({
    required String id,
    required String businessId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.post(
        '/invoices/$id/payments',
        data: data,
        queryParameters: {'businessId': businessId},
      );
      return InvoicePayment.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// لیست پرداخت‌های یک فاکتور
  Future<List<InvoicePayment>> getPayments({
    required String id,
    required String businessId,
  }) async {
    try {
      final response = await dio.get(
        '/invoices/$id/payments',
        queryParameters: {'businessId': businessId},
      );
      return (response.data as List)
          .map((json) => InvoicePayment.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// حذف پرداخت
  Future<void> removePayment({
    required String invoiceId,
    required String paymentId,
    required String businessId,
  }) async {
    try {
      await dio.delete(
        '/invoices/$invoiceId/payments/$paymentId',
        queryParameters: {'businessId': businessId},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// دریافت شماره فاکتور بعدی
  Future<String> getNextInvoiceNumber({
    required String businessId,
  }) async {
    try {
      final response = await dio.get(
        '/invoices/next-number',
        queryParameters: {'businessId': businessId},
      );
      return response.data['invoiceNumber'];
    } catch (e) {
      rethrow;
    }
  }

  /// آمار فاکتورها برای داشبورد
  Future<Map<String, dynamic>> getStats({
    required String businessId,
  }) async {
    try {
      final response = await dio.get(
        '/invoices/stats',
        queryParameters: {'businessId': businessId},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// گزارش خلاصه فروش
  Future<Map<String, dynamic>> getSummaryReport({
    required String businessId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = {
        'businessId': businessId,
        if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
        if (toDate != null) 'toDate': toDate.toIso8601String(),
      };

      final response = await dio.get(
        '/invoices/reports/summary',
        queryParameters: queryParams,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
