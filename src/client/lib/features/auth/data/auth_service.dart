import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/user.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'username': email,
      'password': password,
    }, options: Options(contentType: Headers.formUrlEncodedContentType));

    final token = response.data['access_token'];
    await ApiClient().saveToken(token);

    // Fetch user info
    final userResponse = await _dio.get('/users/me');
    return User.fromJson(userResponse.data);
  }

  Future<User> register({
    required String email,
    required String password,
    required String role,
  }) async {
    await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'role': role,
    });

    // Auto login after register
    return await login(email: email, password: password);
  }

  Future<User> getCurrentUser() async {
    final response = await _dio.get('/users/me');
    return User.fromJson(response.data);
  }
}