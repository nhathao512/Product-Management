class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'],
      data:
          fromJsonT != null && json['data'] != null
              ? fromJsonT(json['data'])
              : null,
      message: json['message'],
      errors: json['errors']?.cast<String>(),
    );
  }
}
