import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Flip Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Card Flip Game')),
      body: GridView.builder(
        padding: const EdgeInsets.all(5),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 5,
          mainAxisSpacing: 10,
        ),
        itemCount: 16,
        itemBuilder: (context, index) {
          final card = gameState.cards[index];
          return GestureDetector(
            onTap: () {
              gameState.flipCard(index);
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0, 1), 
                  end: Offset.zero, 
                ).animate(animation);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              child: SizedBox(
                key: ValueKey<bool>(card.isFaceUp),
                width: 500, 
                height: 500,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.transparent,
                    image: DecorationImage(
                      image: NetworkImage(
                        card.isFaceUp ? card.frontImage : 'assets/cardback.jpg',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GameState extends ChangeNotifier {
  List<Card> cards = [];
  int? firstFlippedIndex; 

  GameState() {
    _initializeCards();
  }

  void _initializeCards() {
    List<String> images = [
      'https://picsum.photos/id/1/200/300',
      'https://picsum.photos/id/2/200/300',
      'https://picsum.photos/id/3/200/300',
      'https://picsum.photos/id/4/200/300',
      'https://picsum.photos/id/5/200/300',
      'https://picsum.photos/id/6/200/300',
      'https://picsum.photos/id/7/200/300',
      'https://picsum.photos/id/8/200/300',
    ];

    List<String> cardImages = List.from(images)..addAll(images);
    cardImages.shuffle();

    cards = cardImages.take(16).map((image) => Card(image)).toList();
  }

  void flipCard(int index) {
    if (firstFlippedIndex == null) {
      firstFlippedIndex = index;
      cards[index].isFaceUp = true;
      notifyListeners();
    } else if (firstFlippedIndex != index) {
      cards[index].isFaceUp = true;
      notifyListeners();

      if (cards[firstFlippedIndex!].frontImage == cards[index].frontImage) {
        firstFlippedIndex = null; 
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          cards[firstFlippedIndex!].isFaceUp = false;
          cards[index].isFaceUp = false;
          firstFlippedIndex = null; 
          notifyListeners();
        });
      }
    }
  }
}

class Card {
  final String frontImage;
  bool isFaceUp = false;

  Card(this.frontImage);
}
