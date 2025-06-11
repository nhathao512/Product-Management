import 'dart:io';
import 'package:dio/dio.dart';

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
    final map = {
      'name': name,
      'description': description,
      'price': price,
      'stock':
          stock.toString(), // Đảm bảo stock là chuỗi để phù hợp với FormData
    };

    if (image != null) {
      map['image'] = await MultipartFile.fromFile(
        image!.path,
        filename: image!.path.split('/').last,
      );
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
