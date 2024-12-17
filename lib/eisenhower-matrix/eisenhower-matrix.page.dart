import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:emma/colors.dart';
import 'package:emma/eisenhower-matrix/task_create.dart';
import 'package:emma/eisenhower-matrix/task_page.dart';
import 'package:emma/models/task.dart';

class EisenhowerMatrixPage extends StatefulWidget {
  const EisenhowerMatrixPage({Key? key}) : super(key: key);

  @override
  _EisenhowerMatrixPageState createState() => _EisenhowerMatrixPageState();
}

class _EisenhowerMatrixPageState extends State<EisenhowerMatrixPage> {
  List<Task> _urgentImportantTasks = [];
  List<Task> _notUrgentImportantTasks = [];
  List<Task> _urgentNotImportantTasks = [];
  List<Task> _notUrgentNotImportantTasks = [];
  bool _isLoading = true;

  final GlobalKey<AnimatedListState> _urgentImportantKey = GlobalKey();
  final GlobalKey<AnimatedListState> _notUrgentImportantKey = GlobalKey();
  final GlobalKey<AnimatedListState> _urgentNotImportantKey = GlobalKey();
  final GlobalKey<AnimatedListState> _notUrgentNotImportantKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Widget _buildLoadingIndicator(Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            backgroundColor: color.withOpacity(0.5),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: const Duration(seconds: 2)),
          const SizedBox(height: 16),
          Text(
            'Loading Tasks...',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final urgentImportantTasks =
          await Task.findTasksByCategory('uw0sLWpsSWYFPfeTbijO');
      final notUrgentImportantTasks =
          await Task.findTasksByCategory('Pnkb6VLOhryAjrwCOyes');
      final urgentNotImportantTasks =
          await Task.findTasksByCategory('cl0BxRTOXKkS2DmO0DC8');
      final notUrgentNotImportantTasks =
          await Task.findTasksByCategory('qUPKuIqJioKvZO8qYD3L');

      print(urgentImportantTasks);

      setState(() {
        _urgentImportantTasks = urgentImportantTasks;
        _notUrgentImportantTasks = notUrgentImportantTasks;
        _urgentNotImportantTasks = urgentNotImportantTasks;
        _notUrgentNotImportantTasks = notUrgentNotImportantTasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tasks: $e')),
      );
    }
  }

  void _toggleTaskCompletion(
      List<Task> tasks, int index, GlobalKey<AnimatedListState> listKey) async {
    Task task = tasks[index];
    bool currentStatus = task.is_done;

    await task.checkDone(task.uid!);

    setState(() {
      if (!currentStatus) {
        // Remove the task from current list with animation
        final removedTask = tasks.removeAt(index);
        listKey.currentState?.removeItem(
            index,
            (context, animation) => _buildAnimatedTaskItem(
                removedTask, animation, tasks.first.category_id),
            duration: const Duration(milliseconds: 300));

        // Append to the end of the list
        tasks.add(removedTask);
        listKey.currentState?.insertItem(tasks.length - 1);
      }
    });
  }

  Widget _buildAnimatedTaskItem(
      Task task, Animation<double> animation, String categoryId) {
    return SizeTransition(
      sizeFactor: animation,
      child: _buildTaskItem(task, () {
        task.checkDone(task.uid!);
      }, categoryId),
    );
  }

  Widget _buildTaskItem(Task task, VoidCallback onTap, String categoryId) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailPage(
              task: task,
              onTaskChanged: () => _loadTasks(),
            ),
          ),
        );
      },
      title: Text(
        task.name.length > 20 ? '${task.name.substring(0, 20)}...' : task.name,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
          decoration: task.is_done ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: Checkbox(
        value: task.is_done,
        onChanged: (bool? value) {
          if (categoryId == 'uw0sLWpsSWYFPfeTbijO') {
            _toggleTaskCompletion(_urgentImportantTasks,
                _urgentImportantTasks.indexOf(task), _urgentImportantKey);
          } else if (categoryId == 'Pnkb6VLOhryAjrwCOyes') {
            _toggleTaskCompletion(_notUrgentImportantTasks,
                _notUrgentImportantTasks.indexOf(task), _notUrgentImportantKey);
          } else if (categoryId == 'cl0BxRTOXKkS2DmO0DC8') {
            _toggleTaskCompletion(_urgentNotImportantTasks,
                _urgentNotImportantTasks.indexOf(task), _urgentNotImportantKey);
          } else if (categoryId == 'qUPKuIqJioKvZO8qYD3L') {
            _toggleTaskCompletion(
                _notUrgentNotImportantTasks,
                _notUrgentNotImportantTasks.indexOf(task),
                _notUrgentNotImportantKey);
          }
        },
        activeColor: Colors.white,
        checkColor: Colors.green,
      ),
      dense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    );
  }

  Widget _buildTaskContent(List<Task> tasks, String title, String subtitle,
      String categoryId, GlobalKey<AnimatedListState> listKey) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: AnimatedList(
            key: listKey,
            initialItemCount: tasks.length,
            itemBuilder: (context, index, animation) {
              return _buildTaskItem(tasks[index], () {}, categoryId);
            },
          ),
        ),
      ],
    );
  }

  Widget buildTaskList(List<Task> tasks, String title, String subtitle,
      Color color, String categoryId, GlobalKey<AnimatedListState> listKey) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: _isLoading
                ? _buildLoadingIndicator(color)
                : tasks.isEmpty
                    ? _buildEmptyState(title, subtitle)
                    : _buildTaskContent(
                        tasks, title, subtitle, categoryId, listKey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 36,
              width: 36,
            ),
            const SizedBox(width: 12),
            const Text(
              'EMMA',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.color1,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return TaskCreatePage(onTaskChanged: () => _loadTasks());
            },
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      body: Container(
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: buildTaskList(
                      _urgentImportantTasks,
                      'Do Now',
                      'Do it Now.',
                      AppColors.color1,
                      'uw0sLWpsSWYFPfeTbijO',
                      _urgentImportantKey,
                    ),
                  ),
                  Expanded(
                    child: buildTaskList(
                      _urgentNotImportantTasks,
                      'Delegate',
                      'Who can do it for you?',
                      AppColors.color2,
                      'cl0BxRTOXKkS2DmO0DC8',
                      _urgentNotImportantKey,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: buildTaskList(
                      _notUrgentImportantTasks,
                      'Decide',
                      'Schedule a time',
                      AppColors.color3,
                      'Pnkb6VLOhryAjrwCOyes',
                      _notUrgentImportantKey,
                    ),
                  ),
                  Expanded(
                    child: buildTaskList(
                      _notUrgentNotImportantTasks,
                      'Postpone',
                      'Eliminate it',
                      AppColors.color4,
                      'qUPKuIqJioKvZO8qYD3L',
                      _notUrgentNotImportantKey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
