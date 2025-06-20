import 'package:flutter/material.dart';
import 'package:product_management_app/presentation/widgets/common/logout_dialog.dart';
import 'package:product_management_app/presentation/widgets/common/search_and_filter.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/product_provider.dart';
import '../widgets/product/product_card.dart';
import '../widgets/state/loading_widget.dart';
import '../widgets/state/empty_widget.dart';
import '../widgets/state/error_widget.dart' as custom_widgets;
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late AnimationController _listController;
  late Animation<double> _fabAnimation;
  late Animation<double> _listAnimation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  void _initializeAnimations() {
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _listController, curve: Curves.easeOut));
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      _fabController.forward();
      _listController.forward();
    });
  }

  void _onSearchChanged() {
    context.read<ProductProvider>().updateSearchQuery(_searchController.text);
  }

  Future<void> _onRefresh() async {
    await context.read<ProductProvider>().loadProducts();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _fabController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, Color(0xFF1976D2)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => showLogoutDialog(context),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withOpacity(0.1), Colors.white],
          ),
        ),
        child: Column(
          children: [
            SearchAndFilter(searchController: _searchController),
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const LoadingWidget();
                  }
                  if (provider.error.isNotEmpty) {
                    return custom_widgets.ErrorWidget(provider);
                  }
                  if (provider.products.isEmpty) {
                    return const EmptyWidget();
                  }
                  return FadeTransition(
                    opacity: _listAnimation,
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: AppColors.primary,
                      backgroundColor: Colors.white,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.products.length,
                        itemBuilder: (context, index) {
                          final product = provider.products[index];
                          return AnimatedContainer(
                            duration: Duration(
                              milliseconds: 300 + (index * 100),
                            ),
                            curve: Curves.easeOutBack,
                            child: ProductCard(product: product, index: index),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: _navigateToProductForm,
          icon: const Icon(Icons.add),
          label: const Text('Thêm sản phẩm'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          heroTag: "addProduct",
        ),
      ),
    );
  }

  void _navigateToProductForm() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const ProductFormScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
