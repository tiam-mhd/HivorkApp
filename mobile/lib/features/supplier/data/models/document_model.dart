import 'package:json_annotation/json_annotation.dart';

part 'document_model.g.dart';

enum SupplierDocumentType {
  @JsonValue('contract')
  contract,
  @JsonValue('certificate')
  certificate,
  @JsonValue('license')
  license,
  @JsonValue('insurance')
  insurance,
  @JsonValue('quality_cert')
  qualityCert,
  @JsonValue('tax_document')
  taxDocument,
  @JsonValue('bank_info')
  bankInfo,
  @JsonValue('id_document')
  idDocument,
  @JsonValue('other')
  other,
}

enum DocumentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('expired')
  expired,
}

extension SupplierDocumentTypeExtension on SupplierDocumentType {
  String get displayName {
    switch (this) {
      case SupplierDocumentType.contract:
        return 'قرارداد';
      case SupplierDocumentType.certificate:
        return 'گواهینامه';
      case SupplierDocumentType.license:
        return 'مجوز';
      case SupplierDocumentType.insurance:
        return 'بیمه';
      case SupplierDocumentType.qualityCert:
        return 'گواهی کیفیت';
      case SupplierDocumentType.taxDocument:
        return 'مدارک مالیاتی';
      case SupplierDocumentType.bankInfo:
        return 'اطلاعات بانکی';
      case SupplierDocumentType.idDocument:
        return 'مدرک شناسایی';
      case SupplierDocumentType.other:
        return 'سایر';
    }
  }
}

extension DocumentStatusExtension on DocumentStatus {
  String get displayName {
    switch (this) {
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

@JsonSerializable()
class SupplierDocument {
  final String id;
  final String supplierId;
  final SupplierDocumentType type;
  final String title;
  final String filePath;
  final String originalFileName;
  final String? mimeType;
  final int? fileSize;
  final DocumentStatus status;
  
  final String? documentNumber;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? issuedBy;
  
  final String? description;
  final String? notes;
  
  // Approval info
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? rejectionReason;
  
  final List<String>? tags;
  
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  SupplierDocument({
    required this.id,
    required this.supplierId,
    required this.type,
    required this.title,
    required this.filePath,
    required this.originalFileName,
    this.mimeType,
    this.fileSize,
    this.status = DocumentStatus.pending,
    this.documentNumber,
    this.issueDate,
    this.expiryDate,
    this.issuedBy,
    this.description,
    this.notes,
    this.approvedAt,
    this.approvedBy,
    this.rejectionReason,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory SupplierDocument.fromJson(Map<String, dynamic> json) =>
      _$SupplierDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$SupplierDocumentToJson(this);

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  bool get isPending => status == DocumentStatus.pending;
  bool get isApproved => status == DocumentStatus.approved;
  bool get isRejected => status == DocumentStatus.rejected;
  
  String get fileName => originalFileName;
  String get typeText => type.displayName;
  String get statusText => status.displayName;
}
