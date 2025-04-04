import 'package:flutter/material.dart';
import 'dart:math';

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
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _numParticipants = 30;
  List<String> participants = List.generate(30, (index) => 'Participant ${index + 1}');
  List<String> shuffledPairs = [];

  void _shufflePairs() {
    List<int> indices = List.generate(participants.length, (index) => index);
    bool isDeranged = false;
    while (!isDeranged) {
      indices.shuffle();
      isDeranged = true;
      for (int i = 0; i < indices.length; i++) {
        if (indices[i] == i) {
          isDeranged = false;
          break;
        }
      }
    }
    setState(() {
      shuffledPairs = [];
      for (int i = 0; i < participants.length; i++) {
        shuffledPairs.add('${participants[i]} → ${participants[indices[i]]}');
      }
    });
  }

  void _resetPairs() {
    setState(() {
      shuffledPairs.clear();
    });
  }

  void _updateParticipants(int count) {
    if (count % 2 != 0) count += 1;
    setState(() {
      _numParticipants = count;
      participants = List.generate(count, (index) => 'Participant ${index + 1}');
      shuffledPairs.clear();
    });
  }

  void _editParticipantName(int index) async {
    String newName = await showDialog(
      context: context,
      builder: (context) => NameTypingDialog(initialName: participants[index]),
    );

    if (newName.isNotEmpty) {
      setState(() {
        participants[index] = newName;
        shuffledPairs.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hidden Santa'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(
            participants: participants,
            onShuffle: _shufflePairs,
            onReset: _resetPairs,
            onEdit: _editParticipantName,
            shuffledPairs: shuffledPairs,
          ),
          const AboutScreen(),
          SettingsScreen(onUpdateParticipants: _updateParticipants, numParticipants: _numParticipants),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<String> participants;
  final VoidCallback onShuffle;
  final VoidCallback onReset;
  final void Function(int) onEdit;
  final List<String> shuffledPairs;

  const HomeScreen({
    required this.participants,
    required this.onShuffle,
    required this.onReset,
    required this.onEdit,
    required this.shuffledPairs,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Participants', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 2,
              ),
              itemCount: participants.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => onEdit(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(participants[index], style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: onShuffle,
                icon: const Icon(Icons.shuffle),
                label: const Text('Generate Pairs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (shuffledPairs.isNotEmpty) ...[
            const Text('Secret Santa Pairs:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: shuffledPairs.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: Colors.red.shade50,
                    child: ListTile(
                      title: Text(shuffledPairs[index], textAlign: TextAlign.center),
                    ),
                  );
                },
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class NameTypingDialog extends StatefulWidget {
  final String initialName;
  const NameTypingDialog({super.key, required this.initialName});

  @override
  State<NameTypingDialog> createState() => _NameTypingDialogState();
}

class _NameTypingDialogState extends State<NameTypingDialog> {
  String name = '';

  void addChar(String char) {
    setState(() {
      name += char;
    });
  }

  void backspace() {
    setState(() {
      if (name.isNotEmpty) name = name.substring(0, name.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Name'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((char) => ElevatedButton(
                onPressed: () => addChar(char),
                child: Text(char),
              )),
              ElevatedButton(onPressed: backspace, child: const Icon(Icons.backspace)),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, name),
                child: const Text('Done'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final Function(int) onUpdateParticipants;
  final int numParticipants;

  const SettingsScreen({required this.onUpdateParticipants, required this.numParticipants, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Adjust Number of Participants', style: TextStyle(fontSize: 20)),
        Slider(
          value: numParticipants.toDouble(),
          min: 6,
          max: 50,
          divisions: 22,
          label: numParticipants.toString(),
          onChanged: (value) => onUpdateParticipants(value.toInt()),
        ),
      ],
    );
  }
}


class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('🎅 Hidden Santa', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text('Hidden Santa is a fun and simple mobile application designed to randomly assign Secret Santa gift-givers within a group. '
              'Users can input a list of participant names, and the app will automatically and anonymously generate gift-giving pairs, ensuring that no one is assigned to themselves. '
              'It’s perfect for holiday parties, team events, family gatherings, or any festive occasion.',),
          SizedBox(height: 24),
          Text('Credits:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Developed by Marlen, Dias, Azamat in the scope of the course “Crossplatform Development” at Astana IT University.\n'
              'Mentor (Teacher): Assistant Professor Abzal Kyzyrkanov'),
        ],
      ),
    );
  }
}
