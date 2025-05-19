import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_pref_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userEmail;
  final _prefs = UserPrefService();
  ThemeMode _currentThemeMode = ThemeMode.light;
  Locale _currentLocale = const Locale('en');
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadPreferences();
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
    setState(() => _isSaving = true);
    try {
      await _prefs.savePreferences(
        theme: _themeToString(_currentThemeMode),
        language: _currentLocale.languageCode,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preferences saved")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save preferences: $e")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
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
    final isGuest = user == null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: SingleChildScrollView(
          child: isGuest
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 60),
              const SizedBox(height: 16),
              const Text(
                "You're in guest mode.",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please log in to access your profile.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: widget.onLogout,
                child: const Text("Go to Login"),
              ),
            ],
          )
              : Column(
            children: [
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
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Light Theme')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark Theme')),
                  DropdownMenuItem(value: ThemeMode.system, child: Text('System Default')),
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
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(value: Locale('ru'), child: Text('Russian')),
                  DropdownMenuItem(value: Locale('kk'), child: Text('Kazakh')),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _savePreferences,
                child: _isSaving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Save Preferences"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  widget.onLogout();
                },
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
