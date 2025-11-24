import 'package:flutter/material.dart';
import '../../data/models/invoice.dart';

enum InvoiceStatusBadgeType {
  status,
  payment,
  shipping,
}

class InvoiceStatusBadge extends StatelessWidget {
  final dynamic status;
  final InvoiceStatusBadgeType type;
  final bool small;

  const InvoiceStatusBadge({
    Key? key,
    required this.status,
    required this.type,
    this.small = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: config.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: small ? 14 : 16,
            color: config.color,
          ),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: small ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig() {
    switch (type) {
      case InvoiceStatusBadgeType.status:
        return _getInvoiceStatusConfig(status as InvoiceStatus);
      case InvoiceStatusBadgeType.payment:
        return _getPaymentStatusConfig(status as PaymentStatus);
      case InvoiceStatusBadgeType.shipping:
        return _getShippingStatusConfig(status as ShippingStatus);
    }
  }

  _StatusConfig _getInvoiceStatusConfig(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return _StatusConfig(
          label: 'پیش‌نویس',
          color: Colors.grey,
          icon: Icons.edit_note,
        );
      case InvoiceStatus.finalized:
        return _StatusConfig(
          label: 'نهایی',
          color: Colors.green,
          icon: Icons.check_circle,
        );
      case InvoiceStatus.cancelled:
        return _StatusConfig(
          label: 'لغو شده',
          color: Colors.red,
          icon: Icons.cancel,
        );
      case InvoiceStatus.returned:
        return _StatusConfig(
          label: 'برگشتی',
          color: Colors.orange,
          icon: Icons.keyboard_return,
        );
    }
  }

  _StatusConfig _getPaymentStatusConfig(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.unpaid:
        return _StatusConfig(
          label: 'پرداخت نشده',
          color: Colors.red,
          icon: Icons.payment,
        );
      case PaymentStatus.partial:
        return _StatusConfig(
          label: 'پرداخت جزئی',
          color: Colors.orange,
          icon: Icons.payments,
        );
      case PaymentStatus.paid:
        return _StatusConfig(
          label: 'پرداخت شده',
          color: Colors.green,
          icon: Icons.check_circle,
        );
    }
  }

  _StatusConfig _getShippingStatusConfig(ShippingStatus status) {
    switch (status) {
      case ShippingStatus.pending:
        return _StatusConfig(
          label: 'ارسال نشده',
          color: Colors.grey,
          icon: Icons.pending,
        );
      case ShippingStatus.processing:
        return _StatusConfig(
          label: 'در حال ارسال',
          color: Colors.blue,
          icon: Icons.local_shipping,
        );
      case ShippingStatus.shipped:
        return _StatusConfig(
          label: 'ارسال شده',
          color: Colors.teal,
          icon: Icons.done_all,
        );
      case ShippingStatus.delivered:
        return _StatusConfig(
          label: 'تحویل داده شده',
          color: Colors.green,
          icon: Icons.verified,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  _StatusConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}
