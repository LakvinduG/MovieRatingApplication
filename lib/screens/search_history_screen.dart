import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryScreen extends StatefulWidget {
  @override
  _SearchHistoryScreenState createState() => _SearchHistoryScreenState();

}

class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  // Load search history from Sharedpreferences
  Future<void> _loadSearchHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  // Add a search id to the search history
  static Future<void> _addSearchHistory(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Load the current search history from prefs, or initialize an empty list if null.
    List<String> _searchHistory = prefs.getStringList('searchHistory') ?? [];
    
    // Add the new search id to the search history list.
    _searchHistory.add(id);
    
    // Save the updated search history back to SharedPreferences.
    await prefs.setStringList('searchHistory', _searchHistory);
    

}


  Future<void> _clearSearchHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
    setState(() {
      _searchHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search History'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: _clearSearchHistory, // Clears the search history
          ),
        ],
      ),
      body: _searchHistory.isEmpty
          ? Center(child: Text('No search history found.'))
          : ListView.builder(
              itemCount: _searchHistory.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_searchHistory[index]),
                  leading: Icon(Icons.history),
                  onTap: () {
                    // Return the selected query to the previous screen
                    Navigator.pop(context, _searchHistory[index]);
                  },
                );
              },
            ),
    );
  }
}
