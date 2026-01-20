import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/admin_stats.dart';

class AdminService {
  final Dio _dio = ApiClient().dio;

  Future<AdminStats> getStats() async {
    final response = await _dio.get('/admin/stats');
    return AdminStats.fromJson(response.data);
  }
}