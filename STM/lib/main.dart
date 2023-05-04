import 'replication.dart';
import 'database.dart' show AppDatabase;
import 'model.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const color = Color.fromRGBO(0, 0, 25, 1.0);  // or Colors.deepOrange

    /* BEGIN #[#892.E] do this "right" when we learn how
    */
    final mas = MyAppState();
    _populateSavedFavoritesAsynchronously(mas);
    // END

    return ChangeNotifierProvider(
      create: (context) => mas,
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: color),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      print("(NOTICE: remove is not implemented on local db yet!)");
      favorites.remove(current);
    } else {
      _createLike(this, current);
      favorites.add(current);
    }
    notifyListeners();
  }

  late Future<AppDatabase> local_database = BUILD_THE_DATABASE();
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],  // destinations
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      print('changing state to $value');
                      selectedIndex = value;
                    });
                  },
                ),  // NavigationRail
              ),  // SafeArea
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),  // Container
              ),  // Expanded
            ],  // Children
          ),  // Row
        );  // Scaffold
      },  // builder
    );  // LayoutBuilder
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('A random idea?'),
          BigCard(pair: pair),
          SizedBox(height: 10),  // create space between
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  print('LIKE pressed');
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              ElevatedButton(
                onPressed: () {
                  print('NEXT pressed');
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],  // End of children
          ),  // Row
        ],
      ),  // Column
    );
  }
}

class FavoritesPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    if (favorites.isEmpty) {
      return Center(
        child: Text('No favroites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${favorites.length} favorites:'),
        ),
        for (var pair in favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}


class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: pair.asPascalCase,
        ),
      ), // Padding
    ); // Card
  }
}

/* BEGIN [#892.E]
We're trying to call the async functions from the sync world and this is eew
*/

// WRITE

void _createLike(MyAppState mas, WordPair pair) {
  mas.local_database
    .then((db) => _doCreateLike(db, pair));
}

void _doCreateLike(AppDatabase db, WordPair pair) {
  final Like like = Like(null, pair.first, pair.second);  /* #[#892.E] `.id` */
  db.likeDAO.createLike(like)
    .then((int i) => print("(WOW: amazing: added ID: " + i.toString() + ")"));
}

// READ

void _populateSavedFavoritesAsynchronously(MyAppState mas) {
  final List<WordPair> favorites = mas.favorites;
  mas.local_database
    .then((db) => _doPopulateSavedFavoritesAsynchronously(favorites, db));
}

void _doPopulateSavedFavoritesAsynchronously(List<WordPair> favs, AppDatabase db) {
  final likesCollection = db.likeDAO;
  likesCollection.findAllLikes()
    .then((likes) => _do2PopulateSavedFavoritesAsynchronously(favs, likes));
}

void _do2PopulateSavedFavoritesAsynchronously(List<WordPair> favs, List<Like> likes) {

  if (0 == likes.length) {
    print("(info: zero likes in local database)");
    return;
  }

  print("(info: adding " + likes.length.toString() + " like(s) from local db)");

  for (final like in likes) {
    final newPair = WordPair(like.word1, like.word2);  // #[#892.E] unserialize
    favs.add(newPair);
  }
}

// END

/*
#history-A.1: per codelab
*/
