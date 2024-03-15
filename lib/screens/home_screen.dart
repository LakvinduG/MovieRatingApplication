import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oneflix/api/api_service.dart';
import 'detail_screen.dart'; // Adjust if your structure is different
import 'search_screen.dart'; // Adjust if your structure is different
import 'package:oneflix/profile_screen.dart'; // Ensure this is correctly pointing to your ProfileScreen

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
        if (nextPage >= _pageController.positions.length) {
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
          height: isNowPlaying ? 200 : 300,
          child: FutureBuilder<List<dynamic>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else if (snapshot.hasData) {
                return isNowPlaying ? _buildNowPlayingSection(snapshot.data) : _buildOtherSections(snapshot.data);
              } else {
                return Text("No data");
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNowPlayingSection(List<dynamic>? data) {
    return PageView.builder(
      controller: _pageController,
      itemCount: data!.length,
      itemBuilder: (context, index) {
        var movie = data[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(movie)));
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtherSections(List<dynamic>? data) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: data!.length,
      itemBuilder: (context, index) {
        var item = data[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(item)));
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
                      'https://image.tmdb.org/t/p/w500${item['poster_path']}',
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

  void _showBottomDrawer() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(Icons.account_circle, size: 36),
                title: Text('Profile', style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                },
              ),
              // Additional drawer items can be added here
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('oneflix'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: _showBottomDrawer,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection("Now Playing", _apiService.fetchMoviesNowPlaying(), isNowPlaying: true),
            const SizedBox(height: 50),
            _buildSection("TV On Air Tonight", _apiService.fetchTvOnAirTonight()),
            const SizedBox(height: 50),
            _buildSection("Best Movies This Year", _apiService.fetchBestMoviesOfYear()),
            const SizedBox(height: 50),
            _buildSection("Highest Grossing Movies", _apiService.fetchHighestGrossingMoviesOfAllTime()),
          ],
        ),
      ),
    );
  }
}
