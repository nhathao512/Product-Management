import 'package:flutter/material.dart';
import 'package:product_management_app/core/constants/app_colors.dart';
import 'package:product_management_app/presentation/providers/product_provider.dart';
import 'package:provider/provider.dart';

class SearchAndFilter extends StatelessWidget {
  final TextEditingController searchController;

  const SearchAndFilter({Key? key, required this.searchController})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sản phẩm...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  context.read<ProductProvider>().resetFilters();
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildSortButton(context), _buildInStockFilter(context)],
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(BuildContext context) {
    return PopupMenuButton<Map<String, String>>(
      icon: const Icon(Icons.sort, color: AppColors.primary),
      onSelected: (value) {
        context.read<ProductProvider>().updateSort(
          value['sortBy'],
          value['sortOrder'],
        );
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: {'sortBy': 'name', 'sortOrder': 'asc'},
              child: Text('Sắp xếp theo tên (A-Z)'),
            ),
            const PopupMenuItem(
              value: {'sortBy': 'name', 'sortOrder': 'desc'},
              child: Text('Sắp xếp theo tên (Z-A)'),
            ),
            const PopupMenuItem(
              value: {'sortBy': 'price', 'sortOrder': 'asc'},
              child: Text('Sắp xếp theo giá (Thấp-Cao)'),
            ),
            const PopupMenuItem(
              value: {'sortBy': 'price', 'sortOrder': 'desc'},
              child: Text('Sắp xếp theo giá (Cao-Thấp)'),
            ),
            const PopupMenuItem(
              value: {'sortBy': 'createdAt', 'sortOrder': 'desc'},
              child: Text('Sắp xếp theo mới nhất'),
            ),
          ],
    );
  }

  Widget _buildInStockFilter(BuildContext context) {
    return PopupMenuButton<bool?>(
      icon: const Icon(Icons.filter_list, color: AppColors.primary),
      onSelected: (value) {
        context.read<ProductProvider>().updateInStockFilter(value);
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem(value: null, child: Text('Tất cả')),
            const PopupMenuItem(value: true, child: Text('Còn hàng')),
            const PopupMenuItem(value: false, child: Text('Hết hàng')),
          ],
    );
  }
}
