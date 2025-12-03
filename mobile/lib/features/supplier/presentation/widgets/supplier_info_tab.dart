import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/supplier_model.dart';

class SupplierInfoTab extends StatelessWidget {
  final Supplier supplier;

  const SupplierInfoTab({Key? key, required this.supplier}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status Card
        _buildStatusCard(context),
        const SizedBox(height: 16),

        // Basic Information
        _buildSectionCard(
          context,
          'اطلاعات پایه',
          [
            _buildInfoRow(Icons.business, 'نام', supplier.name),
            if (supplier.legalName != null)
              _buildInfoRow(Icons.business_center, 'نام قانونی', supplier.legalName!),
            _buildInfoRow(Icons.qr_code, 'کد تامین‌کننده', supplier.code),
            _buildInfoRow(Icons.category, 'نوع', supplier.type.typeText),
            if (supplier.industry != null)
              _buildInfoRow(Icons.work, 'صنعت', supplier.industry!),
          ],
        ),
        const SizedBox(height: 16),

        // IDs
        if (supplier.taxId != null ||
            supplier.nationalId != null ||
            supplier.registrationNumber != null ||
            supplier.economicCode != null)
          _buildSectionCard(
            context,
            'شناسه‌ها',
            [
              if (supplier.taxId != null)
                _buildInfoRow(Icons.receipt_long, 'شناسه مالیاتی', supplier.taxId!),
              if (supplier.nationalId != null)
                _buildInfoRow(Icons.badge, 'شناسه ملی', supplier.nationalId!),
              if (supplier.registrationNumber != null)
                _buildInfoRow(Icons.numbers, 'شماره ثبت', supplier.registrationNumber!),
              if (supplier.economicCode != null)
                _buildInfoRow(Icons.code, 'کد اقتصادی', supplier.economicCode!),
            ],
          ),
        const SizedBox(height: 16),

        // Contact Information
        if (supplier.phone != null ||
            supplier.email != null ||
            supplier.website != null ||
            supplier.address != null)
          _buildSectionCard(
            context,
            'اطلاعات تماس',
            [
              if (supplier.phone != null)
                _buildInfoRow(Icons.phone, 'تلفن', supplier.phone!),
              if (supplier.email != null)
                _buildInfoRow(Icons.email, 'ایمیل', supplier.email!),
              if (supplier.website != null)
                _buildInfoRow(Icons.language, 'وبسایت', supplier.website!),
              if (supplier.address != null)
                _buildInfoRow(Icons.location_on, 'آدرس', supplier.address!),
              if (supplier.city != null || supplier.province != null)
                _buildInfoRow(
                  Icons.location_city,
                  'شهر/استان',
                  [supplier.city, supplier.province]
                      .where((e) => e != null)
                      .join('، '),
                ),
              if (supplier.postalCode != null)
                _buildInfoRow(Icons.mail, 'کد پستی', supplier.postalCode!),
              _buildInfoRow(Icons.flag, 'کشور', supplier.country),
            ],
          ),
        const SizedBox(height: 16),

        // Financial Information
        _buildSectionCard(
          context,
          'اطلاعات مالی',
          [
            if (supplier.balance != 0)
              _buildInfoRow(
                supplier.hasDebt ? Icons.arrow_upward : Icons.arrow_downward,
                supplier.hasDebt ? 'بدهی فعلی' : 'بستانکار',
                '${supplier.balance.abs().toStringAsFixed(0)} ${supplier.currency}',
                valueColor: supplier.hasDebt ? Colors.red : Colors.green,
              ),
            _buildInfoRow(
              Icons.account_balance_wallet,
              'سقف اعتبار',
              '${(double.tryParse(supplier.creditLimit) ?? 0).toStringAsFixed(0)} ${supplier.currency}',
            ),
            _buildInfoRow(
              Icons.calendar_today,
              'مهلت پرداخت',
              '${supplier.paymentTermDays} روز',
            ),
            if (supplier.paymentTermType != null)
              _buildInfoRow(
                Icons.payment,
                'نوع شرایط پرداخت',
                supplier.paymentTermType!,
              ),
            _buildInfoRow(
              Icons.local_shipping,
              'مدت زمان تحویل پیش‌فرض',
              '${supplier.defaultLeadTimeDays} روز',
            ),
            if (supplier.incoterm != null)
              _buildInfoRow(Icons.import_export, 'Incoterm', supplier.incoterm!),
            _buildInfoRow(Icons.money, 'ارز', supplier.currency),
          ],
        ),
        const SizedBox(height: 16),

        // Performance Metrics
        _buildSectionCard(
          context,
          'عملکرد',
          [
            _buildInfoRow(
              Icons.star,
              'امتیاز کیفیت',
              (double.tryParse(supplier.qualityRating) ?? 0) > 0
                  ? '${(double.tryParse(supplier.qualityRating) ?? 0).toStringAsFixed(2)} از 5'
                  : 'ثبت نشده',
              valueColor: (double.tryParse(supplier.qualityRating) ?? 0) >= 4 ? Colors.green : null,
            ),
            _buildInfoRow(
              Icons.delivery_dining,
              'نرخ تحویل به موقع',
              '${(double.tryParse(supplier.onTimeDeliveryRate) ?? 0).toStringAsFixed(1)}%',
              valueColor:
                  (double.tryParse(supplier.onTimeDeliveryRate) ?? 0) >= 90 ? Colors.green : Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Statistics
        _buildSectionCard(
          context,
          'آمار',
          [
            _buildInfoRow(
              Icons.shopping_cart,
              'تعداد سفارشات',
              '${supplier.totalOrders}',
            ),
            _buildInfoRow(
              Icons.attach_money,
              'کل مبلغ خرید',
              '${(double.tryParse(supplier.totalPurchaseAmount) ?? 0).toStringAsFixed(0)} ${supplier.currency}',
            ),
            _buildInfoRow(
              Icons.payment,
              'کل پرداختی',
              '${(double.tryParse(supplier.totalPaid) ?? 0).toStringAsFixed(0)} ${supplier.currency}',
            ),
            if (supplier.lastOrderDate != null)
              _buildInfoRow(
                Icons.event,
                'آخرین سفارش',
                DateFormat('yyyy/MM/dd').format(supplier.lastOrderDate!),
              ),
            if (supplier.lastPaymentDate != null)
              _buildInfoRow(
                Icons.payment,
                'آخرین پرداخت',
                DateFormat('yyyy/MM/dd').format(supplier.lastPaymentDate!),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Business Linking
        if (supplier.isLinkedBusiness || supplier.linkedBusinessId != null)
          _buildSectionCard(
            context,
            'اتصال به کسب‌وکار',
            [
              _buildInfoRow(
                Icons.link,
                'متصل به کسب‌وکار',
                supplier.isLinkedBusiness ? 'بله' : 'خیر',
                valueColor: supplier.isLinkedBusiness ? Colors.green : null,
              ),
              if (supplier.linkedBusinessId != null)
                _buildInfoRow(
                  Icons.business,
                  'شناسه کسب‌وکار',
                  supplier.linkedBusinessId!,
                ),
              if (supplier.linkedAt != null)
                _buildInfoRow(
                  Icons.date_range,
                  'تاریخ اتصال',
                  DateFormat('yyyy/MM/dd').format(supplier.linkedAt!),
                ),
            ],
          ),
        const SizedBox(height: 16),

        // Tags
        if (supplier.tags != null && supplier.tags!.isNotEmpty)
          _buildSectionCard(
            context,
            'برچسب‌ها',
            [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: supplier.tags!.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: Colors.grey[200],
                  );
                }).toList(),
              ),
            ],
          ),
        const SizedBox(height: 16),

        // Notes & Description
        if (supplier.description != null || supplier.notes != null)
          _buildSectionCard(
            context,
            'یادداشت‌ها',
            [
              if (supplier.description != null) ...[
                Text(
                  'توضیحات',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(supplier.description!),
                const SizedBox(height: 16),
              ],
              if (supplier.notes != null) ...[
                Text(
                  'یادداشت',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(supplier.notes!),
              ],
            ],
          ),
        const SizedBox(height: 16),

        // Dates
        _buildSectionCard(
          context,
          'تاریخچه',
          [
            if (supplier.onboardingDate != null)
              _buildInfoRow(
                Icons.date_range,
                'تاریخ شروع همکاری',
                DateFormat('yyyy/MM/dd').format(supplier.onboardingDate!),
              ),
            if (supplier.approvedAt != null)
              _buildInfoRow(
                Icons.check_circle,
                'تاریخ تایید',
                DateFormat('yyyy/MM/dd HH:mm').format(supplier.approvedAt!),
              ),
            _buildInfoRow(
              Icons.create,
              'تاریخ ایجاد',
              DateFormat('yyyy/MM/dd HH:mm').format(supplier.createdAt),
            ),
            _buildInfoRow(
              Icons.update,
              'آخرین بروزرسانی',
              DateFormat('yyyy/MM/dd HH:mm').format(supplier.updatedAt),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    Color statusColor = _getStatusColor(supplier.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'وضعیت: ${supplier.status.statusText}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...children.map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: child,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(SupplierStatus status) {
    switch (status) {
      case SupplierStatus.draft:
        return Colors.grey;
      case SupplierStatus.pending:
        return Colors.orange;
      case SupplierStatus.approved:
        return Colors.green;
      case SupplierStatus.suspended:
        return Colors.amber;
      case SupplierStatus.blocked:
        return Colors.red;
      case SupplierStatus.archived:
        return Colors.blueGrey;
    }
  }
}
