import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
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
import '../state/theme_notifier.dart';
import '../state/locale_notifier.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

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
    final t = AppLocalizations.of(context)!;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.loginToSync)),
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
        SnackBar(content: Text(t.syncedToFirebase)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.syncFailed}: ${e.toString()}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    });

    Connectivity().checkConnectivity().then((result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    });

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
    final themeMode = context.watch<ThemeNotifier>().currentTheme;
    final locale = context.watch<LocaleNotifier>().currentLocale;
    final onThemeChanged = context.read<ThemeNotifier>().setTheme;
    final onLocaleChanged = context.read<LocaleNotifier>().setLocale;

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
                children: [
                  const Icon(Icons.wifi_off, color: Colors.red),
                  const SizedBox(width: 10),
                  Text(
                    t.offlineWarning,
                    style: const TextStyle(color: Colors.grey),
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
                  onThemeChanged: onThemeChanged,
                  currentThemeMode: themeMode,
                  onLocaleChanged: onLocaleChanged,
                  currentLocale: locale,
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
          if (_selectedIndex != 0 && _selectedIndex != 1 && !_isOffline && FirebaseAuth.instance.currentUser != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.sync),
                label: Text(t.syncNow),
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
            _showRegister = false;
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
          BottomNavigationBarItem(icon: const Icon(Icons.history), label: t.history),
        ],
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
