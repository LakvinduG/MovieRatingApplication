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

  Future<void> _loadSearchHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  static Future<void> _addSearchHistory(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Load the current search history from prefs, or initialize an empty list if null.
    List<String> _searchHistory = prefs.getStringList('searchHistory') ?? [];
    
    // Add the new search id to the search history list.
    _searchHistory.add(id);
    
    // Save the updated search history back to SharedPreferences.
    await prefs.setStringList('searchHistory', _searchHistory);
    
    // If you're using this in a StatefulWidget and need to update the UI accordingly,
    // make sure to call setState to trigger a rebuild with the updated search history.
    // This is assuming this function is part of a State class.
  //   setState(() {
  //     // This updates the state variable _searchHistory with the new list.
  //     this._searchHistory = _searchHistory;
  // });
}

  // Optionally, you can add a method to clear the search history
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
