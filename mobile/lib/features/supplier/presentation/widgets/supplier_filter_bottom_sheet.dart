import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/supplier_provider.dart';
import '../../data/models/supplier_model.dart';

class SupplierFilterBottomSheet extends StatefulWidget {
  final String businessId;

  const SupplierFilterBottomSheet({
    Key? key,
    required this.businessId,
  }) : super(key: key);

  @override
  State<SupplierFilterBottomSheet> createState() =>
      _SupplierFilterBottomSheetState();
}

class _SupplierFilterBottomSheetState extends State<SupplierFilterBottomSheet> {
  SupplierStatus? _selectedStatus;
  SupplierType? _selectedType;
  String? _selectedCity;
  String? _selectedProvince;
  String? _selectedIndustry;

  final List<String> _cities = [
    'تهران',
    'اصفهان',
    'شیراز',
    'مشهد',
    'تبریز',
    'کرج',
  ];

  final List<String> _provinces = [
    'تهران',
    'اصفهان',
    'فارس',
    'خراسان رضوی',
    'آذربایجان شرقی',
    'البرز',
  ];

  final List<String> _industries = [
    'تولید',
    'توزیع',
    'خدمات',
    'فناوری',
    'غذایی',
    'پوشاک',
    'ساختمان',
    'الکترونیک',
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<SupplierProvider>();
    _selectedStatus = provider.statusFilter;
    _selectedType = provider.typeFilter;
    _selectedCity = provider.cityFilter;
    _selectedProvince = provider.provinceFilter;
    _selectedIndustry = provider.industryFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'فیلتر تامین‌کنندگان',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('پاک کردن همه'),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Status Filter
          const Text(
            'وضعیت',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...SupplierStatus.values.map((status) {
                final isSelected = _selectedStatus == status;
                return FilterChip(
                  label: Text(status.statusText),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? status : null;
                    });
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // Type Filter
          const Text(
            'نوع تامین‌کننده',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...SupplierType.values.map((type) {
                final isSelected = _selectedType == type;
                return FilterChip(
                  label: Text(type.typeText),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? type : null;
                    });
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // City Filter
          DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: const InputDecoration(
              labelText: 'شهر',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('همه')),
              ..._cities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Province Filter
          DropdownButtonFormField<String>(
            value: _selectedProvince,
            decoration: const InputDecoration(
              labelText: 'استان',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('همه')),
              ..._provinces.map((province) {
                return DropdownMenuItem(
                  value: province,
                  child: Text(province),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedProvince = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Industry Filter
          DropdownButtonFormField<String>(
            value: _selectedIndustry,
            decoration: const InputDecoration(
              labelText: 'صنعت',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('همه')),
              ..._industries.map((industry) {
                return DropdownMenuItem(
                  value: industry,
                  child: Text(industry),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedIndustry = value;
              });
            },
          ),
          const SizedBox(height: 24),

          // Apply Button
          ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('اعمال فیلتر'),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedType = null;
      _selectedCity = null;
      _selectedProvince = null;
      _selectedIndustry = null;
    });

    final provider = context.read<SupplierProvider>();
    provider.clearFilters();
    provider.loadSuppliers(widget.businessId);

    Navigator.pop(context);
  }

  void _applyFilters() {
    final provider = context.read<SupplierProvider>();

    provider.setStatusFilter(_selectedStatus);
    provider.setTypeFilter(_selectedType);
    provider.setCityFilter(_selectedCity);
    provider.setProvinceFilter(_selectedProvince);
    provider.setIndustryFilter(_selectedIndustry);

    provider.loadSuppliers(widget.businessId);

    Navigator.pop(context);
  }
}
