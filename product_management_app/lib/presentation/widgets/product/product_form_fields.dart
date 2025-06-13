import 'package:flutter/material.dart';
import 'package:product_management_app/core/utils/validators.dart' show Validators;

class ProductFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController stockController;

  const ProductFormFields({
    Key? key,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.stockController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Tên sản phẩm',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.shopping_bag),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: Validators.validateName,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'Mô tả',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.description),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          maxLines: 3,
          validator: Validators.validateDescription,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Giá (VNĐ)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.number,
                validator: Validators.validatePrice,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: stockController,
                decoration: InputDecoration(
                  labelText: 'Tồn kho',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.inventory),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.number,
                validator: Validators.validateStock,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
