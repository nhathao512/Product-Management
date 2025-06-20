import 'package:product_management_app/data/models/api_response.dart';
import 'package:product_management_app/data/models/product_model.dart';
import 'package:product_management_app/data/services/api_service.dart';
import 'package:product_management_app/data/services/auth_service.dart';

class ProductRepository {
  final ApiService _apiService;
  final AuthService _authService;

  ProductRepository({ApiService? apiService, AuthService? authService})
    : _apiService = apiService ?? ApiService(),
      _authService = authService ?? AuthService();

  Future<ApiResponse<List<Product>>> getProducts({
    String? search,
    String? sortBy,
    String? sortOrder,
    bool? inStock,
    int? page,
    int? limit,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse<List<Product>>(
          success: false,
          message: 'Không có token xác thực',
          data: null,
        );
      }
      return await _apiService.getProducts(
        token: token,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
        inStock: inStock,
        page: page,
        limit: limit,
      );
    } catch (e) {
      return ApiResponse<List<Product>>(
        success: false,
        message: 'Lỗi mạng: ${e.toString()}',
        data: null,
      );
    }
  }

  Future<ApiResponse<Product>> createProduct(
    CreateProductRequest request,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse<Product>(
          success: false,
          message: 'Không có token xác thực',
          data: null,
        );
      }
      return await _apiService.createProduct(request, token: token);
    } catch (e) {
      return ApiResponse<Product>(
        success: false,
        message: 'Lỗi mạng: ${e.toString()}',
        data: null,
      );
    }
  }

  Future<ApiResponse<Product>> updateProduct(
    int id,
    CreateProductRequest request,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse<Product>(
          success: false,
          message: 'Không có token xác thực',
          data: null,
        );
      }
      return await _apiService.updateProduct(id, request, token: token);
    } catch (e) {
      return ApiResponse<Product>(
        success: false,
        message: 'Lỗi mạng: ${e.toString()}',
        data: null,
      );
    }
  }

  Future<ApiResponse<void>> deleteProduct(int id) async {
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse<void>(
          success: false,
          message: 'Không có token xác thực',
          data: null,
        );
      }
      return await _apiService.deleteProduct(id, token: token);
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Lỗi mạng: ${e.toString()}',
        data: null,
      );
    }
  }
}
