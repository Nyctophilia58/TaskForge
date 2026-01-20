import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/task.dart';
import '../data/developer_service.dart';

final developerServiceProvider = Provider((ref) => DeveloperService());

final myTasksProvider = FutureProvider<List<Task>>((ref) async {
  return ref.read(developerServiceProvider).getMyTasks();
});