import 'dart:io';
import 'package:flutter/material.dart';

class ProductImagePicker extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onImagePicked;
  final Animation<double> imageAnimation;

  const ProductImagePicker({
    Key? key,
    required this.selectedImage,
    required this.onImagePicked,
    required this.imageAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ảnh sản phẩm',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ScaleTransition(
          scale: imageAnimation,
          child: GestureDetector(
            onTap: onImagePicked,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      selectedImage != null
                          ? Colors.blue
                          : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child:
                    selectedImage != null
                        ? Stack(
                          children: [
                            Image.file(selectedImage!, fit: BoxFit.cover),
                            Container(
                              color: Colors.black.withOpacity(0.3),
                              child: const Center(
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                        : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade100,
                                Colors.blue.shade300,
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
