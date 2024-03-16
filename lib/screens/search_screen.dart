import 'package:flutter/material.dart';
import 'package:oneflix/api/api_service.dart';
import 'detail_screen.dart'; 
import 'search_history_screen.dart'; 
import 'package:shared_preferences/shared_preferences.dart';


enum SearchMode { byTitle, byActor, byTwoActors }


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

  // Load the last search query from shared preferences
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

  // Save the search query to shared preferences
  Future<void> _saveSearchQuery(String query) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('searchHistory') ?? [];
    if (!history.contains(query)) {
      history.add(query);
      await prefs.setStringList('searchHistory', history);
    }
    await prefs.setString('lastSearch', query);
  }

  // Called when the search text is changed
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

  // Perform the movie search
  void _searchMovies(String query) async {
    setState(() {
      _searchResults.clear();
    });

    try {
      List<dynamic> results = await _apiService.searchMovies(query); 

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
          // Popup menu for selecting search mode
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

          // Button for opening search history screen
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () async {
              // Await the result from the SearchHistoryScreen
              final selectedQuery = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchHistoryScreen()), 
              );
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
          // Search text field
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
  // Build the search results widget
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
                MaterialPageRoute(builder: (context) => DetailScreen(item)), 
              );
            },
            child: Card(
              elevation: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie poster or placeholder
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

                  // Movie title and rating
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
