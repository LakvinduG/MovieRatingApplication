// Import Flutter Material package and other necessary packages
import 'package:flutter/material.dart';
import 'package:oneflix/api/api_service.dart';
import 'detail_screen.dart'; // Ensure this points to your actual DetailScreen widget
import 'search_history_screen.dart'; // Ensure this points to your actual SearchHistoryScreen widget
import 'package:shared_preferences/shared_preferences.dart';

// Define enum for search modes
enum SearchMode { byTitle, byActor, byTwoActors }

// SearchScreen StatefulWidget
class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

// State class for SearchScreen
class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<dynamic> _searchResults = [];
  SearchMode _searchMode = SearchMode.byTitle;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    _loadLastSearchQuery();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLastSearchQuery() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lastSearch = prefs.getString('lastSearch');
    if (lastSearch != null) {
      setState(() {
        _searchController.text = lastSearch;
        _searchMovies(lastSearch);
      });
    }
  }

  Future<void> _saveSearchQuery(String query) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('searchHistory') ?? [];
    if (!history.contains(query)) {
      history.add(query);
      await prefs.setStringList('searchHistory', history);
    }
    await prefs.setString('lastSearch', query);
  }

  void _onSearchTextChanged() {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _saveSearchQuery(query);
      _searchMovies(query);
    } else {
      setState(() {
        _searchResults.clear();
      });
    }
  }

  void _searchMovies(String query) async {
    setState(() {
      _searchResults.clear();
    });

    try {
      List<dynamic> results = await _apiService.searchMovies(query); // Adjust this call according to your API service

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Movies/TV Shows'),
        actions: <Widget>[
          PopupMenuButton<SearchMode>(
            onSelected: (SearchMode result) {
              setState(() {
                _searchMode = result;
                _searchResults.clear(); // Clear results on mode change
                _searchController.clear(); // Clear the search field
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SearchMode>>[
              const PopupMenuItem<SearchMode>(
                value: SearchMode.byTitle,
                child: Text('Search by Title'),
              ),
              const PopupMenuItem<SearchMode>(
                value: SearchMode.byActor,
                child: Text('Search by Actor Name'),
              ),
              const PopupMenuItem<SearchMode>(
                value: SearchMode.byTwoActors,
                child: Text('Search by Two Actor Names'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () async {
              // Await the result from the SearchHistoryScreen
              final selectedQuery = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchHistoryScreen()), // Adjust for your actual SearchHistoryScreen widget
              );
              // Use the selected query to update the search field and perform a search
              if (selectedQuery != null) {
                _searchController.text = selectedQuery;
                _onSearchTextChanged();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter search query...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Text('No results found'),
      );
    } else {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
        ),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          var item = _searchResults[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailScreen(item)), // Adjust for your actual DetailScreen widget
              );
            },
            child: Card(
              elevation: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: item['poster_path'] != null
                        ? Image.network(
                            'https://image.tmdb.org/t/p/w500${item['poster_path']}',
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey,
                            child: Icon(Icons.movie, size: 50),
                            alignment: Alignment.center,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] ?? item['name'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rating: ${item['vote_average'].toString()}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
