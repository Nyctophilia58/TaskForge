import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/project.dart';
import '../../../shared/models/simple_user.dart';
import '../../../shared/models/task.dart';
import '../../../shared/models/task_create.dart';

class BuyerService {
  final Dio _dio = ApiClient().dio;

  Future<List<Project>> getMyProjects() async {
    final response = await _dio.get('/projects');
    return (response.data as List).map((json) => Project.fromJson(json)).toList();
  }

  Future<Project> createProject(Project project) async {
    final dataToSend = project.toJson();
    try {
      final response = await _dio.post('/projects/', data: dataToSend);
      if (response.data is String) {
        throw Exception('Server returned string instead of JSON: ${response.data}');
      }
      return Project.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Create Project Error: $e');
      rethrow;
    }
  }

  Future<List<SimpleUser>> getDevelopers() async {
    final response = await _dio.get('/users/developers');

    if (response.data is! List) {
      throw Exception('Expected list of developers, got ${response.data.runtimeType}');
    }

    return (response.data as List)
        .map((json) => SimpleUser.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Future<List<Task>> getTasksForProject(int projectId) async {
  //   // Use the buyer task list endpoint — it returns all tasks for the buyer's projects
  //   final response = await _dio.get('/tasks?project_id=$projectId'); // ← NO query param
  //   final List<dynamic> data = response.data;
  //
  //   // Filter on frontend by projectId
  //   return data
  //       .map((json) => Task.fromJson(json as Map<String, dynamic>))
  //       .where((task) => task.projectId == projectId)
  //       .toList();
  // }

  Future<List<Task>> getTasksForProject(int projectId) async {
    final response = await _dio.get('/tasks?project_id=$projectId');

    final data = response.data;

    if (data is List) {
      return (data).map((json) => Task.fromJson(json)).where((task) => task.projectId == projectId).toList();
    } else {
      throw Exception('Unexpected response format');
    }
  }

  Future<void> deleteProject(int projectId) async {
    await _dio.delete('/projects/$projectId');
  }

  Future<Project> updateProject(int projectId, Project project) async {
    final response = await _dio.put('/projects/$projectId', data: project.toJson());
    return Project.fromJson(response.data);
  }

  Future<void> deleteTask(int taskId) async {
    await _dio.delete('/tasks/$taskId');
  }

  Future<Task> updateTask(int taskId, TaskCreate task) async {
    final response = await _dio.put('/tasks/$taskId', data: task.toJson());
    return Task.fromJson(response.data);
  }

  Future<void> createTask(TaskCreate task) async {
    await _dio.post('/tasks/', data: task.toJson());
  }

  Future<void> payForTask(int taskId, double amount) async {
    final response = await _dio.post('/payments/', data: {'task_id': taskId, 'amount': amount});
  }

  Future<void> downloadZip(String zipPath, String filename) async {
    try {
      // Get public Downloads directory
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final savePath = '/storage/emulated/0/Download/$filename';

      await _dio.download(zipPath, savePath);

      await OpenFile.open(savePath);
    } catch (e) {
      print('Download error: $e');
      rethrow;
    }
  }
}