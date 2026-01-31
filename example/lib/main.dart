import 'package:flutter/material.dart';
import 'package:fancy_page_indicator/fancy_page_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fancy Page Indicator Example',
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  late final PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fancy Page Indicator Example')),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller,
              children: List.generate(
                5,
                (index) => Container(
                  color: Colors.primaries[index % Colors.primaries.length],
                  child: Center(
                    child: Text(
                      'Page ${index + 1}',
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FancyPageIndicator(
              controller: controller,
              count: 5,
              enableLoupe: true,
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}
