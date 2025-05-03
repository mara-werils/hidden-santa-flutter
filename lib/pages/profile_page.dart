import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hidden_santa/services/auth_service.dart';
import 'package:hidden_santa/services/user_pref_service.dart';
import 'package:hidden_santa/main.dart';

class ProfilePage extends StatefulWidget {
  final void Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;
  final void Function(Locale) onLocaleChanged;
  final Locale currentLocale;

  const ProfilePage({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
    required this.onLocaleChanged,
    required this.currentLocale,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _prefs = UserPrefService();
  final _authService = AuthService();
  late User user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await _prefs.loadPreferences();
    if (prefs != null) {
      final theme = prefs['theme'];
      final lang = prefs['language'];
      if (theme != null) widget.onThemeChanged(_toThemeMode(theme));
      if (lang != null) widget.onLocaleChanged(Locale(lang));
    }
  }

  ThemeMode _toThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Welcome, ${user.email ?? 'Google User'}"),
                    const SizedBox(height: 16),
                    Text("Theme: ${widget.currentThemeMode.name}"),
                    Text("Language: ${widget.currentLocale.languageCode}"),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await _prefs.savePreferences(
                          theme: _themeToString(widget.currentThemeMode),
                          language: widget.currentLocale.languageCode,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Preferences saved")),
                        );
                      },
                      child: const Text("Save Preferences"),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await _authService.signOut();
                        // After logout, navigate to the login page (or main screen)
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HiddenSantaApp()),
                        );
                      },
                      child: const Text("Logout"),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to main screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HiddenSantaApp()),
                        );
                      },
                      child: const Text("Go to Home"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
