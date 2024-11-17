import 'package:emma/models/task.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';

/// Flutter code sample for [SearchBar].

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreen();
}

class _SearchScreen extends State<SearchScreen> {
  bool isDark = false;
  List<Task> tasks = [];
  List<Task> searchedTasks = [];

  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    List<Task> res = await Task.findAll();
    setState(() {
      tasks = res;
    });
  }

  List<Task> queryTasks(String query, List<Task> resultTasks) {
    resultTasks.retainWhere(
        (task) => task.name.split(' ').any((word) => word.startsWith(query)));
    return resultTasks;
  }

  @override
  Widget build(BuildContext context) {
    // final ThemeData themeData = ThemeData(
    //     useMaterial3: true,
    //     brightness: isDark ? Brightness.dark : Brightness.light);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Search Bar')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              controller: controller,
              padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0)),
              onTap: () {
                // controller.openView();
              },
              onChanged: (val) {
                setState(() {
                  searchedTasks = queryTasks(controller.text, List.from(tasks));
                  print(controller.text);
                });
                controller.openView();
              },
              leading: const Icon(Icons.search),
              trailing: <Widget>[
                // Tooltip(
                //   message: 'Change brightness mode',
                //   child: IconButton(
                //     isSelected: isDark,
                //     onPressed: () {
                //       setState(() {
                //         isDark = !isDark;
                //       });
                //     },
                //     icon: const Icon(Icons.wb_sunny_outlined),
                //     selectedIcon: const Icon(Icons.brightness_2_outlined),
                //   ),
                // )
              ],
            );
          }, suggestionsBuilder:
                  (BuildContext context, SearchController controller) async {
            return List<ListTile>.generate(searchedTasks.length, (int index) {
              final task = searchedTasks[index];
              return ListTile(
                title: Text(task.name),
                onTap: () {
                  setState(() {
                    controller.closeView(task.name);
                  });
                },
              );
            });
          }),
        ),
      ),
    );
  }
}
