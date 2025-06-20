class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập tên sản phẩm';
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mô tả';
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập giá';
    if (double.tryParse(value) == null || double.parse(value) <= 0)
      return 'Giá phải lớn hơn 0';
    return null;
  }

  static String? validateStock(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập số lượng tồn kho';
    if (int.tryParse(value) == null || int.parse(value) < 0)
      return 'Số lượng tồn kho không hợp lệ';
    return null;
  }
}
