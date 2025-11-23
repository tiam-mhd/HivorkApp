import 'package:universal_io/io.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/logger.dart';

/// ویجت مدیریت تصاویر تنوع محصول
class VariantImageManager extends StatefulWidget {
  final String? variantId;
  final String? mainImageUrl;
  final List<String>? imageUrls;
  final Function(File?)? onMainImageChanged;
  final Function(List<File>)? onImagesChanged;
  final Function(Uint8List?)? onMainImageBytesChanged; // برای وب
  final Function(List<Uint8List>)? onImagesBytesChanged; // برای وب
  final bool enabled;

  const VariantImageManager({
    Key? key,
    this.variantId,
    this.mainImageUrl,
    this.imageUrls,
    this.onMainImageChanged,
    this.onImagesChanged,
    this.onMainImageBytesChanged,
    this.onImagesBytesChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<VariantImageManager> createState() => _VariantImageManagerState();
}

class _VariantImageManagerState extends State<VariantImageManager> {
  final ImagePicker _picker = ImagePicker();
  File? _mainImageFile;
  List<File> _imageFiles = [];
  static const int _maxImages = 3;
  
  // برای وب
  Uint8List? _mainImageBytes;
  List<Uint8List> _imageBytes = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      color: isDark ? theme.cardColor : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // هدر
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تصاویر تنوع',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.blue.shade700 : Colors.blue.shade200,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'حداکثر $_maxImages عکس',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // عکس اصلی تنوع
            _buildMainImageSection(),
            const SizedBox(height: 16),
            // عکس‌های اضافی
            _buildAdditionalImagesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainImageSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عکس اصلی',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? theme.textTheme.bodyLarge?.color : Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: widget.enabled ? _pickMainImage : null,
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isDark ? Colors.grey.shade900.withOpacity(0.3) : Colors.grey.shade50,
              gradient: isDark ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade800.withOpacity(0.2),
                  Colors.grey.shade900.withOpacity(0.3),
                ],
              ) : null,
            ),
            child: _buildMainImageContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildMainImageContent() {
    // فایل جدید
    if (_mainImageFile != null || _mainImageBytes != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: kIsWeb && _mainImageBytes != null
                ? Image.memory(
                    _mainImageBytes!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    _mainImageFile!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          if (widget.enabled)
            Positioned(
              top: 4,
              right: 4,
              child: Row(
                children: [
                  _buildSmallIconButton(
                    icon: Icons.edit,
                    onTap: _pickMainImage,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  _buildSmallIconButton(
                    icon: Icons.delete,
                    onTap: _removeMainImage,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
        ],
      );
    }

    // URL موجود
    if (widget.mainImageUrl != null && widget.mainImageUrl!.isNotEmpty) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              widget.mainImageUrl!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder(compact: true);
              },
            ),
          ),
          if (widget.enabled)
            Positioned(
              top: 4,
              right: 4,
              child: _buildSmallIconButton(
                icon: Icons.edit,
                onTap: _pickMainImage,
                color: Colors.blue,
              ),
            ),
        ],
      );
    }

    return _buildPlaceholder(compact: true);
  }

  Widget _buildPlaceholder({bool compact = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: compact ? 40 : 48,
          color: isDark ? Colors.blue.shade300 : Colors.grey.shade400,
        ),
        const SizedBox(height: 6),
        Text(
          'انتخاب عکس',
          style: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
            fontSize: compact ? 12 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalImagesSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalImages = _imageFiles.length + (widget.imageUrls?.length ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'عکس‌های اضافی',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? theme.textTheme.bodyLarge?.color : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: totalImages >= _maxImages 
                    ? (isDark ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50)
                    : (isDark ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: totalImages >= _maxImages 
                      ? (isDark ? Colors.red.shade700 : Colors.red.shade300)
                      : (isDark ? Colors.green.shade700 : Colors.green.shade300),
                  width: 1,
                ),
              ),
              child: Text(
                '$totalImages/$_maxImages',
                style: TextStyle(
                  color: totalImages >= _maxImages 
                      ? (isDark ? Colors.red.shade300 : Colors.red.shade700)
                      : (isDark ? Colors.green.shade300 : Colors.green.shade700),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // دکمه افزودن
              if (widget.enabled && totalImages < _maxImages)
                _buildAddImageButton(),
              // عکس‌های جدید
              ...List.generate(_imageFiles.length, (index) {
                return _buildImageTile(
                  file: _imageFiles[index],
                  bytes: kIsWeb && index < _imageBytes.length ? _imageBytes[index] : null,
                );
              }),
              // عکس‌های موجود
              if (widget.imageUrls != null)
                ...widget.imageUrls!.map((url) => _buildImageTile(url: url)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: _pickAdditionalImages,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.blue.shade700 : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isDark ? Colors.blue.shade900.withOpacity(0.2) : Colors.grey.shade50,
          gradient: isDark ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade800.withOpacity(0.2),
              Colors.blue.shade900.withOpacity(0.3),
            ],
          ) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 28,
              color: isDark ? Colors.blue.shade300 : Colors.blue.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              'افزودن',
              style: TextStyle(
                color: isDark ? Colors.blue.shade200 : Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile({File? file, String? url, Uint8List? bytes}) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(left: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: kIsWeb && bytes != null
                ? Image.memory(
                    bytes,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                : file != null
                    ? Image.file(
                        file,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        url!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey.shade400,
                              size: 24,
                            ),
                          );
                        },
                      ),
          ),
          if (widget.enabled)
            Positioned(
              top: 2,
              right: 2,
              child: _buildSmallIconButton(
                icon: Icons.close,
                onTap: () => _removeImage(file: file, url: url, bytes: bytes),
                color: Colors.red,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSmallIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    double size = 18,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: size,
          color: color,
        ),
      ),
    );
  }

  Future<void> _pickMainImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _mainImageBytes = bytes;
            _mainImageFile = File(image.path);
          });
          widget.onMainImageBytesChanged?.call(bytes); // callback برای bytes
        } else {
          setState(() {
            _mainImageFile = File(image.path);
          });
        }
        widget.onMainImageChanged?.call(File(image.path));
        Logger.success('Variant main image selected');
      }
    } catch (e) {
      Logger.error('Error picking variant main image', e);
      if (mounted) {
        _showError('خطا در انتخاب عکس: ${e.toString()}');
      }
    }
  }

  Future<void> _pickAdditionalImages() async {
    try {
      final remainingSlots = _maxImages - _imageFiles.length - (widget.imageUrls?.length ?? 0);

      if (remainingSlots <= 0) {
        _showError('حداکثر $_maxImages عکس مجاز است');
        return;
      }

      final List<XFile> images = await _picker.pickMultiImage(
        requestFullMetadata: false,
      );

      if (images.isNotEmpty) {
        final selectedImages = images.take(remainingSlots).toList();
        
        if (kIsWeb) {
          final newBytes = <Uint8List>[];
          final newFiles = <File>[];
          
          for (var xFile in selectedImages) {
            final bytes = await xFile.readAsBytes();
            newBytes.add(bytes);
            newFiles.add(File(xFile.path));
          }
          
          setState(() {
            _imageBytes.addAll(newBytes);
            _imageFiles.addAll(newFiles);
          });
          widget.onImagesBytesChanged?.call(_imageBytes); // callback برای bytes
        } else {
          final newFiles = selectedImages.map((xFile) => File(xFile.path)).toList();
          setState(() {
            _imageFiles.addAll(newFiles);
          });
        }
        
        widget.onImagesChanged?.call(_imageFiles);
        Logger.success('${selectedImages.length} variant images selected');
      }
    } catch (e) {
      Logger.error('Error picking additional variant images', e);
      if (mounted) {
        _showError('خطا در انتخاب عکس‌ها: ${e.toString()}');
      }
    }
  }

  void _removeMainImage() {
    setState(() {
      _mainImageFile = null;
      _mainImageBytes = null;
    });
    widget.onMainImageChanged?.call(null);
    Logger.info('Variant main image removed');
  }

  void _removeImage({File? file, String? url, Uint8List? bytes}) {
    setState(() {
      if (file != null) {
        final index = _imageFiles.indexOf(file);
        if (index != -1) {
          _imageFiles.removeAt(index);
          if (kIsWeb && index < _imageBytes.length) {
            _imageBytes.removeAt(index);
          }
        }
        widget.onImagesChanged?.call(_imageFiles);
      }
    });
    Logger.info('Variant image removed');
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
