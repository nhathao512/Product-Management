import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      stock: json['stock'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
    };
  }
}

class CreateProductRequest {
  final String name;
  final String description;
  final double price;
  final int stock;
  final File? image;

  CreateProductRequest({
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.image,
  });

  Future<Map<String, dynamic>> toJson() async {
    final map = <String, dynamic>{
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
    };

    if (image != null) {
      // Lấy MIME type từ file
      String? mimeType = lookupMimeType(image!.path);

      // Fallback nếu không detect được MIME type
      if (mimeType == null) {
        final extension = image!.path.toLowerCase();
        if (extension.endsWith('.jpg') || extension.endsWith('.jpeg')) {
          mimeType = 'image/jpeg';
        } else if (extension.endsWith('.png')) {
          mimeType = 'image/png';
        } else if (extension.endsWith('.gif')) {
          mimeType = 'image/gif';
        } else if (extension.endsWith('.webp')) {
          mimeType = 'image/webp';
        } else {
          mimeType = 'image/jpeg'; // Default fallback
        }
      }

      map['image'] = await MultipartFile.fromFile(
        image!.path,
        filename: image!.path.split('/').last,
        contentType: DioMediaType.parse(mimeType),
      );

      print('Image MIME type: $mimeType'); // Debug log
    }

    return map;
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'],
      data:
          fromJsonT != null && json['data'] != null
              ? fromJsonT(json['data'])
              : null,
      message: json['message'],
      errors: json['errors']?.cast<String>(),
    );
  }
}
