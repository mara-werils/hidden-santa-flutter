import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/local_storage_service.dart';
import '../widgets/name_typing_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'about_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  final void Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;
  final void Function(Locale) onLocaleChanged;
  final Locale currentLocale;

  const MainScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
    required this.onLocaleChanged,
    required this.currentLocale,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _numParticipants = 30;
  bool _showRegister = false;
  bool _isOffline = false;
  final _firestore = FirestoreService();
  final _storage = LocalStorageService();
  List<String> participants = List.generate(30, (index) => 'Participant ${index + 1}');
  List<String> shuffledPairs = [];

  void _shufflePairs() {
    List<int> indices = List.generate(participants.length, (i) => i);
    bool isDeranged = false;
    while (!isDeranged) {
      indices.shuffle();
      isDeranged = !indices.asMap().entries.any((e) => e.key == e.value);
    }

    final newPairs = List.generate(
      participants.length,
          (i) => '${participants[i]} → ${participants[indices[i]]}',
    );

    setState(() {
      shuffledPairs = newPairs;
    });

    _storage.saveShuffledPairs(shuffledPairs);

    _firestore.saveHistory(shuffledPairs);
  }



  void _resetPairs() {
    setState(() {
      shuffledPairs.clear();
    });
  }

  void _updateParticipants(int count) {
    if (count % 2 != 0) count += 1;
    final updated = List.generate(count, (i) => 'Participant ${i + 1}');
    setState(() {
      _numParticipants = count;
      participants = updated;
      shuffledPairs.clear();
    });
    _storage.saveParticipants(updated);
    _storage.saveShuffledPairs([]);
  }

  void _editParticipantName(int index) async {
    String? newName = await showDialog(
      context: context,
      builder: (context) => NameTypingDialog(initialName: participants[index]),
    );
    if (newName?.isNotEmpty ?? false) {
      setState(() {
        participants[index] = newName!;
        shuffledPairs.clear();
      });
      _storage.saveParticipants(participants);
      _storage.saveShuffledPairs([]);
    }
  }

  Future<void> _syncDataToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to sync data.")),
      );
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await docRef.set({
        'participants': participants,
        'shuffledPairs': shuffledPairs,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data synced to Firebase!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sync failed: ${e.toString()}")),
      );
    }
  }



  @override
  void initState() {
    super.initState();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      print('Connectivity changed: $result'); // 🧪 DEBUG
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    });


    Connectivity().checkConnectivity().then((result) {
      print('Initial connectivity: $result'); // 🧪 DEBUG
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    });
    // Load saved participants and shuffled pairs
    _storage.loadParticipants().then((loaded) {
      if (loaded.isNotEmpty) {
        setState(() => participants = loaded);
      }
    });

    _storage.loadShuffledPairs().then((loadedPairs) {
      if (loadedPairs.isNotEmpty) {
        setState(() => shuffledPairs = loadedPairs);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

    return Scaffold(
      body: Column(
        children: [
          if (_isOffline)
            Container(
              width: double.infinity,
              color: Colors.red.shade300,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.wifi_off, color: Colors.red),
                  SizedBox(width: 10),
                  Text(
                    "You are offline. Some features may be unavailable.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          Expanded(
            child: IndexedStack(
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
                SettingsScreen(
                  onUpdateParticipants: _updateParticipants,
                  numParticipants: _numParticipants,
                  onThemeChanged: widget.onThemeChanged,
                  currentThemeMode: widget.currentThemeMode,
                  onLocaleChanged: widget.onLocaleChanged,
                  currentLocale: widget.currentLocale,
                ),
                if (!isLoggedIn)
                  _showRegister
                      ? RegisterPage(onRegistered: () {
                    setState(() {
                      _showRegister = false;
                    });
                  })
                      : LoginPage(
                    onLoginSuccess: () {
                      setState(() {});
                    },
                    onTapSignUp: () {
                      setState(() {
                        _showRegister = true;
                      });
                    },
                  )
                else
                  ProfileScreen(
                    onLogout: () {
                      setState(() {
                        _selectedIndex = 3;
                      });
                    },
                  ),
                const HistoryScreen(),
              ],
            ),
          ),
          if (_selectedIndex != 0 && !_isOffline && FirebaseAuth.instance.currentUser != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.sync),
                label: const Text("Sync Now"),
                onPressed: _syncDataToFirebase,
              ),
            ),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _showRegister = false; // reset to login on Profile tab
          });
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: t.home),
          BottomNavigationBarItem(icon: const Icon(Icons.info), label: t.about),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: t.settings),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: isLoggedIn
                ? t.profile
                : _showRegister
                ? t.register
                : t.login,
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
