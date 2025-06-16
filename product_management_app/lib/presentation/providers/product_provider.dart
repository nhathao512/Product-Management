import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';

  List<Product> get products =>
      _searchQuery.isEmpty ? _products : _filteredProducts;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        _error = 'Không có token xác thực';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.getProducts(token: token);
      if (response.success && response.data != null) {
        _products = response.data!;
        _filterProducts(); // Filter products after loading
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Lỗi mạng: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchProducts(String query) {
    _searchQuery = query.toLowerCase().trim();
    _filterProducts();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredProducts.clear();
    notifyListeners();
  }

  void _filterProducts() {
    if (_searchQuery.isEmpty) {
      _filteredProducts.clear();
    } else {
      _filteredProducts =
          _products.where((product) {
            return product.name.toLowerCase().contains(_searchQuery) ||
                product.description.toLowerCase().contains(_searchQuery) ||
                product.price.toString().contains(_searchQuery) ||
                product.stock.toString().contains(_searchQuery);
          }).toList();
    }
  }

  Future<bool> createProduct(CreateProductRequest request) async {
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        _error = 'Không có token xác thực';
        notifyListeners();
        return false;
      }
      final response = await _apiService.createProduct(request, token: token);
      if (response.success && response.data != null) {
        _products.add(response.data!);
        _filterProducts(); // Re-filter after adding
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } catch (e) {
      _error = 'Lỗi mạng: ${e.toString()}';
      return false;
    }
  }

  Future<bool> updateProduct(int id, CreateProductRequest request) async {
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        _error = 'Không có token xác thực';
        notifyListeners();
        return false;
      }
      final response = await _apiService.updateProduct(
        id,
        request,
        token: token,
      );
      if (response.success && response.data != null) {
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) {
          _products[index] = response.data!;
          _filterProducts(); // Re-filter after updating
          notifyListeners();
        }
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } catch (e) {
      _error = 'Lỗi mạng: ${e.toString()}';
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        _error = 'Không có token xác thực';
        notifyListeners();
        return false;
      }
      final response = await _apiService.deleteProduct(id, token: token);
      if (response.success) {
        _products.removeWhere((p) => p.id == id);
        _filterProducts(); // Re-filter after deleting
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } catch (e) {
      _error = 'Lỗi mạng: ${e.toString()}';
      return false;
    }
  }
}
