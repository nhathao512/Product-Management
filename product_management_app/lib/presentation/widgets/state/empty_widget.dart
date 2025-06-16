import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class EmptyWidget extends StatelessWidget {
  final bool isSearchResult;
  final String? searchQuery;

  const EmptyWidget({Key? key, this.isSearchResult = false, this.searchQuery})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchResult ? Icons.search_off : Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            isSearchResult ? 'Không tìm thấy kết quả' : 'Chưa có sản phẩm nào',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearchResult
                ? 'Không có sản phẩm nào phù hợp với "${searchQuery ?? ''}"'
                : 'Nhấn nút + để thêm sản phẩm đầu tiên',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (isSearchResult) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Clear search action
                // This should be implemented in the parent widget or provider
                // context.read<ProductProvider>().clearSearch();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Xóa tìm kiếm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
