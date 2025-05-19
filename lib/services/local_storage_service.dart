import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _participantsKey = 'participants';
  static const _shuffledPairsKey = 'shuffled_pairs';

  Future<void> saveParticipants(List<String> participants) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_participantsKey, participants);
  }

  Future<List<String>> loadParticipants() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_participantsKey) ?? [];
  }

  Future<void> saveShuffledPairs(List<String> pairs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_shuffledPairsKey, pairs);
  }

  Future<List<String>> loadShuffledPairs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_shuffledPairsKey) ?? [];
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_participantsKey);
    await prefs.remove(_shuffledPairsKey);
  }
}
