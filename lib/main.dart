import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/user_pref_service.dart';
import 'pages/register_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HiddenSantaApp());
}


class HiddenSantaApp extends StatefulWidget {
  const HiddenSantaApp({super.key});

  @override
  State<HiddenSantaApp> createState() => _HiddenSantaAppState();
}

class _HiddenSantaAppState extends State<HiddenSantaApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('kk');

  void _toggleTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void _changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hidden Santa',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.redAccent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
        Locale('kk'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('en');
      },
      home: MainScreen(
        currentThemeMode: _themeMode,
        onThemeChanged: _toggleTheme,
        onLocaleChanged: _changeLocale,
        currentLocale: _locale,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final void Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;
  final void Function(Locale) onLocaleChanged;
  final Locale currentLocale;

  const MainScreen({
    required this.onThemeChanged,
    required this.currentThemeMode,
    required this.onLocaleChanged,
    required this.currentLocale,
    super.key,
  });

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
    String? newName = await showDialog(
      context: context,
      builder: (context) => NameTypingDialog(initialName: participants[index]),
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        participants[index] = newName;
        shuffledPairs.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
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
          SettingsScreen(
            onUpdateParticipants: _updateParticipants,
            numParticipants: _numParticipants,
            onThemeChanged: widget.onThemeChanged,
            currentThemeMode: widget.currentThemeMode,
            onLocaleChanged: widget.onLocaleChanged,
            currentLocale: widget.currentLocale,
          ),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: t.home),
          BottomNavigationBarItem(icon: const Icon(Icons.info), label: t.about),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: t.settings),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: t.profile),
        ],
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
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
    final t = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.participants, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
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
                        child: Text(
                          participants[index],
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : null,
                          ),
                        ),
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
                  label: Text(t.generatePairs),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt),
                  label: Text(t.reset),
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
              Text(t.secretSantaPairs, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
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
                          title: Text(
                            shuffledPairs[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
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
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialName;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(t.editName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: t.enterName,
              border: const OutlineInputBorder(),
            ),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _controller.text);
                },
                child: Text(t.done),
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
  final void Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;
  final void Function(Locale) onLocaleChanged;
  final Locale currentLocale;

  const SettingsScreen({
    required this.onUpdateParticipants,
    required this.numParticipants,
    required this.onThemeChanged,
    required this.currentThemeMode,
    required this.onLocaleChanged,
    required this.currentLocale,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(t.adjustParticipants, style: const TextStyle(fontSize: 20)),
            Slider(
              value: numParticipants.toDouble(),
              min: 6,
              max: 50,
              divisions: 22,
              label: numParticipants.toString(),
              onChanged: (value) => onUpdateParticipants(value.toInt()),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! < 0) {
                  onThemeChanged(ThemeMode.dark);
                } else if (details.primaryVelocity! > 0) {
                  onThemeChanged(ThemeMode.light);
                }
              },
              onLongPress: () => onThemeChanged(ThemeMode.system),
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.swipe, size: 30),
                    Text(
                      t.swipeHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('${t.currentTheme}: ${currentThemeMode.name.toUpperCase()}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(t.language, style: const TextStyle(fontSize: 18)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLangButton(context, 'English', const Locale('en')),
                _buildLangButton(context, 'Русский', const Locale('ru')),
                _buildLangButton(context, 'Қазақша', const Locale('kk')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(BuildContext context, String label, Locale locale) {
    final isSelected = locale == currentLocale;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: () => onLocaleChanged(locale),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.redAccent : Colors.grey,
          foregroundColor: Colors.white,
        ),
        child: Text(label),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.aboutTitle, style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(t.aboutDescription),
          const SizedBox(height: 24),
          Text(t.credits, style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(t.developerCredits),
        ],
      ),
    ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final bool isGuest;
  const ProfileScreen({super.key, this.isGuest = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userEmail;
  final _prefs = UserPrefService();
  ThemeMode _currentThemeMode = ThemeMode.light;
  Locale _currentLocale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadUser();
    if (!widget.isGuest && FirebaseAuth.instance.currentUser != null) {
      _loadPreferences();
    }
  }

  void _loadUser() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userEmail = user?.email;
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await _prefs.loadPreferences();
    if (prefs != null) {
      final language = prefs['language'] ?? 'en';
      final supportedLanguages = ['en', 'ru', 'kk'];
      setState(() {
        _currentThemeMode = _toThemeMode(prefs['theme'] ?? 'light');
        _currentLocale = Locale(
          supportedLanguages.contains(language) ? language : 'en',
        );
      });
    }
  }


  Future<void> _savePreferences() async {
    await _prefs.savePreferences(
      theme: _themeToString(_currentThemeMode),
      language: _currentLocale.languageCode,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Preferences saved")),
    );
  }

  ThemeMode _toThemeMode(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  String _themeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      default:
        return 'light';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (widget.isGuest || user == null) ...[
                  const Text("Guest Mode", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text("Login"),
                  ),
                ] else ...[
                  Text('Logged in as: $_userEmail', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  DropdownButton<ThemeMode>(
                    value: _currentThemeMode,
                    onChanged: (value) {
                      setState(() {
                        _currentThemeMode = value!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System Default'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<Locale>(
                    value: _currentLocale,
                    onChanged: (value) {
                      setState(() {
                        _currentLocale = value!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                        value: Locale('en'),
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: Locale('ru'),
                        child: Text('Russian'),
                      ),
                      DropdownMenuItem(
                        value: Locale('kk'),
                        child: Text('Kazakh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _savePreferences,
                    child: const Text("Save Preferences"),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text("Logout"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}



///////////////////////////////////////


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = "";

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = "Login failed: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = "Google login failed: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loginAsGuest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen(isGuest: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else ...[
              ElevatedButton(
                onPressed: _login,
                child: const Text("Login"),
              ),
              ElevatedButton(
                onPressed: _loginWithGoogle,
                child: const Text("Login with Google"),
              ),
              ElevatedButton(
                onPressed: _loginAsGuest,
                child: const Text("Continue as Guest"),
              ),
            ],
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
