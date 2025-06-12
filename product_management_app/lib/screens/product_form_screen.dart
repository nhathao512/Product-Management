import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({Key? key, this.product}) : super(key: key);

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  File? _selectedImage;

  late AnimationController _formAnimationController;
  late AnimationController _imageAnimationController;
  late AnimationController _submitAnimationController;

  late Animation<double> _formAnimation;
  late Animation<double> _imageAnimation;
  late Animation<double> _submitAnimation;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '',
    );

    // Initialize animation controllers
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _imageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _submitAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Create animations
    _formAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _imageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _imageAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _submitAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _submitAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _formAnimationController.forward();
    _imageAnimationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _formAnimationController.dispose();
    _imageAnimationController.dispose();
    _submitAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Start image selection animation
    _imageAnimationController.reset();

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      final imageSize = await imageFile.length();
      const maxSize = 100 * 1024 * 1024;
      String extension = path.extension(pickedFile.path).toLowerCase();
      const validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];

      if (!validExtensions.contains(extension)) {
        _showAnimatedSnackBar(
          'Định dạng ảnh không hợp lệ. Vui lòng chọn JPG, PNG, GIF hoặc WEBP.',
          Colors.orange,
          Icons.warning,
        );
        return;
      }

      if (imageSize > maxSize) {
        _showAnimatedSnackBar(
          'Ảnh quá lớn. Vui lòng chọn ảnh dưới 100MB.',
          Colors.orange,
          Icons.warning,
        );
        return;
      }

      final mimeType = await _getMimeType(imageFile);
      if (!mimeType.startsWith('image/')) {
        _showAnimatedSnackBar(
          'Tệp không phải là ảnh hợp lệ.',
          Colors.red,
          Icons.error,
        );
        return;
      }

      setState(() {
        _selectedImage = imageFile;
      });

      // Animate image container
      _imageAnimationController.forward();
    }
  }

  void _showAnimatedSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value.clamp(0.0, 1.0))),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Row(
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, iconValue, child) {
                        return Transform.scale(
                          scale: iconValue.clamp(0.0, 1.0),
                          child: Icon(icon, color: Colors.white),
                        );
                      },
                    ),
                    SizedBox(width: 8),
                    Expanded(child: Text(message)),
                  ],
                ),
              ),
            );
          },
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 3),
        elevation: 8,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<String> _getMimeType(File file) async {
    final bytes = await file.readAsBytes();
    if (bytes.length < 8) return 'application/octet-stream';
    final header =
        bytes
            .sublist(0, 8)
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join();
    if (header.startsWith('89504e47')) return 'image/png';
    if (header.startsWith('ffd8ff')) return 'image/jpeg';
    if (header.startsWith('47494638')) return 'image/gif';
    if (header.startsWith('52494646') && header.contains('57454250'))
      return 'image/webp';
    return 'application/octet-stream';
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      _submitAnimationController.forward();

      final request = CreateProductRequest(
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        image: _selectedImage,
      );

      final provider = Provider.of<ProductProvider>(context, listen: false);
      bool success;
      String message;

      if (widget.product == null) {
        success = await provider.createProduct(request);
        message =
            success ? 'Tạo sản phẩm thành công' : 'Lỗi: ${provider.error}';
      } else {
        success = await provider.updateProduct(widget.product!.id, request);
        message =
            success ? 'Cập nhật sản phẩm thành công' : 'Lỗi: ${provider.error}';
      }

      setState(() {
        _isSubmitting = false;
      });

      _submitAnimationController.reset();

      // Quay về màn hình trước với thông báo
      Navigator.pop(context, {'success': success, 'message': message});
    }
  }

  Widget _buildAnimatedFormField({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value.clamp(0.0, 1.0))),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Tạo sản phẩm' : 'Sửa sản phẩm'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _formAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated form fields
                  _buildAnimatedFormField(
                    delay: 0,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên sản phẩm',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.shopping_bag),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên sản phẩm';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  _buildAnimatedFormField(
                    delay: 100,
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.description),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mô tả';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildAnimatedFormField(
                          delay: 200,
                          child: TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              labelText: 'Giá (VNĐ)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.attach_money),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập giá';
                              }
                              if (double.tryParse(value) == null ||
                                  double.parse(value) <= 0) {
                                return 'Giá phải lớn hơn 0';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildAnimatedFormField(
                          delay: 300,
                          child: TextFormField(
                            controller: _stockController,
                            decoration: InputDecoration(
                              labelText: 'Tồn kho',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.inventory),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập số lượng tồn kho';
                              }
                              if (int.tryParse(value) == null ||
                                  int.parse(value) < 0) {
                                return 'Số lượng tồn kho không hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  _buildAnimatedFormField(
                    delay: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ảnh sản phẩm',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 8),
                        ScaleTransition(
                          scale: _imageAnimation,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      _selectedImage != null ||
                                              widget.product?.imageUrl != null
                                          ? Colors.blue
                                          : Colors.grey.shade300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child:
                                    _selectedImage != null
                                        ? Stack(
                                          children: [
                                            Image.file(
                                              _selectedImage!,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.3,
                                                ),
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.camera_alt,
                                                      size: 40,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      'Nhấn để thay đổi ảnh',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                        : widget.product?.imageUrl != null
                                        ? Stack(
                                          children: [
                                            Image.network(
                                              widget.product!.imageUrl!,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value:
                                                        loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.grey.shade200,
                                                          Colors.grey.shade400,
                                                        ],
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      size: 50,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.3,
                                                ),
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.camera_alt,
                                                      size: 40,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      'Nhấn để thay đổi ảnh',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                        : Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.blue.shade100,
                                                Colors.blue.shade300,
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.add_photo_alternate,
                                                  size: 50,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Chọn ảnh sản phẩm',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'Nhấn để chọn ảnh',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  _buildAnimatedFormField(
                    delay: 500,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: AnimatedBuilder(
                        animation: _submitAnimationController,
                        builder: (context, child) {
                          return ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: _isSubmitting ? 0 : 8,
                            ),
                            child:
                                _isSubmitting
                                    ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Đang xử lý...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          widget.product == null
                                              ? Icons.add
                                              : Icons.update,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          widget.product == null
                                              ? 'Tạo sản phẩm'
                                              : 'Cập nhật sản phẩm',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
