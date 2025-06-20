import 'package:flutter/foundation.dart';
import 'package:product_management_app/data/models/product_model.dart';
import 'package:product_management_app/presentation/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;

  List<Product> _products = [];
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';
  String? _sortBy;
  String? _sortOrder;
  bool? _inStock;
  int _page = 1;
  int _limit = 20;

  ProductProvider({ProductRepository? repository})
    : _repository = repository ?? ProductRepository();

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadProducts({
    String? search,
    String? sortBy,
    String? sortOrder,
    bool? inStock,
    int? page,
    int? limit,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    final response = await _repository.getProducts(
      search: search ?? _searchQuery,
      sortBy: sortBy ?? _sortBy,
      sortOrder: sortOrder ?? _sortOrder,
      inStock: inStock ?? _inStock,
      page: page ?? _page,
      limit: limit ?? _limit,
    );

    if (response.success && response.data != null) {
      _products = response.data!;
      _searchQuery = search ?? _searchQuery;
      _sortBy = sortBy ?? _sortBy;
      _sortOrder = sortOrder ?? _sortOrder;
      _inStock = inStock ?? _inStock;
      _page = page ?? _page;
      _limit = limit ?? _limit;
    } else {
      _error = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createProduct(CreateProductRequest request) async {
    final response = await _repository.createProduct(request);
    if (response.success && response.data != null) {
      _products.add(response.data!);
      notifyListeners();
      return true;
    }
    _error = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> updateProduct(int id, CreateProductRequest request) async {
    final response = await _repository.updateProduct(id, request);
    if (response.success && response.data != null) {
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = response.data!;
        notifyListeners();
      }
      return true;
    }
    _error = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteProduct(int id) async {
    final response = await _repository.deleteProduct(id);
    if (response.success) {
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    }
    _error = response.message;
    notifyListeners();
    return false;
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    loadProducts(search: query);
  }

  void updateSort(String? sortBy, String? sortOrder) {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    loadProducts(sortBy: sortBy, sortOrder: sortOrder);
  }

  void updateInStockFilter(bool? inStock) {
    _inStock = inStock;
    loadProducts(inStock: inStock);
  }

  void resetFilters() {
    _searchQuery = '';
    _sortBy = null;
    _sortOrder = null;
    _inStock = null;
    loadProducts();
  }
}
