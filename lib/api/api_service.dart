import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _apiKey = "74a04cff3446ea957a4dcc1957334a3b";
  final String _baseUrl = "https://api.themoviedb.org/3/";

  Future<List<dynamic>> fetchMoviesNowPlaying() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/now_playing?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to load now playing movies');
    }
  }

  Future<List<dynamic>> fetchTvOnAirTonight() async {
    final response = await http.get(Uri.parse('$_baseUrl/tv/airing_today?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to load TV airing today');
    }
  }

  Future<List<dynamic>> fetchBestMoviesOfYear() async {
    final year = DateTime.now().year;
    final response = await http.get(Uri.parse('$_baseUrl/discover/movie?api_key=$_apiKey&sort_by=vote_average.desc&primary_release_year=$year'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to load best movies of the year');
    }
  }

  Future<List<dynamic>> fetchHighestGrossingMoviesOfAllTime() async {
    final response = await http.get(Uri.parse('$_baseUrl/discover/movie?api_key=$_apiKey&sort_by=revenue.desc'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to load highest-grossing movies of all time');
    }
  }

  Future<List<dynamic>> searchMovies(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$query'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to search movies');
    }
  }

  Future<List<dynamic>> searchTvShows(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/search/tv?api_key=$_apiKey&query=$query'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to search TV shows');
    }
  }

  Future<List<dynamic>> searchPerson(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/search/person?api_key=$_apiKey&query=$query'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to search person');
    }
  }

  Future<List<dynamic>> getMoviesByPersonId(int personId) async {
    final response = await http.get(Uri.parse('$_baseUrl/person/$personId/movie_credits?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      List<dynamic> combinedResults = [];
      if (responseBody.containsKey('cast')) {
        combinedResults.addAll(responseBody['cast']);
      }
      if (responseBody.containsKey('crew')) {
        combinedResults.addAll(responseBody['crew']);
      }
      return combinedResults;
    } else {
      throw Exception('Failed to load movies by person ID');
    }
  }

  // Newly added method to find movies with both actors
  Future<List<dynamic>> getMoviesByBothActors(String actorName1, String actorName2) async {
    try {
      // Step 1: Search for both actors and get their IDs
      var searchResults1 = await searchPerson(actorName1);
      var searchResults2 = await searchPerson(actorName2);

      if (searchResults1.isEmpty || searchResults2.isEmpty) {
        return [];
      }

      int actorId1 = searchResults1.first['id'];
      int actorId2 = searchResults2.first['id'];

      // Step 2: Fetch movies for each actor
      List<dynamic> actor1Movies = await getMoviesByPersonId(actorId1);
      List<dynamic> actor2Movies = await getMoviesByPersonId(actorId2);

      // Step 3: Find intersection of movies
      var actor1MovieIds = actor1Movies.map((movie) => movie['id']).toSet();
      var commonMovies = actor2Movies.where((movie) => actor1MovieIds.contains(movie['id'])).toList();

      return commonMovies;
    } catch (e) {
      throw Exception('Failed to find common movies: $e');
    }
  }
}
