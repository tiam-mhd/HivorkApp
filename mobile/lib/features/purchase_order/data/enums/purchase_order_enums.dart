/// Purchase Order Status Enum
/// مطابق با backend: PurchaseOrderStatus
enum PurchaseOrderStatus {
  draft('draft', 'پیش‌نویس'),
  pending('pending', 'در انتظار تایید'),
  approved('approved', 'تایید شده'),
  sent('sent', 'ارسال شده'),
  confirmed('confirmed', 'تایید شده توسط تامین‌کننده'),
  partiallyReceived('partially_received', 'دریافت جزئی'),
  received('received', 'دریافت کامل'),
  cancelled('cancelled', 'لغو شده'),
  closed('closed', 'بسته شده');

  final String value;
  final String label;

  const PurchaseOrderStatus(this.value, this.label);

  static PurchaseOrderStatus fromString(String value) {
    return PurchaseOrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PurchaseOrderStatus.draft,
    );
  }
}

/// Purchase Order Type Enum
/// مطابق با backend: PurchaseOrderType
enum PurchaseOrderType {
  standard('standard', 'استاندارد'),
  dropShip('drop_ship', 'ارسال مستقیم'),
  blanket('blanket', 'سفارش چتری'),
  contract('contract', 'قراردادی'),
  b2bOrder('b2b_order', 'سفارش B2B');

  final String value;
  final String label;

  const PurchaseOrderType(this.value, this.label);

  static PurchaseOrderType fromString(String value) {
    return PurchaseOrderType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PurchaseOrderType.standard,
    );
  }
}

/// Payment Method Enum
/// مطابق با backend: PaymentMethod
enum PaymentMethod {
  cash('cash', 'نقد'),
  bankTransfer('bank_transfer', 'انتقال بانکی'),
  check('check', 'چک'),
  creditCard('credit_card', 'کارت اعتباری'),
  promissoryNote('promissory_note', 'سفته'),
  other('other', 'سایر');

  final String value;
  final String label;

  const PaymentMethod(this.value, this.label);

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

/// Payment Status Enum
/// مطابق با backend: PaymentStatus
enum PaymentStatus {
  pending('pending', 'در انتظار'),
  completed('completed', 'تکمیل شده'),
  failed('failed', 'ناموفق'),
  cancelled('cancelled', 'لغو شده');

  final String value;
  final String label;

  const PaymentStatus(this.value, this.label);

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

/// Receipt Status Enum
/// مطابق با backend: ReceiptStatus
enum ReceiptStatus {
  draft('draft', 'پیش‌نویس'),
  completed('completed', 'تکمیل شده'),
  cancelled('cancelled', 'لغو شده');

  final String value;
  final String label;

  const ReceiptStatus(this.value, this.label);

  static ReceiptStatus fromString(String value) {
    return ReceiptStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReceiptStatus.draft,
    );
  }
}
