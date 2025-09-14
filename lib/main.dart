import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart' as cs;

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const OtakuinApp());
}

class OtakuinApp extends StatelessWidget {
  const OtakuinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otakuin',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF212121),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF212121),
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Anime>> futureAnime;
  late Future<List<TopAnime>> futureTopAnime;

  @override
  void initState() {
    super.initState();
    futureAnime = fetchAnime();
    futureTopAnime = fetchTopAnime();
  }

  Future<List<TopAnime>> fetchTopAnime() async {
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null) {
      throw Exception('API key not found');
    }

    try {
      final response = await http.get(
        Uri.parse('http://myapi.ldtp.com/api/top10'),
        headers: {'x-api-key': apiKey},
      );

      if (response.statusCode == 200) {
        final List<dynamic> animeJson = json.decode(response.body);
        return animeJson.map((json) => TopAnime.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load top anime');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load top anime');
    }
  }

  Future<List<Anime>> fetchAnime() async {
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null) {
      throw Exception('API key not found');
    }

    try {
      final response = await http.get(
        Uri.parse('http://myapi.ldtp.com/api/home'),
        headers: {'x-api-key': apiKey},
      );

      if (response.statusCode == 200) {
        final List<dynamic> animeJson = json.decode(response.body);
        return animeJson.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load anime');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load anime');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Otakuin'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<TopAnime>>(
              future: futureTopAnime,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return cs.CarouselSlider(
                    options: cs.CarouselOptions(
                      height: 200,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.8,
                    ),
                    items: snapshot.data!.map((topAnime) {
                      return TopAnimeCard(topAnime: topAnime);
                    }).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('${snapshot.error}'),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari Anime Di Sini',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'New Update Anime',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FutureBuilder<List<Anime>>(
              future: futureAnime,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final anime = snapshot.data![index];
                      return AnimeCard(anime: anime);
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('${snapshot.error}'),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch_later),
            label: 'Clock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF212121),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class TopAnimeCard extends StatelessWidget {
  final TopAnime topAnime;

  const TopAnimeCard({super.key, required this.topAnime});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Image.network(
              topAnime.thumbnail,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Text(
                '#${topAnime.rank}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(2.0, 2.0),
                    ),
                  ]
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topAnime.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimeCard extends StatelessWidget {
  final Anime anime;

  const AnimeCard({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Image.network(
                  anime.thumbnail,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (anime.rating / 10).toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    'Eps ${anime.last_episode ?? 0}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: Text(
            anime.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

//

class Anime {
  final int id;
  final String title;
  final String thumbnail;
  final int rating;
  final int? last_episode;
  final int? views;

  const Anime({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.rating,
    this.last_episode,
    this.views,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'] ?? 0,
      title: json['title'],
      thumbnail: json['thumbnail'],
      rating: json['rating'] ?? 0,
      last_episode: json['last_episode'],
      views: json['views'],
    );
  }
}

class TopAnime {
  final int id;
  final String title;
  final String thumbnail;
  final int rating;
  final int rank;

  const TopAnime({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.rating,
    required this.rank,
  });

  factory TopAnime.fromJson(Map<String, dynamic> json) {
    return TopAnime(
      id: json['id'] ?? 0,
      title: json['title'],
      thumbnail: json['thumbnail'],
      rating: json['rating'] ?? 0,
      rank: json['rank'] ?? 0,
    );
  }
}
