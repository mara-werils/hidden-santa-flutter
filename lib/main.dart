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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final crossAxisCount = isLandscape ? 4 : 2;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Participants', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Scrollable participants section
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(participants.length, (index) {
                return GestureDetector(
                  onTap: () => onEdit(index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Text(participants[index], style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 20,
            runSpacing: 10,
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
          // Scrollable content section (Generated Pairs)
          if (shuffledPairs.isNotEmpty) ...[
            const Text('Secret Santa Pairs:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            // Scrollable generated pairs section
            Expanded(
              child: SizedBox(
                width: double.infinity,
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
            ),
          ],
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
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialName; // Initialize with the existing name
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Name'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Enter name',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _controller.text); // Return the edited name
                },
                child: const Text('Done'),
              ),
            ],
          ),
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
    return Center(
      child: SingleChildScrollView(
        child: Column(
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
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('🎅 Hidden Santa', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text(
            'Hidden Santa is a fun and simple mobile application designed to randomly assign Secret Santa gift-givers within a group. '
                'Users can input a list of participant names, and the app will automatically and anonymously generate gift-giving pairs, ensuring that no one is assigned to themselves. '
                'It’s perfect for holiday parties, team events, family gatherings, or any festive occasion.',
          ),
          SizedBox(height: 24),
          Text('Credits:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
              'Developed by Marlen, Dias, Azamat in the scope of the course “Crossplatform Development” at Astana IT University.\n'
                  'Mentor (Teacher): Assistant Professor Abzal Kyzyrkanov'),
        ],
      ),
    );
  }
}
