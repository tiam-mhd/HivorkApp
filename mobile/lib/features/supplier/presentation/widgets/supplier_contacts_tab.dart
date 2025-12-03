import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/supplier_provider.dart';

class SupplierContactsTab extends StatefulWidget {
  final String businessId;
  final String supplierId;

  const SupplierContactsTab({Key? key, required this.businessId, required this.supplierId}) : super(key: key);

  @override
  State<SupplierContactsTab> createState() => _SupplierContactsTabState();
}

class _SupplierContactsTabState extends State<SupplierContactsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContacts();
    });
  }

  Future<void> _loadContacts() async {
    if (widget.businessId.isEmpty) return;

    final provider = context.read<SupplierProvider>();
    await provider.loadContacts(widget.supplierId, widget.businessId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SupplierProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingContacts) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.contacts, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('هیچ مخاطبی ثبت نشده'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showContactDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('افزودن مخاطب'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadContacts,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.contacts.length,
              itemBuilder: (context, index) {
                final contact = provider.contacts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(contact.name[0].toUpperCase()),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(contact.name)),
                        if (contact.isPrimary)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'اصلی',
                              style: TextStyle(fontSize: 10, color: Colors.blue),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (contact.position != null)
                          Text('سمت: ${contact.position}'),
                        if (contact.phone != null)
                          Text('تلفن: ${contact.phone}'),
                        if (contact.email != null)
                          Text('ایمیل: ${contact.email}'),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('ویرایش'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('حذف', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showContactDialog(contact: contact);
                        } else if (value == 'delete') {
                          _deleteContact(contact.id);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showContactDialog({contact}) {
    final nameController = TextEditingController(text: contact?.name);
    final positionController = TextEditingController(text: contact?.position);
    final phoneController = TextEditingController(text: contact?.phone);
    final emailController = TextEditingController(text: contact?.email);
    bool isPrimary = contact?.isPrimary ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(contact == null ? 'افزودن مخاطب' : 'ویرایش مخاطب'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'نام *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: positionController,
                  decoration: const InputDecoration(
                    labelText: 'سمت',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'تلفن',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'ایمیل',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('مخاطب اصلی'),
                  value: isPrimary,
                  onChanged: (value) {
                    setState(() {
                      isPrimary = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('نام الزامی است')),
                  );
                  return;
                }

                if (widget.businessId.isEmpty) return;

                final provider = context.read<SupplierProvider>();
                final data = {
                  'name': nameController.text,
                  'position': positionController.text.isEmpty ? null : positionController.text,
                  'phone': phoneController.text.isEmpty ? null : phoneController.text,
                  'email': emailController.text.isEmpty ? null : emailController.text,
                  'isPrimary': isPrimary,
                };

                bool success;
                if (contact == null) {
                  success = await provider.createContact(
                    widget.supplierId,
                    widget.businessId,
                    data,
                  );
                } else {
                  success = await provider.updateContact(
                    widget.supplierId,
                    contact.id,
                    widget.businessId,
                    data,
                  );
                }

                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(contact == null ? 'مخاطب افزوده شد' : 'مخاطب ویرایش شد'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.error ?? 'خطا در انجام عملیات'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(contact == null ? 'افزودن' : 'ذخیره'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteContact(String contactId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف مخاطب'),
        content: const Text('آیا از حذف این مخاطب اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (widget.businessId.isEmpty) return;

    final provider = context.read<SupplierProvider>();
    final success = await provider.deleteContact(
      widget.supplierId,
      contactId,
      widget.businessId,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('مخاطب حذف شد'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'خطا در حذف مخاطب'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
