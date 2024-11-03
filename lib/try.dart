import 'package:flutter/material.dart';

// Define a custom InheritedWidget to hold the counter value
class CounterInheritedWidget extends InheritedWidget {
  final int counter;
  @override
  final Widget child;

  const CounterInheritedWidget(
      {super.key, required this.counter, required this.child})
      : super(child: child);

  // This method allows child widgets to access the counter value
  static CounterInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CounterInheritedWidget>();
  }

  @override
  bool updateShouldNotify(covariant CounterInheritedWidget oldWidget) {
    // Notify children only when the counter value changes
    return oldWidget.counter != counter;
  }
}

// A StatefulWidget that uses the CounterInheritedWidget to share state
class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

  @override
  _CounterAppState createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CounterInheritedWidget(
      counter: _counter,
      child: Scaffold(
        appBar: AppBar(title: const Text('InheritedWidget Example')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('The counter value is:'),
              // Access the counter value from the InheritedWidget
              CounterValue(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// A widget that reads the counter value from the InheritedWidget
class CounterValue extends StatelessWidget {
  const CounterValue({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the counter value via CounterInheritedWidget.of
    final inheritedWidget = CounterInheritedWidget.of(context);
    final counter = inheritedWidget?.counter ?? 0;

    return Text(
      '$counter',
      style: const TextStyle(fontSize: 48),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: CounterApp(),
  ));
}
