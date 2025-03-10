import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: FadingTextScreen(),
    );
  }
}

class FadingTextScreen extends StatefulWidget {
  @override
  _FadingTextScreenState createState() => _FadingTextScreenState();
}

class _FadingTextScreenState extends State<FadingTextScreen> {
  bool _isVisible = true;
  bool _isDarkMode = false;
  bool _showFrame = false;
  bool _isRotating = false;
  Color _textColor = Colors.black;
  double _rotationAngle = 0;

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _changeTextColor(Color color) {
    setState(() {
      _textColor = color;
    });
  }

  void _toggleFrame(bool value) {
    setState(() {
      _showFrame = value;
    });
  }

  void _toggleRotation() {
    setState(() {
      _isRotating = !_isRotating;
      if (_isRotating) {
        _rotateText();
      }
    });
  }

  void _rotateText() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_isRotating) {
        setState(() {
          _rotationAngle += pi / 18;
        });
        _rotateText();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fading & Rotating Text Animation'),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: _toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.color_lens),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Pick a Text Color'),
                  content: BlockPicker(
                    pickerColor: _textColor,
                    onColorChanged: _changeTextColor,
                  ),
                  actions: [
                    TextButton(
                      child: Text('Done'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _toggleVisibility,
              child: AnimatedOpacity(
                opacity: _isVisible ? 1.0 : 0.0,
                duration: Duration(seconds: 1),
                curve: Curves.easeInOut,
                child: Transform.rotate(
                  angle: _rotationAngle,
                  child: Container(
                    decoration: _showFrame
                        ? BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 3),
                            borderRadius: BorderRadius.circular(10),
                          )
                        : null,
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Hello, Flutter!',
                      style: TextStyle(fontSize: 24, color: _textColor),
                    ),
                  ),
                ),
              ),
            ),
            SwitchListTile(
              title: Text('Show Frame'),
              value: _showFrame,
              onChanged: _toggleFrame,
            ),
            ElevatedButton(
              onPressed: _toggleRotation,
              child: Text(_isRotating ? 'Stop Rotation' : 'Start Rotation'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleVisibility,
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
