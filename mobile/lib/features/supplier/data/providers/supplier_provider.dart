import 'package:flutter/foundation.dart';
import '../models/supplier_model.dart';
import '../models/contact_model.dart';
import '../models/supplier_product_model.dart';
import '../models/document_model.dart';
import '../dtos/supplier_dtos.dart';
import '../services/supplier_api_service.dart';
import '../services/contact_api_service.dart';
import '../services/supplier_product_api_service.dart';
import '../services/document_api_service.dart';

class SupplierProvider with ChangeNotifier {
  final SupplierApiService _supplierApiService;
  final ContactApiService _contactApiService;
  final SupplierProductApiService _supplierProductApiService;
  final DocumentApiService _documentApiService;

  SupplierProvider(
    this._supplierApiService,
    this._contactApiService,
    this._supplierProductApiService,
    this._documentApiService,
  );

  // State
  List<Supplier> _suppliers = [];
  Supplier? _selectedSupplier;
  List<Contact> _contacts = [];
  List<SupplierProduct> _supplierProducts = [];
  List<SupplierDocument> _documents = [];
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _pagination;
  
  bool _isLoading = false;
  bool _isLoadingContacts = false;
  bool _isLoadingProducts = false;
  bool _isLoadingDocuments = false;
  String? _error;

  // Filters
  SupplierStatus? _statusFilter;
  SupplierType? _typeFilter;
  String? _cityFilter;
  String? _provinceFilter;
  String? _industryFilter;
  String? _searchQuery;

  // Getters
  List<Supplier> get suppliers => _suppliers;
  Supplier? get selectedSupplier => _selectedSupplier;
  List<Contact> get contacts => _contacts;
  List<SupplierProduct> get supplierProducts => _supplierProducts;
  List<SupplierDocument> get documents => _documents;
  List<SupplierDocument> get supplierDocuments => _documents;
  Map<String, dynamic>? get stats => _stats;
  Map<String, dynamic>? get pagination => _pagination;
  
  bool get isLoading => _isLoading;
  bool get isLoadingContacts => _isLoadingContacts;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingDocuments => _isLoadingDocuments;
  String? get error => _error;

  SupplierStatus? get statusFilter => _statusFilter;
  SupplierType? get typeFilter => _typeFilter;
  String? get cityFilter => _cityFilter;
  String? get provinceFilter => _provinceFilter;
  String? get industryFilter => _industryFilter;
  String? get searchQuery => _searchQuery;

  bool get hasActiveFilters =>
      _statusFilter != null ||
      _typeFilter != null ||
      _cityFilter != null ||
      _provinceFilter != null ||
      _industryFilter != null ||
      _searchQuery != null;

  // ========================
  // Supplier CRUD
  // ========================

  /// Load suppliers with filters
  Future<void> loadSuppliers(String businessId, {int page = 1, int limit = 50}) async {
    print('🔥 PROVIDER DEBUG: loadSuppliers called with businessId = "$businessId"');
    
    if (businessId.isEmpty) {
      print('❌ PROVIDER ERROR: businessId is empty!');
      _error = 'شناسه کسب‌وکار موجود نیست';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final filter = FilterSuppliersDto(
        status: _statusFilter?.name,
        type: _typeFilter?.name,
        city: _cityFilter,
        province: _provinceFilter,
        industry: _industryFilter,
        search: _searchQuery,
        page: page,
        limit: limit,
      );
      
      print('🔥 PROVIDER DEBUG: Filter created = $filter');

      final result = await _supplierApiService.getSuppliers(
        businessId: businessId,
        filter: filter,
      );
      
      print('🔥 PROVIDER DEBUG: Got result, suppliers count = ${(result['data'] as List).length}');

      _suppliers = result['data'] as List<Supplier>;
      _pagination = result['pagination'];
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _suppliers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load supplier by ID
  Future<void> loadSupplier(String id, String businessId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedSupplier = await _supplierApiService.getSupplierById(
        id: id,
        businessId: businessId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _selectedSupplier = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create supplier
  Future<Supplier?> createSupplier(String businessId, CreateSupplierDto dto) async {
    print('🔥 PROVIDER DEBUG: createSupplier called');
    print('🔥 PROVIDER DEBUG: businessId = $businessId');
    print('🔥 PROVIDER DEBUG: dto = $dto');
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔥 PROVIDER DEBUG: Calling API service...');
      final supplier = await _supplierApiService.createSupplier(
        businessId: businessId,
        dto: dto,
      );
      print('🔥 PROVIDER DEBUG: API call successful');
      print('🔥 PROVIDER DEBUG: Created supplier = ${supplier.id}');
      _suppliers.insert(0, supplier);
      _error = null;
      notifyListeners();
      return supplier;
    } catch (e) {
      print('🔥 PROVIDER DEBUG: Error occurred!');
      print('🔥 PROVIDER DEBUG: Error = $e');
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update supplier
  Future<bool> updateSupplier(
    String id,
    String businessId,
    UpdateSupplierDto dto,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedSupplier = await _supplierApiService.updateSupplier(
        id: id,
        businessId: businessId,
        dto: dto,
      );

      final index = _suppliers.indexWhere((s) => s.id == id);
      if (index != -1) {
        _suppliers[index] = updatedSupplier;
      }

      if (_selectedSupplier?.id == id) {
        _selectedSupplier = updatedSupplier;
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete supplier
  Future<bool> deleteSupplier(String id, String businessId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supplierApiService.deleteSupplier(
        id: id,
        businessId: businessId,
      );

      _suppliers.removeWhere((s) => s.id == id);
      if (_selectedSupplier?.id == id) {
        _selectedSupplier = null;
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change supplier status
  Future<bool> changeSupplierStatus(
    String id,
    String businessId,
    SupplierStatus status,
    String? reason,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dto = ChangeSupplierStatusDto(
        status: status.name.toUpperCase(),
        reason: reason,
      );

      final updatedSupplier = await _supplierApiService.changeSupplierStatus(
        id: id,
        businessId: businessId,
        dto: dto,
      );

      final index = _suppliers.indexWhere((s) => s.id == id);
      if (index != -1) {
        _suppliers[index] = updatedSupplier;
      }

      if (_selectedSupplier?.id == id) {
        _selectedSupplier = updatedSupplier;
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load supplier stats
  Future<void> loadSupplierStats(String id, String businessId) async {
    try {
      _stats = await _supplierApiService.getSupplierStats(
        id: id,
        businessId: businessId,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // ========================
  // Contacts
  // ========================

  /// Load contacts
  Future<void> loadContacts(String supplierId, String businessId) async {
    _isLoadingContacts = true;
    notifyListeners();

    try {
      _contacts = await _contactApiService.getContacts(
        supplierId: supplierId,
        businessId: businessId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _contacts = [];
    } finally {
      _isLoadingContacts = false;
      notifyListeners();
    }
  }

  /// Create contact
  Future<bool> createContact(
    String supplierId,
    String businessId,
    Map<String, dynamic> data,
  ) async {
    try {
      final contact = await _contactApiService.createContact(
        supplierId: supplierId,
        businessId: businessId,
        data: data,
      );
      _contacts.add(contact);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Update contact
  Future<bool> updateContact(
    String supplierId,
    String id,
    String businessId,
    Map<String, dynamic> data,
  ) async {
    try {
      final updatedContact = await _contactApiService.updateContact(
        supplierId: supplierId,
        id: id,
        businessId: businessId,
        data: data,
      );

      final index = _contacts.indexWhere((c) => c.id == id);
      if (index != -1) {
        _contacts[index] = updatedContact;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Delete contact
  Future<bool> deleteContact(String supplierId, String id, String businessId) async {
    try {
      await _contactApiService.deleteContact(
        supplierId: supplierId,
        id: id,
        businessId: businessId,
      );

      _contacts.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ========================
  // Supplier Products
  // ========================

  /// Load supplier products
  Future<void> loadSupplierProducts(
    String supplierId,
    String businessId, {
    bool? isActive,
    bool? isPreferred,
  }) async {
    _isLoadingProducts = true;
    notifyListeners();

    try {
      _supplierProducts = await _supplierProductApiService.getSupplierProducts(
        supplierId: supplierId,
        businessId: businessId,
        isActive: isActive,
        isPreferred: isPreferred,
      );
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _supplierProducts = [];
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  /// Add product to supplier
  Future<bool> addProduct(
    String supplierId,
    String businessId,
    Map<String, dynamic> data,
  ) async {
    try {
      final product = await _supplierProductApiService.addProduct(
        supplierId: supplierId,
        businessId: businessId,
        data: data,
      );
      _supplierProducts.add(product);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Update supplier product
  Future<bool> updateSupplierProduct(
    String supplierId,
    String id,
    String businessId,
    Map<String, dynamic> data,
  ) async {
    try {
      final updated = await _supplierProductApiService.updateSupplierProduct(
        supplierId: supplierId,
        id: id,
        businessId: businessId,
        data: data,
      );

      final index = _supplierProducts.indexWhere((p) => p.id == id);
      if (index != -1) {
        _supplierProducts[index] = updated;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Remove product from supplier
  Future<bool> removeProduct(String supplierId, String id, String businessId) async {
    try {
      await _supplierProductApiService.removeProduct(
        supplierId: supplierId,
        id: id,
        businessId: businessId,
      );

      _supplierProducts.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ========================
  // Documents
  // ========================

  /// Load documents
  Future<void> loadDocuments(
    String supplierId,
    String businessId, {
    String? documentType,
    String? status,
  }) async {
    _isLoadingDocuments = true;
    notifyListeners();

    try {
      _documents = await _documentApiService.getDocuments(
        supplierId: supplierId,
        businessId: businessId,
        documentType: documentType,
        status: status,
      );
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _documents = [];
    } finally {
      _isLoadingDocuments = false;
      notifyListeners();
    }
  }

  /// Alias for loadDocuments
  Future<void> loadSupplierDocuments(
    String businessId,
    String supplierId, {
    String? documentType,
    String? status,
  }) async {
    return loadDocuments(
      supplierId,
      businessId,
      documentType: documentType,
      status: status,
    );
  }

  /// Upload document
  Future<bool> uploadDocument(
    String supplierId,
    String businessId,
    String filePath,
    String documentType, {
    String? documentNumber,
    String? issueDate,
    String? expiryDate,
    String? notes,
  }) async {
    try {
      final document = await _documentApiService.uploadDocument(
        supplierId: supplierId,
        businessId: businessId,
        filePath: filePath,
        documentType: documentType,
        documentNumber: documentNumber,
        issueDate: issueDate,
        expiryDate: expiryDate,
        notes: notes,
      );
      _documents.add(document);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Approve document
  Future<bool> approveDocument(
    String supplierId,
    String id,
    String businessId,
  ) async {
    try {
      final updated = await _documentApiService.approveDocument(
        supplierId: supplierId,
        id: id,
        businessId: businessId,
      );

      final index = _documents.indexWhere((d) => d.id == id);
      if (index != -1) {
        _documents[index] = updated;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Reject document
  Future<bool> rejectDocument(
    String supplierId,
    String id,
    String businessId,
    String reason,
  ) async {
    try {
      final updated = await _documentApiService.rejectDocument(
        supplierId: supplierId,
        id: id,
        businessId: businessId,
        reason: reason,
      );

      final index = _documents.indexWhere((d) => d.id == id);
      if (index != -1) {
        _documents[index] = updated;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Delete document
  Future<bool> deleteDocument(
    String supplierId,
    String id,
    String businessId,
  ) async {
    try {
      await _documentApiService.deleteDocument(
        supplierId: supplierId,
        id: id,
        businessId: businessId,
      );

      _documents.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ========================
  // Filters
  // ========================

  void setStatusFilter(SupplierStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setTypeFilter(SupplierType? type) {
    _typeFilter = type;
    notifyListeners();
  }

  void setCityFilter(String? city) {
    _cityFilter = city;
    notifyListeners();
  }

  void setProvinceFilter(String? province) {
    _provinceFilter = province;
    notifyListeners();
  }

  void setIndustryFilter(String? industry) {
    _industryFilter = industry;
    notifyListeners();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _typeFilter = null;
    _cityFilter = null;
    _provinceFilter = null;
    _industryFilter = null;
    _searchQuery = null;
    notifyListeners();
  }

  // ========================
  // Utility
  // ========================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedSupplier() {
    _selectedSupplier = null;
    _contacts = [];
    _supplierProducts = [];
    _documents = [];
    _stats = null;
    notifyListeners();
  }
}
