import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:product_management_app/services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({Key? key, this.product}) : super(key: key);

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  File? _selectedImage;

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
          const SnackBar(
            content: Text(
              'Định dạng ảnh không hợp lệ. Vui lòng chọn JPG, PNG, GIF hoặc WEBP.',
            ),
          ),
        );
        return;
      }

      if (imageSize > maxSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ảnh quá lớn. Vui lòng chọn ảnh dưới 100MB.'),
          ),
        );
        return;
      }

      final mimeType = await _getMimeType(imageFile);
      if (!mimeType.startsWith('image/')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tệp không phải là ảnh hợp lệ.')),
        );
        return;
      }

      print(
        'Selected image: ${imageFile.path}, size: ${imageSize / (1024 * 1024)} MB, extension: $extension',
      ); // Log debug

      setState(() {
        _selectedImage = imageFile;
      });
    }
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
      final request = CreateProductRequest(
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        image: _selectedImage,
      );

      final provider = Provider.of<ProductProvider>(context, listen: false);
      bool success;
      if (widget.product == null) {
        success = await provider.createProduct(request);
      } else {
        success = await provider.updateProduct(widget.product!.id, request);
      }

      if (success) {
        // Không cần gọi loadProducts() vì Provider đã tự động cập nhật
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product == null
                  ? 'Tạo sản phẩm thành công'
                  : 'Cập nhật sản phẩm thành công',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${provider.error}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Tạo sản phẩm' : 'Sửa sản phẩm'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên sản phẩm',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên sản phẩm';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mô tả';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Giá (VNĐ)',
                    border: OutlineInputBorder(),
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
                SizedBox(height: 16),
                TextFormField(
                  controller: _stockController,
                  decoration: InputDecoration(
                    labelText: 'Tồn kho',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số lượng tồn kho';
                    }
                    if (int.tryParse(value) == null || int.parse(value) < 0) {
                      return 'Số lượng tồn kho không hợp lệ';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Ảnh sản phẩm',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover)
                            : widget.product?.imageUrl != null
                            ? Image.network(
                              '${ApiService.baseUrl.replaceAll('/api', '')}${widget.product!.imageUrl}',
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      Icon(Icons.broken_image, size: 50),
                            )
                            : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  Text('Chọn ảnh'),
                                ],
                              ),
                            ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(widget.product == null ? 'Tạo' : 'Cập nhật'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
