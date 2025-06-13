import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/api_response.dart';
import '../../core/constants/api_constants.dart';

class ApiService {
  late Dio _dio;

  // Thêm getter tĩnh để lấy baseUrl
  static String get baseUrl {
    return kIsWeb
        ? ApiConstants.baseUrlLocal
        : (Platform.isAndroid
            ? ApiConstants.baseUrlEmulator
            : ApiConstants.baseUrlLocal);
  }

  ApiService() {
    String baseUrl =
        kIsWeb
            ? ApiConstants.baseUrlLocal
            : (Platform.isAndroid
                ? ApiConstants.baseUrlEmulator
                : ApiConstants.baseUrlLocal);

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  Future<ApiResponse<List<Product>>> getProducts() async {
    try {
      final response = await _dio.get('/products');
      if (response.statusCode == 200) {
        return ApiResponse<List<Product>>.fromJson(
          response.data,
          (data) =>
              (data as List).map((item) => Product.fromJson(item)).toList(),
        );
      } else {
        throw Exception('Lỗi máy chủ: Mã trạng thái ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Lỗi mạng: Không thể kết nối đến máy chủ. Vui lòng kiểm tra IP/cổng.',
        );
      }
      throw Exception('Lỗi mạng: ${e.message}');
    }
  }

  Future<ApiResponse<Product>> getProduct(int id) async {
    try {
      final response = await _dio.get('/products/$id');
      if (response.statusCode == 200) {
        return ApiResponse<Product>.fromJson(
          response.data,
          (data) => Product.fromJson(data),
        );
      } else {
        throw Exception('Lỗi máy chủ: Mã trạng thái ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Lỗi mạng: ${e.message}');
    }
  }

  Future<ApiResponse<Product>> createProduct(
    CreateProductRequest request,
  ) async {
    try {
      final data = await request.toJson();
      final formData = FormData.fromMap(data);
      print('Sending FormData: ${formData.fields}');
      if (data.containsKey('image')) {
        final imageFile = data['image'] as MultipartFile;
        print('Image filename: ${imageFile.filename}');
        print('Image contentType: ${imageFile.contentType}');
        print('Image length: ${imageFile.length}');
      }
      final response = await _dio.post(
        '/products',
        data: formData,
        options: Options(headers: {}),
      );
      if (response.statusCode == 201) {
        return ApiResponse<Product>.fromJson(
          response.data,
          (data) => Product.fromJson(data),
        );
      } else {
        throw Exception('Lỗi máy chủ: Mã trạng thái ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiResponse<Product>.fromJson(
          e.response!.data,
          (data) => Product.fromJson(data),
        );
        print('Server error: ${errorResponse.message}');
        throw Exception(
          'Lỗi: ${errorResponse.message}${errorResponse.errors != null ? ' - ${errorResponse.errors!.join(', ')}' : ''}',
        );
      }
      throw Exception('Lỗi mạng: ${e.message}');
    }
  }

  Future<ApiResponse<Product>> updateProduct(
    int id,
    CreateProductRequest request,
  ) async {
    try {
      final data = await request.toJson();
      final formData = FormData.fromMap(data);
      if (data.containsKey('image')) {
        final imageFile = data['image'] as MultipartFile;
        print('Update - Image filename: ${imageFile.filename}');
        print('Update - Image contentType: ${imageFile.contentType}');
        print('Update - Image length: ${imageFile.length}');
      }
      final response = await _dio.put(
        '/products/$id',
        data: formData,
        options: Options(headers: {}),
      );
      if (response.statusCode == 200) {
        return ApiResponse<Product>.fromJson(
          response.data,
          (data) => Product.fromJson(data),
        );
      } else {
        throw Exception('Lỗi máy chủ: Mã trạng thái ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiResponse<Product>.fromJson(
          e.response!.data,
          (data) => Product.fromJson(data),
        );
        throw Exception(
          'Lỗi: ${errorResponse.message}${errorResponse.errors != null ? ' - ${errorResponse.errors!.join(', ')}' : ''}',
        );
      }
      throw Exception('Lỗi mạng: ${e.message}');
    }
  }

  Future<ApiResponse<void>> deleteProduct(int id) async {
    try {
      final response = await _dio.delete('/products/$id');
      if (response.statusCode == 200) {
        return ApiResponse<void>.fromJson(response.data, null);
      } else {
        throw Exception('Lỗi máy chủ: Mã trạng thái ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Lỗi mạng: ${e.message}');
    }
  }
}
