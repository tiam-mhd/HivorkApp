import 'package:json_annotation/json_annotation.dart';

part 'contact_model.g.dart';

@JsonSerializable()
class Contact {
  final String id;
  final String supplierId;
  final String firstName;
  final String lastName;
  final String? position;
  final String? department;
  final String? phone;
  final String? mobile;
  final String email;
  final String? whatsapp;
  final String? telegram;
  final String? linkedin;
  final bool isPrimary;
  final bool isActive;
  final List<String>? roles;
  final String? notes;
  final DateTime? birthday;
  final String? preferredLanguage;
  final String? preferredContactMethod;
  
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Contact({
    required this.id,
    required this.supplierId,
    required this.firstName,
    required this.lastName,
    this.position,
    this.department,
    this.phone,
    this.mobile,
    required this.email,
    this.whatsapp,
    this.telegram,
    this.linkedin,
    this.isPrimary = false,
    this.isActive = true,
    this.roles,
    this.notes,
    this.birthday,
    this.preferredLanguage,
    this.preferredContactMethod,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);
  Map<String, dynamic> toJson() => _$ContactToJson(this);

  String get fullName => '$firstName $lastName';
  
  String get displayContact {
    if (mobile != null) return mobile!;
    if (phone != null) return phone!;
    return email;
  }
  
  // For backwards compatibility
  String get name => fullName;
}
