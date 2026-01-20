import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/admin_service.dart';
import '../../../../shared/models/admin_stats.dart';

final adminServiceProvider = Provider((ref) => AdminService());

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  return await ref.read(adminServiceProvider).getStats();
});