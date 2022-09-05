import 'package:dismissible_carousel_viewpager_example/demo/base_usage_page.dart';
import 'package:flutter/material.dart';

import 'demo/base_page.dart';
import 'demo/dismissal_usage_page.dart';

void main() {
  runApp(const MyApp());
}

final List<BasePage> _allPages = <BasePage>[
  const BaseUsagePage(),
  const DismissalUsagePage(),
];

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _DemoListPage(),
    );
  }
}

class _DemoListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView.separated(
          itemBuilder: (context, index) {
            BasePage page = _allPages[index];
            return ListTile(
              minVerticalPadding: 16,
              title: Text(page.title),
              subtitle: page.desc,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => page,
                    ));
              },
            );
          },
          itemCount: _allPages.length,
          separatorBuilder: (BuildContext context, int index) => ColoredBox(
              color: Colors.grey.withOpacity(0.2),
              child: const SizedBox(
                width: double.infinity,
                height: 1,
              )),
        ),
      );
}
