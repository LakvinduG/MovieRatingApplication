import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final dynamic movie;

  DetailScreen(this.movie);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie['title'] ?? movie['name']), //Display Movie Tittle
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w500${movie['poster_path']}', //Fetch and Display movie poster
                  fit: BoxFit.cover,
                  width: 200, 
                ),
              ),
            ),
            SizedBox(height: 16),
            
            Text(
              'Overview:', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              movie['overview'] ?? 'No overview available', //Display overview or deafault message
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Release Date: ${movie['release_date'] ?? movie['first_air_date'] ?? 'Unknown'}', //Display release date or deafault message
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Rating: ${movie['vote_average'] ?? 'N/A'}', //Display movie rating or default message
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Language: ${movie['original_language'] ?? 'N/A'}', //Display movie langauge or deafault message
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
