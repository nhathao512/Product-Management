import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import '../models/api_response.dart';
import '../../core/constants/api_constants.dart';

class AuthService {
  late Dio _dio;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthService() {
    String baseUrl =
        kIsWeb
            ? ApiConstants.baseUrlLocal
            : (Platform.isAndroid
                ? ApiConstants.baseUrlEmulator
                : ApiConstants.baseUrlLocal);

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print('Sending token: Bearer $token'); // Debug token
          } else {
            print('No token available');
          }
          handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Xử lý token hết hạn (có thể thêm logout hoặc refresh token)
            print('Token expired or invalid');
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/auth/login', data: request.toJson());
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<AuthResponse>.fromJson(
          response.data,
          (data) => AuthResponse.fromJson(data),
        );
        if (apiResponse.success && apiResponse.data != null) {
          await saveToken(apiResponse.data!.token);
        }
        return apiResponse;
      } else {
        return ApiResponse<AuthResponse>(
          success: false,
          message: 'Lỗi máy chủ: Mã trạng thái ${response.statusCode}',
          data: null,
        );
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return ApiResponse<AuthResponse>.fromJson(
          e.response!.data,
          (data) => AuthResponse.fromJson(data),
        );
      }
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Lỗi mạng: ${e.message}',
        data: null,
      );
    }
  }

  Future<ApiResponse<User>> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: request.toJson(),
      );
      if (response.statusCode == 200) {
        return ApiResponse<User>.fromJson(
          response.data,
          (data) => User.fromJson(data),
        );
      } else {
        return ApiResponse<User>(
          success: false,
          message: 'Lỗi máy chủ: Mã trạng thái ${response.statusCode}',
          data: null,
        );
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return ApiResponse<User>.fromJson(
          e.response!.data,
          (data) => User.fromJson(data),
        );
      }
      return ApiResponse<User>(
        success: false,
        message: 'Lỗi mạng: ${e.message}',
        data: null,
      );
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toJson().toString());
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return User.fromJson(Map<String, dynamic>.from(jsonDecode(userString)));
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
