import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:7116/api';
  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Future<ApiResponse<List<Product>>> getProducts() async {
    try {
      final response = await _dio.get('/products');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<Product>>.fromJson(
          response.data,
          (data) =>
              (data as List).map((item) => Product.fromJson(item)).toList(),
        );
        return apiResponse;
      } else {
        throw Exception('Lỗi máy chủ: Mã trạng thái ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Lỗi mạng: Không thể kết nối đến máy chủ tại $baseUrl. Vui lòng kiểm tra IP/cổng.',
        );
      }
      throw Exception('Lỗi mạng: ${e.message}');
    }
  }

  Future<ApiResponse<Product>> getProduct(int id) async {
    try {
      final response = await _dio.get('/products/$id');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Product>.fromJson(
          response.data,
          (data) => Product.fromJson(data),
        );
        return apiResponse;
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
      final response = await _dio.post('/products', data: request.toJson());

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse<Product>.fromJson(
          response.data,
          (data) => Product.fromJson(data),
        );
        return apiResponse;
      } else {
        throw Exception('Lỗi máy chủ: Mã trạng thái ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Lỗi mạng: ${e.message}');
    }
  }

  Future<ApiResponse<Product>> updateProduct(
    int id,
    CreateProductRequest request,
  ) async {
    try {
      final response = await _dio.put('/products/$id', data: request.toJson());

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Product>.fromJson(
          response.data,
          (data) => Product.fromJson(data),
        );
        return apiResponse;
      } else {
        throw Exception('Lỗi máy chủ: Mã trạng thái ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Lỗi mạng: ${e.message}');
    }
  }

  Future<ApiResponse<void>> deleteProduct(int id) async {
    try {
      final response = await _dio.delete('/products/$id');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<void>.fromJson(response.data, null);
        return apiResponse;
      } else {
        throw Exception('Lỗi máy chủ: Mã trạng thái ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Lỗi mạng: ${e.message}');
    }
  }
}
