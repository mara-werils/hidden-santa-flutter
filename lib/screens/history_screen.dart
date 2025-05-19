import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _firestore = FirestoreService();
  final _localStorage = LocalStorageService();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _filteredSessions = [];

  bool _loading = true;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _sessions = [];
        _filteredSessions = [];
        _loading = false;
      });
      return;
    }

    try {
      final remote = await _firestore.loadHistorySessions();

      if (remote.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No history found in Firebase.'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      remote.sort((a, b) {
        final t1 = _extractTimestamp(a['timestamp']);
        final t2 = _extractTimestamp(b['timestamp']);
        return t2.compareTo(t1); // Newest first
      });

      setState(() {
        _sessions = remote;
        _filteredSessions = remote;
        _loading = false;
        _isOffline = false;
      });

    } catch (e) {
      final localPairs = await _localStorage.loadShuffledPairs();

      setState(() {
        _sessions = [
          {
            'timestamp': DateTime.now(),
            'pairs': localPairs,
          }
        ];
        _filteredSessions = _sessions;
        _loading = false;
        _isOffline = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firebase unavailable. Showing local data.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  DateTime _extractTimestamp(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  void _filterHistory(String query) {
    final filtered = _sessions.where((session) {
      final pairs = List<String>.from(session['pairs'] ?? []);
      return pairs.any((pair) => pair.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    setState(() {
      _filteredSessions = filtered;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shuffled History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search participants...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterHistory,
            ),
          ),
          Expanded(
            child: _filteredSessions.isEmpty
                ? const Center(child: Text('No matching sessions found.'))
                : ListView.builder(
              itemCount: _filteredSessions.length,
              itemBuilder: (context, index) {
                final session = _filteredSessions[index];
                final pairs = List<String>.from(session['pairs'] ?? []);
                final timestamp = _extractTimestamp(session['timestamp']);

                return ExpansionTile(
                  title: Text('Session ${index + 1}'),
                  subtitle: Text(
                    '${timestamp.toLocal()}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  children: pairs
                      .map((pair) => ListTile(title: Text(pair)))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isOffline
          ? Container(
        color: Colors.red[100],
        padding: const EdgeInsets.all(12),
        child: const Text(
          'Offline mode: showing local history.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red),
        ),
      )
          : null,
    );
  }
}
