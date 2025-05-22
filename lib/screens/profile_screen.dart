import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/user_pref_service.dart';
import '../state/theme_notifier.dart';
import '../state/locale_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userEmail;
  final _prefs = UserPrefService();

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadPreferencesAndApply();
  }

  void _loadUser() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userEmail = user?.email;
    });
  }

  Future<void> _loadPreferencesAndApply() async {
    final prefs = await _prefs.loadPreferences();
    if (prefs != null) {
      final themeStr = prefs['theme'] ?? 'light';
      final langStr = prefs['language'] ?? 'en';
      final supportedLanguages = ['en', 'ru', 'kk'];

      final themeMode = _toThemeMode(themeStr);
      final locale = Locale(supportedLanguages.contains(langStr) ? langStr : 'en');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ThemeNotifier>().setTheme(themeMode);
        context.read<LocaleNotifier>().setLocale(locale);
      });
    }
  }

  ThemeMode _toThemeMode(String value) {
    switch (value.toLowerCase()) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isGuest = FirebaseAuth.instance.currentUser == null;
    final theme = context.watch<ThemeNotifier>().currentTheme;
    final locale = context.watch<LocaleNotifier>().currentLocale;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: SingleChildScrollView(
          child: isGuest
              ? Column(
            children: [
              const Icon(Icons.lock_outline, size: 60),
              const SizedBox(height: 16),
              Text(t.guestModed),
              ElevatedButton(
                onPressed: widget.onLogout,
                child: Text(t.goToLogin),
              ),
            ],
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${t.email}: $_userEmail', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              Text('${t.theme}: ${theme.name.toUpperCase()}'),
              Text('${t.language}: ${locale.languageCode.toUpperCase()}'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  widget.onLogout();
                },
                child: Text(t.logout),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
