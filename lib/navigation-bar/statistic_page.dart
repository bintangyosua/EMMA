import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:emma/models/task.dart';

class StatisticPage extends StatefulWidget {
  @override
  _StatisticPageState createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  int urgentImportantCount = 0;
  int notUrgentImportantCount = 0;
  int urgentNotImportantCount = 0;
  int notUrgentNotImportantCount = 0;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserTaskCounts();
  }

  Future<void> _fetchUserTaskCounts() async {
    try {
      // Use the Task model's method to fetch tasks by category
      List<Task> urgentImportantTasks =
          await Task.findTasksByCategory('uw0sLWpsSWYFPfeTbijO');
      List<Task> notUrgentImportantTasks =
          await Task.findTasksByCategory('Pnkb6VLOhryAjrwCOyes');
      List<Task> urgentNotImportantTasks =
          await Task.findTasksByCategory('cl0BxRTOXKkS2DmO0DC8');
      List<Task> notUrgentNotImportantTasks =
          await Task.findTasksByCategory('qUPKuIqJioKvZO8qYD3L');

      setState(() {
        // Set the counts based on the length of each task list
        urgentImportantCount = urgentImportantTasks.length;
        notUrgentImportantCount = notUrgentImportantTasks.length;
        urgentNotImportantCount = urgentNotImportantTasks.length;
        notUrgentNotImportantCount = notUrgentNotImportantTasks.length;

        isLoading = false;
      });

      // Debugging prints
      // print('Urgent Important Tasks: $urgentImportantCount');
      // print('Not Urgent Important Tasks: $notUrgentImportantCount');
      // print('Urgent Not Important Tasks: $urgentNotImportantCount');
      // print('Not Urgent Not Important Tasks: $notUrgentNotImportantCount');
    } catch (e) {
      print('Error fetching task counts: $e');
      setState(() {
        errorMessage = 'Error fetching tasks: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red];
    final totalTasks = urgentImportantCount +
        notUrgentImportantCount +
        urgentNotImportantCount +
        notUrgentNotImportantCount;

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
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
                'Statistics',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // If there's an error, show error message
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 36,
                width: 36,
              ),
              const SizedBox(width: 12),
              const Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: Text(
            errorMessage!,
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 36,
              width: 36,
            ),
            const SizedBox(width: 12),
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your Task Distribution',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (totalTasks > 0)
              SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: colors[0],
                        value: (urgentImportantCount / totalTasks) * 100,
                        title:
                            '${(urgentImportantCount / totalTasks * 100).toStringAsFixed(1)}%',
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        color: colors[1],
                        value: (notUrgentImportantCount / totalTasks) * 100,
                        title:
                            '${(notUrgentImportantCount / totalTasks * 100).toStringAsFixed(1)}%',
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        color: colors[2],
                        value: (urgentNotImportantCount / totalTasks) * 100,
                        title:
                            '${(urgentNotImportantCount / totalTasks * 100).toStringAsFixed(1)}%',
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        color: colors[3],
                        value: (notUrgentNotImportantCount / totalTasks) * 100,
                        title:
                            '${(notUrgentNotImportantCount / totalTasks * 100).toStringAsFixed(1)}%',
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    sectionsSpace: 4,
                    centerSpaceRadius: 50,
                  ),
                ),
              ),
            if (totalTasks == 0)
              const Text(
                'No tasks available to display statistics.',
                style: TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 20),
            // Legend
            Column(
              children: [
                _buildLegend('Do Now', colors[0], urgentImportantCount),
                _buildLegend('Decide', colors[1], notUrgentImportantCount),
                _buildLegend('Delegate', colors[2], urgentNotImportantCount),
                _buildLegend('Postpone', colors[3], notUrgentNotImportantCount),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String title, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            '$count Tasks',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
