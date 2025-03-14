import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const CardMatchingGame());
}

class CardMatchingGame extends StatelessWidget {
  const CardMatchingGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const GameScreen(),
    );
  }
}

class Card {
  final String frontImage;
  final int id;
  bool isFlipped;
  bool isMatched;

  Card({
    required this.frontImage,
    required this.id,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<Card> cards = [];
  int? firstCardIndex;
  int? secondCardIndex;
  bool isProcessing = false;
  int score = 0;
  int seconds = 0;
  Timer? timer;
  bool gameStarted = false;
  bool gameCompleted = false;
  
  // List of emojis for card fronts
  final List<String> cardEmojis = [
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼',
  ];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    // Create pairs of cards
    cards = [];
    for (int i = 0; i < cardEmojis.length; i++) {
      cards.add(Card(frontImage: cardEmojis[i], id: i));
      cards.add(Card(frontImage: cardEmojis[i], id: i));
    }
    
    // Shuffle the cards
    cards.shuffle(Random());
    
    // Reset game state
    firstCardIndex = null;
    secondCardIndex = null;
    isProcessing = false;
    score = 0;
    seconds = 0;
    gameStarted = false;
    gameCompleted = false;
    timer?.cancel();
    timer = null;
  }

  void _startTimer() {
    if (!gameStarted) {
      gameStarted = true;
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          seconds++;
        });
      });
    }
  }

  void _stopTimer() {
    timer?.cancel();
  }

  void _onCardTap(int index) {
    if (isProcessing || cards[index].isFlipped || cards[index].isMatched || gameCompleted) {
      return;
    }

    _startTimer(); // Start timer on first card flip

    setState(() {
      cards[index].isFlipped = true;

      if (firstCardIndex == null) {
        firstCardIndex = index;
      } else if (secondCardIndex == null && firstCardIndex != index) {
        secondCardIndex = index;
        isProcessing = true;

        // Check for a match
        if (cards[firstCardIndex!].id == cards[secondCardIndex!].id) {
          // Match found
          cards[firstCardIndex!].isMatched = true;
          cards[secondCardIndex!].isMatched = true;
          score += 10; // Add points for a match
          
          // Reset selection
          firstCardIndex = null;
          secondCardIndex = null;
          isProcessing = false;
          
          // Check if game is complete
          if (cards.every((card) => card.isMatched)) {
            gameCompleted = true;
            _stopTimer();
          }
        } else {
          // No match, flip back after delay
          score = score > 2 ? score - 2 : 0; // Deduct points for mismatch
          
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              setState(() {
                cards[firstCardIndex!].isFlipped = false;
                cards[secondCardIndex!].isFlipped = false;
                firstCardIndex = null;
                secondCardIndex = null;
                isProcessing = false;
              });
            }
          });
        }
      }
    });
  }

  void _resetGame() {
    setState(() {
      _initializeGame();
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Matching Game'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: $score',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Time: ${_formatTime(seconds)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: gameCompleted
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Congratulations!',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'You completed the game in ${_formatTime(seconds)} with a score of $score',
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _resetGame,
                          child: const Text('Play Again'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      return CardWidget(
                        card: cards[index],
                        onTap: () => _onCardTap(index),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _resetGame,
              child: const Text('Reset Game'),
            ),
          ),
        ],
      ),
    );
  }
}

class CardWidget extends StatefulWidget {
  final Card card;
  final VoidCallback onTap;

  const CardWidget({
    Key? key,
    required this.card,
    required this.onTap,
  }) : super(key: key);

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _frontAnimation;
  late Animation<double> _backAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _frontAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: pi / 2)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: ConstantTween(pi / 2),
        weight: 50.0,
      ),
    ]).animate(_controller);

    _backAnimation = TweenSequence([
      TweenSequenceItem(
        tween: ConstantTween(pi / 2),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: pi / 2, end: pi)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50.0,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(CardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.isFlipped != oldWidget.card.isFlipped) {
      if (widget.card.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Back face
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_backAnimation.value),
                child: Visibility(
                  visible: _controller.value <= 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Front face
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_frontAnimation.value),
                child: Visibility(
                  visible: _controller.value > 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.card.isMatched ? Colors.green : Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        widget.card.frontImage,
                        style: const TextStyle(fontSize: 32.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}