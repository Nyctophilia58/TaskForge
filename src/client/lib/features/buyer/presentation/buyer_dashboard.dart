import 'package:client/features/buyer/presentation/project_detail_screen.dart';
import 'package:client/features/buyer/providers/buyer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // ← ADD THIS
import '../../../core/network/api_client.dart';
import '../../../shared/models/project.dart';
import 'create_project_screen.dart';
import 'edit_project_screen.dart';

class BuyerDashboard extends ConsumerWidget {
  const BuyerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(myProjectsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('My Projects'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              await ApiClient().clearToken();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          )
        ]
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
        ),
        label: const Text('New Project'),
        icon: const Icon(Icons.add),
        backgroundColor: theme.primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withOpacity(0.8),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => ref.refresh(myProjectsProvider.future),
            child: projectsAsync.when(
              data: (projects) => projects.isEmpty
                  ? Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 100, color: Colors.white.withOpacity(0.6)),
                      const SizedBox(height: 24),
                      const Text(
                        'No projects yet',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tap the + button to create your first project',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];

                  return Slidable(
                    // Swipe actions
                    endActionPane: ActionPane(
                      motion: const StretchMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            final updated = await Navigator.push<Project>(
                              context,
                              MaterialPageRoute(builder: (_) => EditProjectScreen(project: project)),
                            );
                            if (updated != null) {
                              await ref.read(buyerServiceProvider).updateProject(project.id, updated);
                              ref.invalidate(myProjectsProvider);
                            }
                          },
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
                          borderRadius: BorderRadius.circular(16),
                        ),
                        SlidableAction(
                          onPressed: (context) async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: const Text('Delete Project'),
                                content: Text('Delete "${project.title}" and all its tasks?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await ref.read(buyerServiceProvider).deleteProject(project.id);
                              ref.invalidate(myProjectsProvider);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Project deleted')),
                              );
                            }
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ],
                    ),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.folder, size: 36, color: theme.primaryColor),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      project.title,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      project.description,
                                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: Colors.white.withOpacity(0.8)),
                    const SizedBox(height: 16),
                    const Text('Error loading projects', style: TextStyle(fontSize: 18, color: Colors.white)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.refresh(myProjectsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}