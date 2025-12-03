import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import '../../data/providers/supplier_provider.dart';
import '../../data/models/document_model.dart';

class SupplierDocumentsTab extends StatefulWidget {
  final String supplierId;
  final String businessId;

  const SupplierDocumentsTab({
    Key? key,
    required this.supplierId,
    required this.businessId,
  }) : super(key: key);

  @override
  State<SupplierDocumentsTab> createState() => _SupplierDocumentsTabState();
}

class _SupplierDocumentsTabState extends State<SupplierDocumentsTab> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    try {
      await context.read<SupplierProvider>().loadSupplierDocuments(
            widget.businessId,
            widget.supplierId,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری اسناد: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupplierProvider>(
      builder: (context, provider, child) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final documents = provider.supplierDocuments;

        if (documents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'هیچ سندی ثبت نشده است',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadDocuments,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _viewDocument(document),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getDocumentIcon(document.type),
                              size: 32,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getDocumentTypeLabel(document.type),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (document.documentNumber != null && document.documentNumber!.isNotEmpty)
                                    Text(
                                      'شماره: ${document.documentNumber}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            _buildStatusBadge(document.status),
                          ],
                        ),
                        if (document.issueDate != null || document.expiryDate != null) ...[
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (document.issueDate != null)
                                Expanded(
                                  child: _buildDateInfo(
                                    'تاریخ صدور',
                                    document.issueDate!,
                                  ),
                                ),
                              if (document.issueDate != null && document.expiryDate != null)
                                const SizedBox(width: 16),
                              if (document.expiryDate != null)
                                Expanded(
                                  child: _buildDateInfo(
                                    'تاریخ انقضا',
                                    document.expiryDate!,
                                    isExpiring: _isExpiringSoon(document),
                                  ),
                                ),
                            ],
                          ),
                        ],
                        if (document.notes != null && document.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            document.notes!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (document.fileSize != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'حجم: ${_formatFileSize(document.fileSize!)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  bool _isExpiringSoon(SupplierDocument document) {
    if (document.expiryDate == null) return false;
    final now = DateTime.now();
    final daysUntilExpiry = document.expiryDate!.difference(now).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry <= 30;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildDateInfo(String label, DateTime date, {bool isExpiring = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              intl.DateFormat('yyyy/MM/dd').format(date),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isExpiring ? Colors.orange : null,
              ),
            ),
            if (isExpiring) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: Colors.orange,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(DocumentStatus status) {
    Color color;
    String label;

    switch (status) {
      case DocumentStatus.pending:
        color = Colors.orange;
        label = 'در انتظار تایید';
        break;
      case DocumentStatus.approved:
        color = Colors.green;
        label = 'تایید شده';
        break;
      case DocumentStatus.rejected:
        color = Colors.red;
        label = 'رد شده';
        break;
      case DocumentStatus.expired:
        color = Colors.grey;
        label = 'منقضی شده';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  IconData _getDocumentIcon(SupplierDocumentType type) {
    switch (type) {
      case SupplierDocumentType.contract:
        return Icons.description;
      case SupplierDocumentType.license:
        return Icons.card_membership;
      case SupplierDocumentType.certificate:
        return Icons.verified;
      case SupplierDocumentType.insurance:
        return Icons.health_and_safety;
      case SupplierDocumentType.taxDocument:
        return Icons.receipt_long;
      case SupplierDocumentType.qualityCert:
        return Icons.verified_user;
      case SupplierDocumentType.bankInfo:
        return Icons.account_balance;
      case SupplierDocumentType.idDocument:
        return Icons.badge;
      case SupplierDocumentType.other:
        return Icons.insert_drive_file;
    }
  }

  String _getDocumentTypeLabel(SupplierDocumentType type) {
    switch (type) {
      case SupplierDocumentType.contract:
        return 'قرارداد';
      case SupplierDocumentType.license:
        return 'مجوز';
      case SupplierDocumentType.certificate:
        return 'گواهی‌نامه';
      case SupplierDocumentType.insurance:
        return 'بیمه';
      case SupplierDocumentType.taxDocument:
        return 'مدرک مالیاتی';
      case SupplierDocumentType.qualityCert:
        return 'گواهی کیفیت';
      case SupplierDocumentType.bankInfo:
        return 'اطلاعات بانکی';
      case SupplierDocumentType.idDocument:
        return 'مدرک شناسایی';
      case SupplierDocumentType.other:
        return 'سایر';
    }
  }

  void _viewDocument(SupplierDocument document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getDocumentTypeLabel(document.type)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (document.documentNumber != null) ...[
                _buildInfoRow('شماره سند', document.documentNumber!),
                const SizedBox(height: 8),
              ],
              if (document.issueDate != null) ...[
                _buildInfoRow(
                  'تاریخ صدور',
                  intl.DateFormat('yyyy/MM/dd').format(document.issueDate!),
                ),
                const SizedBox(height: 8),
              ],
              if (document.expiryDate != null) ...[
                _buildInfoRow(
                  'تاریخ انقضا',
                  intl.DateFormat('yyyy/MM/dd').format(document.expiryDate!),
                ),
                const SizedBox(height: 8),
              ],
              _buildInfoRow('وضعیت', _getStatusLabel(document.status)),
              if (document.notes != null && document.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'یادداشت‌ها:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(document.notes!),
              ],
              if (document.filePath != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Open file
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('مشاهده فایل'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  String _getStatusLabel(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return 'در انتظار تایید';
      case DocumentStatus.approved:
        return 'تایید شده';
      case DocumentStatus.rejected:
        return 'رد شده';
      case DocumentStatus.expired:
        return 'منقضی شده';
    }
  }
}
