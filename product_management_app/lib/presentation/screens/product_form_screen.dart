import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:product_management_app/core/utils/image_utils.dart';
import 'package:provider/provider.dart';
import '../../data/models/product_model.dart';
import '../providers/product_provider.dart';
import '../widgets/product/product_form_fields.dart';
import '../widgets/product/product_image_picker.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Định dạng ảnh không hợp lệ. Vui lòng chọn JPG, PNG, GIF hoặc WEBP.',
            ),
          ),
        );
        return;
      }
      if (imageSize > maxSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ảnh quá lớn. Vui lòng chọn ảnh dưới 100MB.')),
        );
        return;
      }
      final mimeType = await getMimeType(imageFile);
      if (!mimeType.startsWith('image/')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tệp không phải là ảnh hợp lệ.')),
        );
        return;
      }
      setState(() => _selectedImage = imageFile);
      _imageAnimationController.forward();
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
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
      setState(() => _isSubmitting = false);
      _submitAnimationController.reset();
      Navigator.pop(context, {'success': success, 'message': message});
    }
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
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductFormFields(
                  nameController: _nameController,
                  descriptionController: _descriptionController,
                  priceController: _priceController,
                  stockController: _stockController,
                ),
                const SizedBox(height: 24),
                ProductImagePicker(
                  selectedImage: _selectedImage,
                  onImagePicked: _pickImage,
                  imageAnimation: _imageAnimation,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child:
                      _isSubmitting
                          ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Đang xử lý...'),
                            ],
                          )
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.product == null
                                    ? Icons.add
                                    : Icons.update,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.product == null
                                    ? 'Tạo sản phẩm'
                                    : 'Cập nhật sản phẩm',
                              ),
                            ],
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
