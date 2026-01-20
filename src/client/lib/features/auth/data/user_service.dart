import '../../../core/network/api_client.dart';

class UserService {
  Future<Map<String, dynamic>> getMe() async {
    final response = await ApiClient().dio.get('/users/me');
    return response.data;
  }
}
