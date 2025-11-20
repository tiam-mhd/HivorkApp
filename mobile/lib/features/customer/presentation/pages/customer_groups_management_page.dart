import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/models/customer_group.dart';
import '../../data/services/customer_group_api_service.dart';

class CustomerGroupsManagementPage extends StatefulWidget {
  final String businessId;

  const CustomerGroupsManagementPage({
    Key? key,
    required this.businessId,
  }) : super(key: key);

  @override
  State<CustomerGroupsManagementPage> createState() =>
      _CustomerGroupsManagementPageState();
}

class _CustomerGroupsManagementPageState
    extends State<CustomerGroupsManagementPage> {
  late CustomerGroupApiService _apiService;
  List<CustomerGroup> _groups = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final dio = ServiceLocator().dio;
    _apiService = CustomerGroupApiService(dio);
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() => _loading = true);
    try {
      final groups = await _apiService.getGroups(widget.businessId);
      setState(() {
        _groups = groups;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری گروه‌ها: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت گروه‌بندی مشتریان'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'هنوز گروهی ایجاد نشده',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _groups.length,
                  onReorder: (oldIndex, newIndex) {
                    // TODO: Implement reordering
                  },
                  itemBuilder: (context, index) {
                    final group = _groups[index];
                    return Card(
                      key: ValueKey(group.id),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: group.color != null
                            ? CircleAvatar(
                                backgroundColor: _parseColor(group.color!),
                                child: const Icon(Icons.folder, color: Colors.white),
                              )
                            : const CircleAvatar(child: Icon(Icons.folder)),
                        title: Text(group.name),
                        subtitle: group.description != null
                            ? Text(group.description!)
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (group.customerCount != null && group.customerCount! > 0)
                              Chip(
                                label: Text('${group.customerCount}'),
                                backgroundColor: Colors.blue.shade50,
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showGroupForm(group),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(group),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGroupForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  void _showGroupForm(CustomerGroup? group) {
    final nameController = TextEditingController(text: group?.name);
    final descController = TextEditingController(text: group?.description);
    Color selectedColor = group?.color != null 
        ? _parseColor(group!.color!) 
        : Colors.blue;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(group == null ? 'افزودن گروه جدید' : 'ویرایش گروه'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'نام گروه',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'توضیحات',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
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
                  const SnackBar(content: Text('نام گروه الزامی است')),
                );
                return;
              }

              Navigator.pop(context);
              
              try {
                final colorHex = '#${selectedColor.value.toRadixString(16).substring(2)}';
                
                if (group == null) {
                  await _apiService.createGroup({
                    'name': nameController.text,
                    'description': descController.text,
                    'color': colorHex,
                    'businessId': widget.businessId,
                  });
                } else {
                  await _apiService.updateGroup(
                    group.id,
                    widget.businessId,
                    {
                      'name': nameController.text,
                      'description': descController.text,
                      'color': colorHex,
                    },
                  );
                }
                
                _loadGroups();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(group == null 
                          ? 'گروه با موفقیت ایجاد شد'
                          : 'گروه با موفقیت بروزرسانی شد'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطا: $e')),
                  );
                }
              }
            },
            child: Text(group == null ? 'ایجاد' : 'بروزرسانی'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(CustomerGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف گروه'),
        content: Text(
          'آیا از حذف گروه "${group.name}" اطمینان دارید؟\n\n'
          'مشتریان این گروه به گروه عمومی منتقل خواهند شد.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await _apiService.deleteGroup(group.id, widget.businessId);
                _loadGroups();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('گروه حذف شد')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطا در حذف گروه: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
