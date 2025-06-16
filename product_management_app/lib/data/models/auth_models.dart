class LoginRequest {
  final String userName;
  final String password;

  LoginRequest({required this.userName, required this.password});

  Map<String, dynamic> toJson() {
    return {'userName': userName, 'password': password};
  }
}

class RegisterRequest {
  final String userName;
  final String email;
  final String password;

  RegisterRequest({
    required this.userName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'userName': userName, 'email': email, 'password': password};
  }
}

class AuthResponse {
  final String token;
  final DateTime expiry;

  AuthResponse({required this.token, required this.expiry});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      expiry: DateTime.parse(json['expiry']),
    );
  }
}

class User {
  final int id;
  final String userName;
  final String email;

  User({required this.id, required this.userName, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      userName: json['userName'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'userName': userName, 'email': email};
  }
}
