import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(HeartbeatApp());
}

class HeartbeatApp extends StatefulWidget {
  @override
  _HeartbeatAppState createState() => _HeartbeatAppState();
}

class _HeartbeatAppState extends State<HeartbeatApp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _timerSeconds = 10;
  Timer? _timer;
  bool _showMessage = false;
  int _counter = 0;
  List<int> _history = [];
  int _customIncrement = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.3).animate(_controller);
  }

  void startTimer() {
    setState(() {
      _timerSeconds = 10;
      _showMessage = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          timer.cancel();
          _showMessage = true;
        }
      });
    });
  }

  void _incrementCounter() {
    setState(() {
      if (_counter + _customIncrement <= 100) {
        _history.add(_counter);
        _counter += _customIncrement;
      }
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _history.add(_counter);
        _counter -= _customIncrement;
      }
    });
  }

  void _resetCounter() {
    setState(() {
      _history.add(_counter);
      _counter = 0;
    });
  }

  void _undo() {
    setState(() {
      if (_history.isNotEmpty) {
        _counter = _history.removeLast();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Valentine's Heartbeat & Counter"),
          backgroundColor: Colors.redAccent,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Lottie.asset('assets/heart_animation.json', fit: BoxFit.cover),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _animation,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 100,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "$_timerSeconds sec",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: startTimer,
                    child: Text("Start Heartbeat"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Counter: $_counter',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _counter == 0 ? Colors.red : _counter > 50 ? Colors.green : Colors.black),
                  ),
                  Slider(
                    min: 0,
                    max: 100,
                    value: _counter.toDouble(),
                    onChanged: (double value) {
                      setState(() {
                        _counter = value.toInt();
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(onPressed: _incrementCounter, child: Text("+$_customIncrement")),
                      SizedBox(width: 10),
                      ElevatedButton(onPressed: _decrementCounter, child: Text("-$_customIncrement")),
                      SizedBox(width: 10),
                      ElevatedButton(onPressed: _resetCounter, child: Text("Reset")),
                      SizedBox(width: 10),
                      ElevatedButton(onPressed: _undo, child: Text("Undo")),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(labelText: "Set Custom Increment"),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _customIncrement = int.tryParse(value) ?? 1;
                        });
                      },
                    ),
                  ),
                  if (_showMessage)
                    AnimatedOpacity(
                      opacity: _showMessage ? 1.0 : 0.0,
                      duration: Duration(seconds: 2),
                      child: Text(
                        "Happy Valentine's Day! ❤️",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
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
