import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

// Define the main function, which is the entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
// Define the MyApp widget, which is a stateless widget that builds the app's UI
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movies&More',
      // Set the app's dark theme
      theme: ThemeData.dark(),
      // Set the app's home page to an instance of the MyHomePage widget
      home: MyHomePage(title: 'Movies&More'),
    );
  }
}
// Define the MyHomePage widget, which is a stateful widget that defines the layout of the home page
class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
// Define the _MyHomePageState class, which extends the State class and defines the state of the MyHomePage widget
class _MyHomePageState extends State<MyHomePage> {
  // Define the instance variables that will hold the data fetched from the API
  List<Map<String, dynamic>> movies = [];
  List<Map<String, dynamic>> shows = [];
  Map<String, dynamic> show = {}; // define a variable named show
// Define a method that fetches the list of movies from the API
  Future<void> fetchMovies() async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/discover/movie?api_key=2e3a3937942a5214d0878f836907166a'));

    if (response.statusCode == 200) {
      // Set the state of the widget with the list of movies returned from the API
      setState(() {
        final Map<String, dynamic> data = json.decode(response.body);
        movies = List<Map<String, dynamic>>.from(data['results']);
      });
    } else {
      // Handle error
    }
  }

  Future<void> fetchTvShows() async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/discover/tv?api_key=2e3a3937942a5214d0878f836907166a'));

    if (response.statusCode == 200) {
      // Set the state of the widget with the list of TV shows returned from the API
      setState(() {
        final Map<String, dynamic> data = json.decode(response.body);
        shows = List<Map<String, dynamic>>.from(data['results']);
      });
    } else {
      // Handle error
    }
  }
  // This method is called when the state object is first created
  // It calls two methods to fetch movies and TV shows from an API
  @override
  void initState() {
    super.initState();
    fetchMovies();
    fetchTvShows();
  }
  // This method builds the UI for the widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The app bar displays the title of the widget
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // The bottom navigation bar displays a row of icons that the user can interact with
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                // Code to execute when the home button is pressed
              },
            ),
            //Watch list:
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WatchlistScreen(),
                  ),
                );
              },
            ),
            //Already watched:
            IconButton(
              icon: Icon(Icons.checklist),
              onPressed: () {},
            ),
            //Search:
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // The body of the widget displays a column of movies
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discover Movies',
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // The "See More" button navigates to a screen that displays all movies
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllMoviesScreen(movies: movies),
                        ),
                      );
                    },
                    child: Text(
                      'See More',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            // The second element in the column is a horizontal list of movie cards
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                // Set the maximum number of cards to 5 if there are more movies
                itemCount: movies.length > 5 ? 5 : movies.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MovieDetailsScreen(movie: movies[index]),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 120,
                      child: Card(
                        color: Colors.black,
                        child: Column(
                          children: [
                            // Display the movie poster image
                            Expanded(
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://image.tmdb.org/t/p/w500${movies[index]['poster_path']}',
                                width: 200,
                                // adjust the width of the image
                                height: 300,
                                // adjust the height of the image
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                            SizedBox(height: 5),
                            // Display the movie title
                            SizedBox(
                              height: 40,
                              // Display the "Discover TV Shows" text and "See More" button
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: 120 -
                                          2 * 8.0 -
                                          2 * 1.0, // 120 is the width of the picture
                                    ),
                                    child: Text(
                                      movies[index]['title'],
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discover TV Shows',
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllTvShowsScreen(shows: shows),
                        ),
                      );
                    },
                    child: Text(
                      'See More',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                // Displays a scrollable list of widgets.
                scrollDirection: Axis.horizontal,
                // Shows only five shows
                itemCount: shows.length > 5 ? 5 : shows.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TvShowDetailsScreen(show: shows[index]),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 120,
                      child: Card(
                        color: Colors.black,
                        child: Column(
                          children: [
                            Expanded(
                              //Load the poster image and cache it
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://image.tmdb.org/t/p/w500${shows[index]['poster_path']}',
                                width: 200,
                                height: 300,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                            SizedBox(height: 5),
                            SizedBox(
                              height: 40,
// adjust the height of the title container
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: 120 -
                                          2 * 8.0 -
                                          2 * 1.0, // 120 is the width of the picture
                                    ),
                                    child: Text(
                                      shows[index]['name'],
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AllMoviesScreen extends StatelessWidget {
  // Declare a list of movie maps that will be passed to the constructor
  final List<Map<String, dynamic>> movies;
  // Create a constructor that takes a Key object and the movies list as arguments
  const AllMoviesScreen({Key? key, required this.movies}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover Movies'),
      ),
      // Set the BottomAppBar widget to display a row of icons for navigating to different screens
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Add an IconButton that will pop the screen stack back to the home screen
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            // IconButton that will navigate to the WatchlistScreen
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WatchlistScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.checklist),
              onPressed: () {
                // Code to execute when the checklist button is pressed
              },
            ),
            // IconButton that will navigate to the SearchScreen
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // Set the body of the screen to a ListView widget that will display the movies
      body: ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          // Get the current movie map from the movies list using the index
          final movie = movies[index];
          return GestureDetector(
            onTap: () {
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailsScreen(movie: movie),
                  ),
                );
              } catch (e) {
                // Handle the error here
                print('Error navigating to movie details screen: $e');
              }
            },
            // Display the movie information
            child: Container(
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the movie poster and description in a row
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      movie['title'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Description:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                movie['overview'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.white,
                    thickness: 1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MovieDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> movie;

  const MovieDetailsScreen({Key? key, required this.movie}) : super(key: key);

  @override
  _MovieDetailsScreenState createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  // Map that stores details of a movie.
  Map<String, dynamic> _movieDetails = {};
  List<dynamic> _castAndCrew = [];

  @override
  void initState() {
    super.initState();
    // Calls the _fetchMovieDetails() method when the state is initialized.
    _fetchMovieDetails();
  }
// Fetches the details of a movie from the API.
  void _fetchMovieDetails() async {
    final response = await http.get(Uri.https(
      'api.themoviedb.org',
      '/3/movie/${widget.movie['id']}',
      {
        'api_key': '2e3a3937942a5214d0878f836907166a',
        'language': 'en-US',
        'append_to_response': 'credits',
      },
    ));
// If the API call is successful, the movie details
// are stored in _movieDetails and the cast and crew are stored in _castAndCrew.
    if (response.statusCode == 200) {
      setState(() {
        _movieDetails = jsonDecode(response.body);
        _castAndCrew =
            _movieDetails['credits']['cast'] + _movieDetails['credits']['crew'];
      });
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Details'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WatchlistScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.checklist),
              onPressed: () {
                // Code to execute when the checklist button is pressed
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              // Displays the backdrop image of the movie.
              child: CachedNetworkImage(
                imageUrl:
                    'https://image.tmdb.org/t/p/w500${widget.movie['backdrop_path']}',
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie['title'] ?? 'Title not available',
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  if (_movieDetails.containsKey('genres') &&
                      _movieDetails['genres'] != null &&
                      _movieDetails['genres'].isNotEmpty)
                    Text(
                      '${_movieDetails['genres'].map((genre) => genre['name']).join(', ')}',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 18),
                  SizedBox(width: 5),
                  Text(
                    widget.movie['vote_average'] != null
                        ? widget.movie['vote_average'].toString()
                        : '',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Description:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Visibility(
                visible: widget.movie['overview'] != null &&
                    widget.movie['overview'].isNotEmpty,
                child: Text(
                  widget.movie['overview'],
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '\nCast and Crew:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 120,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => SizedBox(width: 10),
                itemCount: _castAndCrew.length,
                itemBuilder: (BuildContext context, int index) {
                  final person = _castAndCrew[index];
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigates to the Person Details Screen when a person is tapped.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PersonDetailsScreen(person: person),
                            ),
                          );
                        },
                        child: Column(
                          // Displays the profile image of the person.
                          children: [
                            CircleAvatar(
                              backgroundImage: person['profile_path'] != null
                                  ? NetworkImage(
                                      'https://image.tmdb.org/t/p/w185${person['profile_path']}',
                                    )
                                  : null,
                              radius: 35,
                            ),
                            SizedBox(height: 5),
                            // Displays the name of the person.
                            Text(
                              person['name'],
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                            // Displays the role of the person.
                            SizedBox(height: 5),
                            Text(
                              person['character'] ?? person['job'],
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Movie card that displays the poster image and title of a movie
class MovieCard extends StatelessWidget {
  final Map<String, dynamic> movie;

  const MovieCard({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Navigates to the Movie Details Screen when the card is tapped.
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(movie: movie),
          ),
        );
      },
      child: Container(
        width: 120,
        height: 200,
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Displays the poster image of the movie.
              Expanded(
                child: CachedNetworkImage(
                  imageUrl:
                      'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                // Displays the title of the movie.
                child: Text(
                  movie['title'],
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Screen that displays a list of TV shows with their names, posters, and descriptions.
class AllTvShowsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> shows;

  const AllTvShowsScreen({Key? key, required this.shows}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover TV Shows'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WatchlistScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.checklist),
              onPressed: () {
                // Code to execute when the checklist button is pressed
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: shows.length,
        itemBuilder: (context, index) {
          final show = shows[index];
          return GestureDetector(
            onTap: () {
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TvShowDetailsScreen(show: show),
                  ),
                );
              } catch (e) {
                // Handle the error here
                print('Error navigating to movie details screen: $e');
              }
            },
            child: Container(
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Displays the name of the TV show.
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      show['name'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // Displays the poster image of the TV show.
                        Expanded(
                          flex: 1,
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://image.tmdb.org/t/p/w500${show['poster_path']}',
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                        SizedBox(width: 10),
                        // Displays the description of the TV show.
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Description:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                show['overview'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.white,
                    thickness: 1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TvShowDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> show;

  const TvShowDetailsScreen({Key? key, required this.show}) : super(key: key);

  @override
  _TvShowDetailsScreenState createState() => _TvShowDetailsScreenState();
}

class _TvShowDetailsScreenState extends State<TvShowDetailsScreen> {
  List<dynamic> _cast = [];

  @override
  void initState() {
    super.initState();
    //Fetch the cast and crew of the tv show
    fetchCredits(widget.show['id']).then((cast) {
      setState(() {
        _cast = cast;
      });
    });
  }

  Future<List<dynamic>> fetchCredits(int showId) async {
    //request for credits:
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/tv/$showId/credits?api_key=2e3a3937942a5214d0878f836907166a'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['cast'];
    } else {
      // Handle error
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TV Show Details'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WatchlistScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.checklist),
              onPressed: () {
                // Code to execute when the checklist button is pressed
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //show the picture:
          children: [
            Container(
              height: 300,
              child: CachedNetworkImage(
                imageUrl:
                    'https://image.tmdb.org/t/p/w500${widget.show['backdrop_path']}',
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            SizedBox(height: 10),
            //show the tv show  name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.show['name'],
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),
            //show rating
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 18),
                  SizedBox(width: 5),
                  Text(
                    widget.show['vote_average'].toString(),
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            //show description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Description:',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.show['overview'],
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '\nCast and Crew:',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 120,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => SizedBox(width: 10),
                itemCount: _cast.length,
                itemBuilder: (BuildContext context, int index) {
                  final person = _cast[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PersonDetailsScreen(person: person),
                        ),
                      );
                    },
                    //show the actor picture and details:
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: person['profile_path'] != null
                              ? NetworkImage(
                                  'https://image.tmdb.org/t/p/w185${person['profile_path']}',
                                )
                              : null,
                          radius: 35,
                        ),
                        SizedBox(height: 5),
                        Text(
                          person['name'],
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                        SizedBox(height: 5),
                        Text(
                          person['character'],
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}
class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  List<Map<String, dynamic>> results = [];
  String? _sortBy = 'Relevance';

  Future<void> fetchResults(String query) async {
    //fetch search results
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/search/multi?api_key=2e3a3937942a5214d0878f836907166a&query=$query'));

    if (response.statusCode == 200) {
      setState(() {
        final Map<String, dynamic> data = json.decode(response.body);
        results = List<Map<String, dynamic>>.from(data['results']);
        sortResults(_sortBy);
      });
    } else {
      // Handle error
    }
  }
  //function that controls sorting
  void sortResults(String? sortBy) {
    switch (sortBy) {
      case 'Title (A-Z)':
        results.sort((a, b) => (a['title'] ?? '').compareTo(b['title'] ?? ''));
        break;
      case 'Title (Z-A)':
        results.sort((a, b) => (b['title'] ?? '').compareTo(a['title'] ?? ''));
        break;
      case 'Release Date (Newest First)':
        results.sort((a, b) => (b['release_date'] ?? '').compareTo(a['release_date'] ?? ''));
        break;
      case 'Release Date (Oldest First)':
        results.sort((a, b) => (a['release_date'] ?? '').compareTo(b['release_date'] ?? ''));
        break;
      default:
      // Relevance
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search Movies, TV shows, or People',
            hintStyle: TextStyle(color: Colors.white),
          ),
          onChanged: (String? value) {
            setState(() {
              query = value ?? '';
            });
          },
          onSubmitted: (String? value) {
            fetchResults(query);
          },
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              showMenu<String>(
                context: context,
                position: RelativeRect.fromLTRB(1000.0, 50.0, 0.0, 0.0),
                //sorting options:
                items: <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'Relevance',
                    child: Text('Relevance'),
                  ),
                  PopupMenuItem<String>(
                    value: 'Title (A-Z)',
                    child: Text('Title (A-Z)'),
                  ),
                  PopupMenuItem<String>(
                    value: 'Title (Z-A)',
                    child: Text('Title (Z-A)'),
                  ),
                  PopupMenuItem<String>(
                    value: 'Release Date (Newest First)',
                    child: Text('Release Date (Newest First)'),
                  ),
                  PopupMenuItem<String>(
                    value: 'Release Date (Oldest First)',
                    child: Text('Release Date (Oldest First)'),
                  ),
                ],
              ).then((value) {
                if (value != null) {
                  setState(() {
                    _sortBy = value;
                    if (_sortBy == 'Relevance') {
                      // Always sort by relevance
                      results.sort((a, b) => (b['vote_average'] ?? 0.0).compareTo(a['vote_average'] ?? 0.0));
                    } else {
                      // Sort by the selected option
                      sortResults(_sortBy);
                    }
                  });
                }
              });
            },
          ),

        ],
      ),
      body: results.isEmpty
          ? Center(
        child: Text('Search for movies, TV shows, or people'),
      )
          : ListView.builder(
        itemCount: results.length,
        itemBuilder: (BuildContext context, int index) {
          final result = results[index];
          String title = '';
          String subtitle = '';
          switch (result['media_type']) {
            case 'movie':
              title = result['title'] ?? '';
              subtitle = result['release_date'] ?? '';
              break;
            case 'tv':
              title = result['name'] ?? '';
              subtitle = result['first_air_date'] ?? '';
              break;
            case 'person':
              title = result['name'] ?? '';
              subtitle = 'Person';
              break;
          }

          final imageUrl = result['poster_path'] != null
              ? 'https://image.tmdb.org/t/p/w92${result['poster_path']}'
              : 'https://via.placeholder.com/92x138?text=No+Image';

          return ListTile(
            leading: Image.network(imageUrl),
            title: Text(title),
            subtitle: Text(subtitle),
          );
        },
      ),
    );
  }
}





    class PersonDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> person;
  final List<dynamic>? knownFor;

  const PersonDetailsScreen({
    Key? key,
    required this.person,
    this.knownFor,
  }) : super(key: key);

  @override
  _PersonDetailsScreenState createState() => _PersonDetailsScreenState();
}

class _PersonDetailsScreenState extends State<PersonDetailsScreen> {
  List<dynamic> _knownFor = [];

  @override
  void initState() {
    super.initState();
    _initKnownFor();
  }

  Future<void> _initKnownFor() async {
    if (widget.knownFor != null) {
      setState(() {
        _knownFor = widget.knownFor!;
      });
      return;
    }

    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/person/${widget.person['id']}/combined_credits?api_key=2e3a3937942a5214d0878f836907166a'));

    if (response.statusCode == 200) {
      setState(() {
        final Map<String, dynamic> data = json.decode(response.body);
        _knownFor = List<Map<String, dynamic>>.from(data['cast']) +
            List<Map<String, dynamic>>.from(data['crew']);
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person['name']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.person['profile_path'] != null)
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: widget.person['profile_path'] != null
                        ? DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(
                              'https://image.tmdb.org/t/p/w500${widget.person['profile_path']}',
                            ),
                          )
                        : null,
                  ),
                  child: widget.person['profile_path'] == null
                      ? Icon(Icons.person, size: 200)
                      : null,
                ),
              SizedBox(height: 16),
              Text(
                'Biography',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                widget.person['biography'] ?? 'No information available',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Known For',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (_knownFor.isNotEmpty)
                SizedBox(
                  height: 210,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (context, index) => SizedBox(width: 8),
                    itemCount: _knownFor.length,
                    itemBuilder: (BuildContext context, int index) {
                      final media = _knownFor[index];
                      String title = '';
                      String subtitle = '';
                      switch (media['media_type']) {
                        case 'movie':
                          title = media['title'];
                          subtitle = media['release_date'];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MovieDetailsScreen(movie: media),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                        media['poster_path'] != null
                                            ? 'https://image.tmdb.org/t/p/w500${media['poster_path']}'
                                            : 'https://via.placeholder.com/150x225?text=No+Poster',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                SizedBox(
                                  height: 40,
                                  width: 100,
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        case 'tv':
                          title = media['name'];
                          subtitle = media['first_air_date'];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TvShowDetailsScreen(show: media),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                        media['poster_path'] != null
                                            ? 'https://image.tmdb.org/t/p/w500${media['poster_path']}'
                                            : 'https://via.placeholder.com/150x225?text=No+Poster',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                SizedBox(
                                  height: 40,
                                  width: 100,
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        default:
                          return SizedBox.shrink();
                      }
                    },
                  ),
                ),
              if (_knownFor.isEmpty)
                Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WatchlistScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.checklist),
              onPressed: () {
                // Code to execute when the checklist button is pressed
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).maybePop();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchScreen(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  String _deviceIdentifier = '';
  List<Map<String, dynamic>> _watchlist = [];
  DatabaseReference? _watchlistRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _initDeviceIdentifier();
    initPlatformState();

    _watchlist = []; // Initialize _watchlist here
    _readWatchlist();
  }

  //this does not work as expected:
  Future<void> _readWatchlist() async {
    print(_watchlistRef?.path);
    DatabaseEvent? event = await _watchlistRef?.once();
    print(event?.snapshot.value);
  }

  String _udid = 'Unknown';

  Future<void> initPlatformState() async {
    String udid;
    try {
      udid = await FlutterUdid.udid;
      print(udid);
    } on PlatformException {
      udid = 'Failed to get UDID.';
      print(udid);
    }

    if (!mounted) return;

    setState(() {
      _udid = udid;
    });
  }

  Future<void> _initDeviceIdentifier() async {
    final deviceIdentifier = await FlutterUdid.udid;
    setState(() {
      _deviceIdentifier = deviceIdentifier;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watchlist'),
      ),
      body: _watchlist.isNotEmpty
          ? ListView.builder(
              itemCount: _watchlist.length,
              itemBuilder: (BuildContext context, int index) {
                final media = _watchlist[index];
                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 75,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          media['poster_path'] != null
                              ? 'https://image.tmdb.org/t/p/w500${media['poster_path']}'
                              : 'https://via.placeholder.com/150x225?text=No+Poster',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(
                    media['title'] ?? media['name'] ?? 'No title available',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    media['release_date'] ??
                        media['first_air_date'] ??
                        'No date available',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
// TODO: Remove the selected media from the device's watchlist
                    },
                  ),
                  onTap: () {
// TODO: Navigate to the details screen for the selected media
                  },
                );
              },
            )
          : Center(
              child: Text('No movies or TV shows in your watchlist.'),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
// TODO: Implement media search and add functionality
        },
      ),
    );
  }
}
