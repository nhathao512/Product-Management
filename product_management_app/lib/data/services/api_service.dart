import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/api_response.dart';
import '../../core/constants/api_constants.dart';

class ApiService {
  late Dio _dio;

  static String get baseUrl {
    return kIsWeb
        ? ApiConstants.baseUrlLocal
        : (Platform.isAndroid
            ? ApiConstants.baseUrlEmulator
            : ApiConstants.baseUrlLocal);
  }

  ApiService() {
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

  Future<ApiResponse<List<Product>>> getProducts({String? token}) async {
    try {
      Dio newDio = _dio; // Tạo một instance mới để thêm token
      if (token != null && token.isNotEmpty) {
        newDio.options.headers['Authorization'] = 'Bearer $token';
      }
      final response = await newDio.get('/products');
      if (response.statusCode == 200) {
        return ApiResponse<List<Product>>.fromJson(
          response.data,
          (data) =>
              (data as List).map((item) => Product.fromJson(item)).toList(),
        );
      } else {
        return ApiResponse<List<Product>>(
          success: false,
          message: 'Lỗi máy chủ: Mã trạng thái ${response.statusCode}',
          data: null,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        return ApiResponse<List<Product>>(
          success: false,
          message: 'Lỗi mạng: Không thể kết nối đến máy chủ.',
          data: null,
        );
      }
      return ApiResponse<List<Product>>(
        success: false,
        message: 'Lỗi mạng: ${e.message}',
        data: null,
      );
    }
  }

  Future<ApiResponse<Product>> getProduct(int id, {String? token}) async {
    try {
      Dio newDio = _dio;
      if (token != null && token.isNotEmpty) {
        newDio.options.headers['Authorization'] = 'Bearer $token';
      }
      final response = await newDio.get('/products/$id');
      if (response.statusCode == 200) {
        return ApiResponse<Product>.fromJson(
          response.data,
          (data) => Product.fromJson(data),
        );
      } else {
        return ApiResponse<Product>(
          success: false,
          message: 'Lỗi máy chủ: Mã trạng thái ${response.statusCode}',
          data: null,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<Product>(
        success: false,
        message: 'Lỗi mạng: ${e.message}',
        data: null,
      );
    }
  }

  Future<ApiResponse<Product>> createProduct(
    CreateProductRequest request, {
    String? token,
  }) async {
    try {
      Dio newDio = _dio;
      if (token != null && token.isNotEmpty) {
        newDio.options.headers['Authorization'] = 'Bearer $token';
      }
      final data = await request.toJson();
      final formData = FormData.fromMap(data);
      final response = await newDio.post(
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
        return ApiResponse<Product>(
          success: false,
          message: 'Lỗi máy chủ: Mã trạng thái ${response.statusCode}',
          data: null,
        );
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return ApiResponse<Product>.fromJson(
          e.response!.data,
          (data) => Product.fromJson(data),
        );
      }
      return ApiResponse<Product>(
        success: false,
        message: 'Lỗi mạng: ${e.message}',
        data: null,
      );
    }
  }

  Future<ApiResponse<Product>> updateProduct(
    int id,
    CreateProductRequest request, {
    String? token,
  }) async {
    try {
      Dio newDio = _dio;
      if (token != null && token.isNotEmpty) {
        newDio.options.headers['Authorization'] = 'Bearer $token';
      }
      final data = await request.toJson();
      final formData = FormData.fromMap(data);
      final response = await newDio.put(
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
        return ApiResponse<Product>(
          success: false,
          message: 'Lỗi máy chủ: Mã trạng thái ${response.statusCode}',
          data: null,
        );
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return ApiResponse<Product>.fromJson(
          e.response!.data,
          (data) => Product.fromJson(data),
        );
      }
      return ApiResponse<Product>(
        success: false,
        message: 'Lỗi mạng: ${e.message}',
        data: null,
      );
    }
  }

  Future<ApiResponse<void>> deleteProduct(int id, {String? token}) async {
    try {
      Dio newDio = _dio;
      if (token != null && token.isNotEmpty) {
        newDio.options.headers['Authorization'] = 'Bearer $token';
      }
      final response = await newDio.delete('/products/$id');
      if (response.statusCode == 200) {
        return ApiResponse<void>.fromJson(response.data, null);
      } else {
        return ApiResponse<void>(
          success: false,
          message: 'Lỗi máy chủ: Mã trạng thái ${response.statusCode}',
          data: null,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Lỗi mạng: ${e.message}',
        data: null,
      );
    }
  }
}
