import 'package:flutter/material.dart';

void main() {
  runApp(const HiddenSantaApp());
}

class HiddenSantaApp extends StatelessWidget {
  const HiddenSantaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hidden Santa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const AboutPage(),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Hidden Santa'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '🎅 Hidden Santa',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Hidden Santa is a fun and simple mobile application designed to randomly assign Secret Santa gift-givers within a group. '
                  'Users can input a list of participant names, and the app will automatically and anonymously generate gift-giving pairs, ensuring that no one is assigned to themselves. '
                  'It’s perfect for holiday parties, team events, family gatherings, or any festive occasion.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            SizedBox(height: 24),
            Text(
              'Credits:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Developed by Marlen, Dias, Azamat in the scope of the course “Crossplatform Development” at Astana IT University.\n'
                  'Mentor (Teacher): Assistant Professor Abzal Kyzyrkanov',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
