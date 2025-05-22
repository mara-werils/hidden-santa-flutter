import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/user_pref_service.dart';

class SettingsScreen extends StatelessWidget {
  final Function(int) onUpdateParticipants;
  final int numParticipants;
  final void Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;
  final void Function(Locale) onLocaleChanged;
  final Locale currentLocale;

  const SettingsScreen({
    super.key,
    required this.onUpdateParticipants,
    required this.numParticipants,
    required this.onThemeChanged,
    required this.currentThemeMode,
    required this.onLocaleChanged,
    required this.currentLocale,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isGuest = FirebaseAuth.instance.currentUser == null;
    final prefs = UserPrefService();

    void _updateTheme(ThemeMode mode) {
      onThemeChanged(mode);
      prefs.savePreferences(
        theme: mode.name,
        language: currentLocale.languageCode,
        updatedAt: DateTime.now(),
      );
    }

    void _updateLocale(Locale locale) {
      onLocaleChanged(locale);
      prefs.savePreferences(
        theme: currentThemeMode.name,
        language: locale.languageCode,
        updatedAt: DateTime.now(),
      );
    }

    if (isGuest) {
      final t = AppLocalizations.of(context)!;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            t.guestModed,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }


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
                  _updateTheme(ThemeMode.dark);
                } else if (details.primaryVelocity! > 0) {
                  _updateTheme(ThemeMode.light);
                }
              },
              onLongPress: () => _updateTheme(ThemeMode.system),
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.swipe, size: 30),
                    Text(t.swipeHint, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
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
                _buildLangButton('English', const Locale('en'), _updateLocale),
                _buildLangButton('Русский', const Locale('ru'), _updateLocale),
                _buildLangButton('Қазақша', const Locale('kk'), _updateLocale),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(String label, Locale locale, Function(Locale) onTap) {
    final isSelected = locale == currentLocale;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: () => onTap(locale),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.redAccent : Colors.grey,
          foregroundColor: Colors.white,
        ),
        child: Text(label),
      ),
    );
  }
}
