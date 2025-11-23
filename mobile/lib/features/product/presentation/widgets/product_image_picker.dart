import 'package:universal_io/io.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/logger.dart';

/// ویجت انتخاب و مدیریت تصاویر محصول
class ProductImagePicker extends StatefulWidget {
  final String? productId;
  final String? mainImageUrl;
  final List<String>? imageUrls;
  final Function(File?)? onMainImageChanged;
  final Function(List<File>)? onImagesChanged;
  final Function(Uint8List?)? onMainImageBytesChanged; // برای وب
  final Function(List<Uint8List>)? onImagesBytesChanged; // برای وب
  final bool enabled;
  final int maxImages;

  const ProductImagePicker({
    Key? key,
    this.productId,
    this.mainImageUrl,
    this.imageUrls,
    this.onMainImageChanged,
    this.onImagesChanged,
    this.onMainImageBytesChanged,
    this.onImagesBytesChanged,
    this.enabled = true,
    this.maxImages = 10,
  }) : super(key: key);

  @override
  State<ProductImagePicker> createState() => _ProductImagePickerState();
}

class _ProductImagePickerState extends State<ProductImagePicker> {
  final ImagePicker _picker = ImagePicker();
  File? _mainImageFile;
  List<File> _imageFiles = [];
  
  // برای وب
  Uint8List? _mainImageBytes;
  List<Uint8List> _imageBytes = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عکس اصلی
        _buildMainImageSection(),
        const SizedBox(height: 24),
        // عکس‌های اضافی
        _buildAdditionalImagesSection(),
      ],
    );
  }

  Widget _buildMainImageSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'عکس اصلی محصول',
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? Colors.orange.shade900.withOpacity(0.3) : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isDark ? Colors.orange.shade700 : Colors.orange.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                'الزامی',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.orange.shade300 : Colors.orange.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: widget.enabled ? _pickMainImage : null,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
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
    // اگر فایل جدید انتخاب شده
    if (_mainImageFile != null || _mainImageBytes != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
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
              top: 8,
              right: 8,
              child: Row(
                children: [
                  _buildIconButton(
                    icon: Icons.edit,
                    onTap: _pickMainImage,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
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

    // اگر URL موجود است
    if (widget.mainImageUrl != null && widget.mainImageUrl!.isNotEmpty) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              widget.mainImageUrl!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
            ),
          ),
          if (widget.enabled)
            Positioned(
              top: 8,
              right: 8,
              child: _buildIconButton(
                icon: Icons.edit,
                onTap: _pickMainImage,
                color: Colors.blue,
              ),
            ),
        ],
      );
    }

    // Placeholder
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.blue.shade900.withOpacity(0.2) : Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'انتخاب عکس اصلی',
          style: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'کلیک کنید',
          style: TextStyle(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
            fontSize: 14,
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
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: totalImages >= widget.maxImages 
                    ? (isDark ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50)
                    : (isDark ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: totalImages >= widget.maxImages 
                      ? (isDark ? Colors.red.shade700 : Colors.red.shade300)
                      : (isDark ? Colors.green.shade700 : Colors.green.shade300),
                  width: 1,
                ),
              ),
              child: Text(
                '$totalImages/${widget.maxImages}',
                style: TextStyle(
                  color: totalImages >= widget.maxImages 
                      ? (isDark ? Colors.red.shade300 : Colors.red.shade700)
                      : (isDark ? Colors.green.shade300 : Colors.green.shade700),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // دکمه افزودن
              if (widget.enabled &&
                  _imageFiles.length + (widget.imageUrls?.length ?? 0) <
                      widget.maxImages)
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
        width: 120,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.blue.shade700 : Colors.blue.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isDark ? Colors.blue.shade900.withOpacity(0.2) : Colors.blue.shade50,
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
              size: 36,
              color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
            ),
            const SizedBox(height: 6),
            Text(
              'افزودن',
              style: TextStyle(
                color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile({File? file, String? url, Uint8List? bytes}) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(left: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
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
                            ),
                          );
                        },
                      ),
          ),
          if (widget.enabled)
            Positioned(
              top: 4,
              right: 4,
              child: _buildIconButton(
                icon: Icons.close,
                onTap: () => _removeImage(file: file, url: url),
                color: Colors.red,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    double size = 24,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
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
            _mainImageFile = File(image.path); // برای callback
          });
          widget.onMainImageBytesChanged?.call(bytes); // callback برای bytes
        } else {
          setState(() {
            _mainImageFile = File(image.path);
          });
        }
        widget.onMainImageChanged?.call(File(image.path));
        Logger.success('Main image selected');
      }
    } catch (e) {
      Logger.error('Error picking main image', e);
      if (mounted) {
        _showError('خطا در انتخاب عکس: ${e.toString()}');
      }
    }
  }

  Future<void> _pickAdditionalImages() async {
    try {
      final remainingSlots =
          widget.maxImages - _imageFiles.length - (widget.imageUrls?.length ?? 0);

      if (remainingSlots <= 0) {
        _showError('حداکثر ${widget.maxImages} عکس مجاز است');
        return;
      }

      final List<XFile> images = await _picker.pickMultiImage(
        requestFullMetadata: false,
      );

      if (images.isNotEmpty) {
        final selectedImages = images.take(remainingSlots).toList();
        
        if (kIsWeb) {
          // خواندن bytes برای وب
          final newBytes = <Uint8List>[];
          final newFiles = <File>[];
          
          for (var xFile in selectedImages) {
            final bytes = await xFile.readAsBytes();
            newBytes.add(bytes);
            newFiles.add(File(xFile.path)); // برای callback
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
        Logger.success('${selectedImages.length} images selected');
      }
    } catch (e) {
      Logger.error('Error picking additional images', e);
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
    Logger.info('Main image removed');
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
    Logger.info('Image removed');
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
