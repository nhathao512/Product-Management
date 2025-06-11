import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thêm import
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../services/api_service.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
    : super(key: key);

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text('Bạn có chắc muốn xóa sản phẩm "${product.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () async {
                  final provider = Provider.of<ProductProvider>(
                    context,
                    listen: false,
                  );
                  final success = await provider.deleteProduct(product.id);
                  Navigator.pop(context); // Đóng dialog
                  if (success) {
                    Navigator.pop(context); // Quay lại ProductListScreen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Xóa sản phẩm thành công')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${provider.error}')),
                    );
                  }
                },
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductFormScreen(product: product),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hiển thị ảnh sản phẩm
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    product.imageUrl != null
                        ? Image.network(
                          '${ApiService.baseUrl.replaceAll('/api', '')}${product.imageUrl}',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                              ),
                        )
                        : const Center(
                          child: Icon(
                            Icons.image,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
              ),
              const SizedBox(height: 16),
              // Tên sản phẩm
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Mô tả
              Text(product.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              // Giá
              Text(
                'Giá: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(product.price)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              // Tồn kho
              Text(
                'Tồn kho: ${product.stock}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              // Ngày tạo
              Text(
                'Ngày tạo: ${product.createdAt.toLocal().toString().split('.')[0]}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              // Ngày cập nhật
              Text(
                'Cập nhật lần cuối: ${product.updatedAt.toLocal().toString().split('.')[0]}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
