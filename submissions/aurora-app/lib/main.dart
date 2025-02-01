import 'package:flutter/material.dart';
import 'pages/hidden_journal_page.dart';
import 'pages/game_page.dart';
import 'pages/regular_page.dart';
import 'pages/model_page.dart';
import 'pages/crossword_page.dart';
import 'pages/character_customization_page.dart';

void main() {
  runApp(HiddenJournalApp());
}

class HiddenJournalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hidden Journal',
      theme: ThemeData.dark(),
      home: SpaceHomePage(),
    );
  }
}

class SpaceHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/space_wallpaper.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlanetButton(
                  label: "Hidden Journal",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HiddenJournalPage()),
                  ),
                ),
                PlanetButton(
                  label: "Game",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GamePage()),
                  ),
                ),
                PlanetButton(
                  label: "Regular Page",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegularPage()),
                  ),
                ),
                PlanetButton(
                  label: "Model Page",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ModelPage()),
                  ),
                ),
                PlanetButton(
                  label: "Crossword",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CrosswordPage()),
                  ),
                ),
                PlanetButton(
                  label: "Character Customization",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CharacterCustomizationPage()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlanetButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  PlanetButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(20),
          backgroundColor: Colors.blueAccent,
        ),
        onPressed: onPressed,
        child: Text(label, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
