import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/customer.dart';

class CustomerListItem extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool selectionMode; // برای حالت انتخاب
  final bool isSelected; // آیا این مشتری انتخاب شده است

  const CustomerListItem({
    Key? key,
    required this.customer,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.selectionMode = false,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numberFormat = NumberFormat('#,###', 'fa_IR');

    return Card(
      elevation: isSelected ? 4 : 1,
      margin: EdgeInsets.zero,
      color: isSelected 
          ? theme.colorScheme.primaryContainer.withOpacity(0.5)
          : null,
      shape: isSelected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.primary, width: 2),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.3)
                    : _getStatusColor().withOpacity(0.15),
                foregroundColor: isSelected 
                    ? theme.colorScheme.primary
                    : _getStatusColor(),
                child: customer.avatar != null
                    ? ClipOval(
                        child: Image.network(
                          customer.avatar!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildInitials(),
                        ),
                      )
                    : _buildInitials(),
              ),
              const SizedBox(width: 12),
              
              // اطلاعات اصلی
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // نام و بج وضعیت
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            customer.displayName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _buildCompactStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // گروه مشتری
                    Row(
                      children: [
                        Icon(
                          Icons.group_outlined,
                          size: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          customer.groupDisplayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    // شماره تلفن
                    if (customer.phone != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        customer.phone!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // مانده حساب
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${numberFormat.format(customer.currentBalance.abs())}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getBalanceColor(),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    customer.hasDebt
                        ? 'بدهکار'
                        : customer.hasCredit
                            ? 'بستانکار'
                            : 'تسویه',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getBalanceColor(),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 8),
              
              // دکمه‌های عملیات یا آیکون انتخاب
              if (selectionMode) ...[
                // در حالت انتخاب فقط آیکون نشان می‌دهیم
                if (isSelected)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
              ] else ...[
                // دکمه‌های عملیات در حالت عادی
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (customer.phone != null)
                      IconButton(
                        icon: Icon(
                          Icons.phone_outlined,
                          size: 20,
                          color: Colors.green.shade600,
                        ),
                        onPressed: () async {
                          final uri = Uri(scheme: 'tel', path: customer.phone);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        tooltip: 'تماس',
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      tooltip: 'ویرایش',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red,
                      ),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      tooltip: 'حذف',
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitials() {
    final initials = customer.fullName
        .split(' ')
        .take(2)
        .map((word) => word.isNotEmpty ? word[0] : '')
        .join()
        .toUpperCase();
    
    return Text(
      initials,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCompactStatusBadge() {
    final statusText = customer.status == CustomerStatus.active
        ? 'فعال'
        : customer.status == CustomerStatus.inactive
            ? 'غیرفعال'
            : 'مسدود';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _getStatusColor().withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 10,
              color: _getStatusColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (customer.status) {
      case CustomerStatus.active:
        return Colors.green;
      case CustomerStatus.inactive:
        return Colors.orange;
      case CustomerStatus.blocked:
        return Colors.red;
    }
  }

  Color _getBalanceColor() {
    if (customer.hasDebt) return Colors.red;
    if (customer.hasCredit) return Colors.green;
    return Colors.grey;
  }
}
