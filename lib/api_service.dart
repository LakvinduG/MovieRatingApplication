import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _apiKey = "74a04cff3446ea957a4dcc1957334a3b";
  final String _baseUrl = "https://api.themoviedb.org/3/";

  Future<List<dynamic>> fetchMoviesNowPlaying() async {
    final response = await http.get(Uri.parse('${_baseUrl}movie/now_playing?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to load now playing movies');
    }
  }

  Future<List<dynamic>> fetchTvOnAirTonight() async {
    final response = await http.get(Uri.parse('${_baseUrl}tv/airing_today?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to load TV airing today');
    }
  }

  Future<List<dynamic>> fetchBestMoviesOfYear() async {
    final year = DateTime.now().year;
    final response = await http.get(Uri.parse('${_baseUrl}discover/movie?api_key=$_apiKey&sort_by=vote_average.desc&primary_release_year=$year'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to load best movies of the year');
    }
  }

  Future<List<dynamic>> fetchHighestGrossingMoviesOfAllTime() async {
    final response = await http.get(Uri.parse('${_baseUrl}discover/movie?api_key=$_apiKey&sort_by=revenue.desc'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to load highest-grossing movies of all time');
    }
  }

  Future<List<dynamic>> searchMovies(String query) async {
    final response = await http.get(Uri.parse('${_baseUrl}search/movie?api_key=$_apiKey&query=$query'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to search movies');
    }
  }

  Future<List<dynamic>> searchTvShows(String query) async {
    final response = await http.get(Uri.parse('${_baseUrl}search/tv?api_key=$_apiKey&query=$query'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to search TV shows');
    }
  }
}
