import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/expense_provider.dart';
import '../../../core/utils/formatters.dart';

class ExpenseAttachmentsPage extends StatefulWidget {
  final String expenseId;
  final String expenseTitle;

  const ExpenseAttachmentsPage({
    super.key,
    required this.expenseId,
    required this.expenseTitle,
  });

  @override
  State<ExpenseAttachmentsPage> createState() => _ExpenseAttachmentsPageState();
}

class _ExpenseAttachmentsPageState extends State<ExpenseAttachmentsPage> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _attachments = [];
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadAttachments();
  }

  Future<void> _loadAttachments() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<ExpenseProvider>();
      // در واقع باید از backend بگیریم، اما فعلاً mock داریم
      // TODO: Implement actual API call to get attachments
      setState(() => _attachments = []);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری پیوست‌ها: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadFile(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در انتخاب تصویر: $e')),
        );
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        for (final image in images) {
          await _uploadFile(image);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در انتخاب تصاویر: $e')),
        );
      }
    }
  }

  Future<void> _pickDocument() async {
    // TODO: Implement file_picker for documents (PDF, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('قابلیت انتخاب فایل به زودی اضافه می‌شود')),
    );
  }

  Future<void> _uploadFile(XFile file) async {
    setState(() => _isUploading = true);
    try {
      final provider = context.read<ExpenseProvider>();
      
      // TODO: Implement actual upload to backend
      // await provider.uploadAttachment(widget.expenseId, file);
      
      final fileInfo = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': file.name,
        'path': file.path,
        'size': await File(file.path).length(),
        'type': file.mimeType ?? 'image/jpeg',
        'uploadedAt': DateTime.now(),
      };

      setState(() {
        _attachments.add(fileInfo);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فایل با موفقیت آپلود شد'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در آپلود فایل: $e')),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteAttachment(String attachmentId, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف پیوست'),
        content: const Text('آیا از حذف این پیوست اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // TODO: Implement actual delete from backend
        // await context.read<ExpenseProvider>().deleteAttachment(widget.expenseId, attachmentId);
        
        setState(() {
          _attachments.removeAt(index);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('پیوست با موفقیت حذف شد'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطا در حذف پیوست: $e')),
          );
        }
      }
    }
  }

  void _viewAttachment(Map<String, dynamic> attachment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttachmentViewerPage(attachment: attachment),
      ),
    );
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('دوربین'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('گالری (یک تصویر)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: Colors.orange),
                title: const Text('گالری (چند تصویر)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMultipleImages();
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file, color: Colors.purple),
                title: const Text('فایل (PDF، سند)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickDocument();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('پیوست‌ها'),
              Text(
                widget.expenseTitle,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _attachments.isEmpty
                ? _buildEmptyState()
                : _buildAttachmentsList(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isUploading ? null : _showUploadOptions,
          icon: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.add),
          label: Text(_isUploading ? 'در حال آپلود...' : 'افزودن پیوست'),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.attach_file_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'هیچ پیوستی وجود ندارد',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'رسید یا فاکتور هزینه خود را اضافه کنید',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showUploadOptions,
            icon: const Icon(Icons.add),
            label: const Text('افزودن اولین پیوست'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _attachments.length,
      itemBuilder: (context, index) {
        final attachment = _attachments[index];
        final isImage = attachment['type']?.toString().startsWith('image/') ?? false;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _viewAttachment(attachment),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Thumbnail/Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: isImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(attachment['path']),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) => const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.insert_drive_file,
                            size: 32,
                            color: Colors.grey[600],
                          ),
                  ),
                  const SizedBox(width: 12),
                  // File Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attachment['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatFileSize(attachment['size']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          _formatDate(attachment['uploadedAt']),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  IconButton(
                    onPressed: () => _deleteAttachment(attachment['id'], index),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'حذف',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Attachment Viewer Page
class AttachmentViewerPage extends StatelessWidget {
  final Map<String, dynamic> attachment;

  const AttachmentViewerPage({
    super.key,
    required this.attachment,
  });

  @override
  Widget build(BuildContext context) {
    final isImage = attachment['type']?.toString().startsWith('image/') ?? false;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(attachment['name']),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: isImage
            ? InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  File(attachment['path']),
                  errorBuilder: (context, error, stack) => const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 64, color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'خطا در نمایش تصویر',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insert_drive_file, size: 64, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'پیش‌نمایش برای این نوع فایل موجود نیست',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}
