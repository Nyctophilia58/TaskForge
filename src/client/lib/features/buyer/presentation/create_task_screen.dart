import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/buyer_providers.dart';
import '../../../shared/models/project.dart';
import '../../../shared/models/task_create.dart';
import '../../../shared/models/simple_user.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  final Project project;
  const CreateTaskScreen({super.key, required this.project});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _rateController = TextEditingController();
  SimpleUser? _selectedDev;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final developersAsync = ref.watch(developersProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Create New Task'),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // White Card for Form
                Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Task for "${widget.project.title}"',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Title
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Task Title',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: theme.primaryColor, width: 2),
                              ),
                            ),
                            validator: (v) => v?.trim().isEmpty ?? true ? 'Title is required' : null,
                          ),
                          const SizedBox(height: 20),

                          // Description
                          TextFormField(
                            controller: _descController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: theme.primaryColor, width: 2),
                              ),
                            ),
                            validator: (v) => v?.trim().isEmpty ?? true ? 'Description is required' : null,
                          ),
                          const SizedBox(height: 20),

                          // Hourly Rate
                          TextFormField(
                            controller: _rateController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Hourly Rate (\$)',
                              prefixIcon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: theme.primaryColor, width: 2),
                              ),
                            ),
                            validator: (v) {
                              if (v?.isEmpty ?? true) return 'Rate is required';
                              final rate = double.tryParse(v!);
                              if (rate == null || rate <= 0) return 'Enter a valid positive number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Developer Dropdown
                          developersAsync.when(
                            data: (devs) {
                              if (devs.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'No developers available yet',
                                    style: TextStyle(color: Colors.redAccent, fontSize: 16),
                                  ),
                                );
                              }
                              return DropdownButtonFormField2<SimpleUser>(
                                value: _selectedDev,
                                decoration: InputDecoration(
                                  labelText: 'Assign to Developer',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                                  ),
                                ),
                                hint: const Text('Select a developer'),
                                items: devs.map((dev) {
                                  return DropdownMenuItem<SimpleUser>(
                                    value: dev,
                                    child: Text(dev.email),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedDev = val),
                                validator: (_) => _selectedDev == null ? 'Please select a developer' : null,
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 300,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white,
                                  ),
                                  offset: const Offset(0, -8),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: MaterialStateProperty.all(6),
                                    thumbVisibility: MaterialStateProperty.all(true),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 50,
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(Icons.arrow_drop_down),
                                  iconSize: 30,
                                ),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
                          ),

                          const SizedBox(height: 40),

                          // Create Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _createTask,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _loading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                'Create Task',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate() || _selectedDev == null) return;

    setState(() => _loading = true);

    try {
      final taskCreate = TaskCreate(
        projectId: widget.project.id,
        developerId: _selectedDev!.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        hourlyRate: double.parse(_rateController.text),
      );

      await ref.read(buyerServiceProvider).createTask(taskCreate);
      await ref.refresh(projectTasksProvider(widget.project.id).future);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task created!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _rateController.dispose();
    super.dispose();
  }
}