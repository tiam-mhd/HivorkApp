import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice.dart';
import '../../../business/data/models/business_model.dart';
import '../../../customer/data/models/customer.dart';

/// سرویس تولید PDF فاکتور
class InvoicePdfService {
  /// تولید PDF از فاکتور
  Future<Uint8List> generateInvoicePdf(Invoice invoice) async {
    final pdf = pw.Document();

    // بارگذاری فونت فارسی
    final font = await PdfGoogleFonts.notoSansArabicRegular();
    final fontBold = await PdfGoogleFonts.notoSansArabicBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        build: (context) => [
          _buildHeader(invoice),
          pw.SizedBox(height: 20),
          _buildBusinessAndCustomerInfo(invoice),
          pw.SizedBox(height: 20),
          _buildItemsTable(invoice),
          pw.SizedBox(height: 20),
          _buildTotals(invoice),
          if (invoice.notes != null) ...[
            pw.SizedBox(height: 20),
            _buildNotes(invoice.notes!),
          ],
          pw.Spacer(),
          _buildFooter(),
        ],
      ),
    );

    return pdf.save();
  }

  /// هدر فاکتور (عنوان و شماره)
  pw.Widget _buildHeader(Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                invoice.type.label,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'شماره: ${invoice.invoiceNumber}',
                style: const pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'تاریخ صدور:',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                _formatDate(invoice.issueDate),
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (invoice.dueDate != null) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  'سررسید:',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  _formatDate(invoice.dueDate!),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red700,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// اطلاعات کسب‌وکار و مشتری
  pw.Widget _buildBusinessAndCustomerInfo(Invoice invoice) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Business Info
        pw.Expanded(
          child: _buildInfoBox(
            'فروشنده',
            [
              if (invoice.business != null) ...[
                _buildInfoRow('نام:', invoice.business!.name),
                if (invoice.business!.phone != null)
                  _buildInfoRow('تلفن:', invoice.business!.phone!),
                if (invoice.business!.address != null)
                  _buildInfoRow('آدرس:', invoice.business!.address!),
              ] else
                _buildInfoRow('شناسه:', invoice.businessId),
            ],
          ),
        ),
        pw.SizedBox(width: 16),
        // Customer Info
        pw.Expanded(
          child: _buildInfoBox(
            'خریدار',
            [
              if (invoice.customer != null) ...[
                _buildInfoRow('نام:', invoice.customer!.fullName),
                if (invoice.customer!.phone != null)
                  _buildInfoRow('تلفن:', invoice.customer!.phone!),
                if (invoice.customer!.email != null)
                  _buildInfoRow('ایمیل:', invoice.customer!.email!),
                if (invoice.customer!.address != null)
                  _buildInfoRow('آدرس:', invoice.customer!.address!),
              ] else if (invoice.customerName != null)
                _buildInfoRow('نام:', invoice.customerName!),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildInfoBox(String title, List<pw.Widget> children) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  /// جدول اقلام فاکتور
  pw.Widget _buildItemsTable(Invoice invoice) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(1), // ردیف
        1: const pw.FlexColumnWidth(4), // نام محصول
        2: const pw.FlexColumnWidth(2), // تعداد
        3: const pw.FlexColumnWidth(2), // قیمت واحد
        4: const pw.FlexColumnWidth(2), // جمع
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableHeader('ردیف'),
            _buildTableHeader('شرح کالا/خدمات'),
            _buildTableHeader('تعداد'),
            _buildTableHeader('قیمت واحد'),
            _buildTableHeader('جمع'),
          ],
        ),
        // Items
        ...invoice.items.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final item = entry.value;
          return pw.TableRow(
            children: [
              _buildTableCell(index.toString()),
              _buildTableCell(
                item.productName +
                    (item.description != null ? '\n${item.description}' : ''),
                textAlign: pw.TextAlign.right,
              ),
              _buildTableCell('${item.quantity.toStringAsFixed(0)} ${item.unit}'),
              _buildTableCell(_formatCurrency(item.unitPrice)),
              _buildTableCell(_formatCurrency(item.totalPrice)),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildTableCell(String text,
      {pw.TextAlign textAlign = pw.TextAlign.center}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 10),
        textAlign: textAlign,
      ),
    );
  }

  /// جمع‌کل و محاسبات
  pw.Widget _buildTotals(Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          _buildTotalRow('جمع کل:', _formatCurrency(invoice.subtotal)),
          if (invoice.discountAmount > 0)
            _buildTotalRow(
              'تخفیف:',
              _formatCurrency(invoice.discountAmount),
              color: PdfColors.red700,
            ),
          if (invoice.taxAmount > 0)
            _buildTotalRow('مالیات:', _formatCurrency(invoice.taxAmount)),
          if (invoice.extraCostsTotal > 0)
            _buildTotalRow(
                'هزینه‌های اضافی:', _formatCurrency(invoice.extraCostsTotal)),
          pw.Divider(thickness: 1.5),
          _buildTotalRow(
            'مبلغ قابل پرداخت:',
            _formatCurrency(invoice.totalAmount),
            fontSize: 16,
            bold: true,
            color: PdfColors.blue800,
          ),
          if (invoice.paidAmount > 0) ...[
            pw.SizedBox(height: 8),
            _buildTotalRow(
              'پرداخت شده:',
              _formatCurrency(invoice.paidAmount),
              color: PdfColors.green700,
            ),
            _buildTotalRow(
              'مانده:',
              _formatCurrency(invoice.remainingAmount),
              color: PdfColors.orange700,
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildTotalRow(
    String label,
    String value, {
    double fontSize = 12,
    bool bold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// یادداشت‌ها
  pw.Widget _buildNotes(String notes) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'توضیحات:',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            notes,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  /// فوتر
  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Text(
          'این فاکتور توسط سیستم هایورک تولید شده است',
          style: const pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  /// فرمت تاریخ فارسی
  String _formatDate(DateTime date) {
    // TODO: استفاده از shamsi_date برای تبدیل به تاریخ شمسی
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  /// فرمت قیمت
  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0);
    // اضافه کردن جداکننده هزارگان
    final parts = <String>[];
    var remaining = formatted;
    while (remaining.length > 3) {
      parts.insert(0, remaining.substring(remaining.length - 3));
      remaining = remaining.substring(0, remaining.length - 3);
    }
    if (remaining.isNotEmpty) {
      parts.insert(0, remaining);
    }
    return '${parts.join(',')} ریال';
  }

  /// نمایش پیش‌نمایش و چاپ
  Future<void> printInvoice(Invoice invoice) async {
    final pdfData = await generateInvoicePdf(invoice);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: 'فاکتور_${invoice.invoiceNumber}.pdf',
    );
  }

  /// اشتراک‌گذاری PDF
  Future<void> shareInvoice(Invoice invoice) async {
    final pdfData = await generateInvoicePdf(invoice);
    await Printing.sharePdf(
      bytes: pdfData,
      filename: 'فاکتور_${invoice.invoiceNumber}.pdf',
    );
  }
}
