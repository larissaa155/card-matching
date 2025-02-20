import 'package:flutter/material.dart';

void main() {
  runApp(DigitalPetApp());
}

class DigitalPetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PetHome(),
    );
  }
}

class PetHome extends StatefulWidget {
  @override
  _PetHomeState createState() => _PetHomeState();
}

class _PetHomeState extends State<PetHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int happiness = 50;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  void increaseHappiness() {
    setState(() {
      if (happiness < 100) happiness += 10;
    });
  }
  
  void decreaseHappiness() {
    setState(() {
      if (happiness > 0) happiness -= 10;
    });
  }
  
  // New method to get mood based on happiness level
  String getMood() {
    if (happiness >= 70) return "Happy";
    if (happiness >= 30) return "Neutral";
    return "Unhappy";
  }
  
  // New method to get mood emoji based on happiness level
  IconData getMoodIcon() {
    if (happiness >= 70) return Icons.sentiment_very_satisfied;
    if (happiness >= 30) return Icons.sentiment_neutral;
    return Icons.sentiment_very_dissatisfied;
  }
  
  // Get color based on mood
  Color getMoodColor() {
    if (happiness >= 70) return Colors.green;
    if (happiness >= 30) return Colors.amber;
    return Colors.red;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.pets), text: "Pet"),
            Tab(icon: Icon(Icons.fastfood), text: "Feed"),
            Tab(icon: Icon(Icons.sports_soccer), text: "Play"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pet tab - now with mood indicator
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, size: 100),
                SizedBox(height: 20),
                Text("Happiness: $happiness", style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                // New mood indicator section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: getMoodColor()),
                    borderRadius: BorderRadius.circular(10),
                    color: getMoodColor().withOpacity(0.1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(getMoodIcon(), color: getMoodColor(), size: 32),
                      SizedBox(width: 10),
                      Text(
                        "Mood: ${getMood()}", 
                        style: TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.bold,
                          color: getMoodColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Feed tab
          Center(
            child: ElevatedButton(
              onPressed: increaseHappiness,
              child: Text("Feed Pet"),
            ),
          ),
          // Play tab - fixed to increase happiness
          Center(
            child: ElevatedButton(
              onPressed: increaseHappiness, // Changed from decreaseHappiness
              child: Text("Play with Pet"),
            ),
          ),
        ],
      ),
    );
  }
}