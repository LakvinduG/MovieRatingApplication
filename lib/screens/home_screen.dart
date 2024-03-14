import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oneflix/api/api_service.dart';
import 'detail_screen.dart'; 
import 'search_screen.dart'; 


class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  PageController _pageController = PageController(viewportFraction: 0.8);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _pageController.page!.toInt() + 1;
        if (nextPage == _pageController.positions.length) {
          nextPage = 0; // Go back to the first item if reached the end
        }
        _pageController.animateToPage(
          nextPage,
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Widget _buildSection(String title, Future<List<dynamic>> future, {bool isNowPlaying = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: isNowPlaying ? 200 : 300, // Adjust height based on the section
          child: FutureBuilder<List<dynamic>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else if (snapshot.hasData) {
                if (isNowPlaying) {
                  // Landscape images for Now Playing section
                  return GestureDetector(
                    onTap: () {
                      // Navigate to detail screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetailScreen(snapshot.data![_pageController.page!.toInt()])),
                      );
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var movie = snapshot.data![index];
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  movie['backdrop_path'] != null
                                    ? 'https://image.tmdb.org/t/p/w500${movie['backdrop_path']}'
                                    : '', // Custom image URL
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie['title'] ?? movie['name'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Rating: ${movie['vote_average'].toString()}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  // Vertical list for other sections
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var item = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DetailScreen(item)),
                          );
                        },
                        child: Container(
                          width: 180,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    item['poster_path'] != null
                                      ? 'https://image.tmdb.org/t/p/w500${item['poster_path']}'
                                      : 'assets/imgerror.jpg', // Custom image URL
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Text(item['title'] ?? item['name'], overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16)),
                              Text('Rating: ${item['vote_average'].toString()}', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              } else {
                return Text("No data");
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('oneflix'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Navigate to search screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSection("Now Playing", _apiService.fetchMoviesNowPlaying(), isNowPlaying: true),
            _buildSection("TV On Air Tonight", _apiService.fetchTvOnAirTonight()),
            _buildSection("Best Movies This Year", _apiService.fetchBestMoviesOfYear()),
            _buildSection("Highest Grossing Movies", _apiService.fetchHighestGrossingMoviesOfAllTime()),
          ],
        ),
      ),
    );
  }
}
