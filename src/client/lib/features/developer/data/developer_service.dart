import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/task.dart';

class DeveloperService {
  final Dio _dio = ApiClient().dio;

  Future<List<Task>> getMyTasks() async {
    final response = await _dio.get('/tasks/my');
    return (response.data as List).map((json) => Task.fromJson(json)).toList();
  }

  Future<void> startTask(int taskId) async {
    await _dio.patch('/tasks/$taskId/start');
  }

  Future<void> submitTask(int taskId, double hours, PlatformFile zipFile) async {
    if (zipFile.path == null) {
      throw Exception('File path is null — cannot upload');
    }

    final formData = FormData.fromMap({
      'hours': hours,
      'file': await MultipartFile.fromFile(
        zipFile.path!,
        filename: zipFile.name,
      ),
    });


    final response = await _dio.post(
      '/tasks/$taskId/submit',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: {
          Headers.contentLengthHeader: formData.length,
        },
      ),
    );
  }
}