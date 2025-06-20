import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/product_provider.dart';

class FilterChips extends StatefulWidget {
  const FilterChips({Key? key}) : super(key: key);

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.searchQuery.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip(
                'all',
                'Tất cả',
                Icons.widgets,
                provider.products.length,
              ),
              _buildFilterChip(
                'in_stock',
                'Còn hàng',
                Icons.check_circle,
                provider.products.where((p) => p.stock > 0).length,
              ),
              _buildFilterChip(
                'out_of_stock',
                'Hết hàng',
                Icons.remove_circle,
                provider.products.where((p) => p.stock == 0).length,
              ),
              _buildFilterChip(
                'low_stock',
                'Sắp hết',
                Icons.warning,
                provider.products
                    .where((p) => p.stock > 0 && p.stock <= 5)
                    .length,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String value,
    String label,
    IconData icon,
    int count,
  ) {
    final isSelected = _selectedFilter == value;

    return Container(
      margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: FilterChip(
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? value : 'all';
          });
          _applyFilter(value);
        },
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(label),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.white.withOpacity(0.3)
                          : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
        ),
      ),
    );
  }

  void _applyFilter(String filter) {
    final provider = context.read<ProductProvider>();
    // Implement filtering logic here if needed
    // For now, we'll just update the selected filter
  }
}
