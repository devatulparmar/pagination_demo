import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:list_demo/model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _pageSize = 20;
  final PagingController<int, Users> _pagingController = PagingController(firstPageKey: 0);

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await Dio().get('https://api.slingacademy.com/v1/sample-data/users?offset=$pageKey&limit=$_pageSize');
      List u = newItems.data['users'] as List;
      List<Users> users = u.map((e) => Users.fromJson(e)).toList();
      final isLastPage = users.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(users);
      } else {
        final nextPageKey = pageKey + users.length;
        _pagingController.appendPage(users, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 150,
              width: 500,
              color: Colors.pink,
            ),
            PagedListView<int, Users>(
              pagingController: _pagingController,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              builderDelegate: PagedChildBuilderDelegate<Users>(
                firstPageProgressIndicatorBuilder: (_) => const Scaffold(
                  body: Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                newPageProgressIndicatorBuilder: (_) => const Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      color: Colors.green,
                    ),
                  ),
                ),
                itemBuilder: (context, item, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item.city.toString(),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
