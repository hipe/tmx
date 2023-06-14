import 'package:stm/app.dart';
import 'package:stm/counter_observer.dart';
import 'common_ui.dart' as cui;
import 'replication.dart';
import 'database.dart' show AppDatabase;
import 'model.dart';
import 'routes/list_skilltrees.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  Bloc.observer = const CounterObserver();
  runApp(const CounterApp());
}

void _ASIDE_ORIG_main() {
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
  var history = <WordPair>[];

  GlobalKey? historyListKey;

  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      removeFavorite(pair);
    } else {
      _addFavoriteAndNotify(pair);
    }
  }

  void _addFavoriteAndNotify(WordPair pair) {
    // NOTE name this function to accord with `removeFavorite` IFF you publicize
    _createLike(this, pair);
    favorites.add(pair);
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    _deleteLike(this, pair);
    favorites.remove(pair);
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
    var colorScheme = Theme.of(context).colorScheme;

    // (one handler for nav clicks, regardless of which layout (widget) we use)
    final onNavClick = (offset) {
      this.setState(() {
        this.selectedIndex = offset;
      });
    };

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool narrowNotWide = cui.narrowNotWide(constraints);
          Widget page = _buildPage(selectedIndex, constraints);
          Widget mainArea = _wrapAsMainArea(page, colorScheme);
          final args = [
            mainArea,
            if (! narrowNotWide) constraints,
            this.selectedIndex,
            onNavClick,
          ];
          final func = narrowNotWide ? _whenScreenIsNarrow : _whenScreenIsWide;
          return Function.apply(func, args);
        },
      ),  // body:: LayoutBuilder
    );  // Scaffold
  }  // build()
}

Widget _buildPage(int selectedIndex, BoxConstraints bc) {
  if (1 == selectedIndex) return FavoritesPage();
  if (0 == selectedIndex) return GeneratorPage(bc);
  throw UnimplementedError('no widget for $selectedIndex');
}

/* END */

Widget _wrapAsMainArea(Widget page, ColorScheme colorScheme) {
  // the container for the current page, with its bg color & switching anim
  return ColoredBox(
    color: colorScheme.surfaceVariant,
    child: AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      child: page,
    ),
  );
}

Widget _whenScreenIsWide(mainArea, constraints, selectedIndex, onNavClick) {
  final navRail = NavigationRail(
    extended: constraints.maxWidth >= 600,
    destinations: [
      NavigationRailDestination(
        icon: Icon(Icons.home),
        label: Text('Home'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.favorite),
        label: Text('Favorites'),
      ),
    ],
    selectedIndex: selectedIndex,
    onDestinationSelected: (offset) => onNavClick(offset),  // hi
  );

  return Row(
    children:[
      SafeArea(child: navRail),
      Expanded(child: mainArea),
    ],  // children: []
  );  // Row
}

Widget _whenScreenIsNarrow(Widget mainArea, selectedIndex, onNavClick) {
  final bnb = BottomNavigationBar(
    items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.favorite),
        label: 'Favorites',
      ),
    ],
    currentIndex: selectedIndex,
    onTap: (offset) => onNavClick(offset),  // hi
  );
  return Column(children: [Expanded(child: mainArea), SafeArea(child: bnb)]);
}

class GeneratorPage extends StatelessWidget {

  final BoxConstraints _bc;

  GeneratorPage(this._bc);

  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    final buttons = [
      ElevatedButton.icon(
        label: Text('Like'),
        icon: Icon(icon),
        onPressed: () {
          print('LIKE pressed');
          appState.toggleFavorite();
        },
      ),
      ElevatedButton(
        child: Text('Next'),
        onPressed: () {
          print('NEXT pressed');
          appState.getNext();
        },
      ),
      ElevatedButton(
        child: Text("IMAGINE"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (ctxt) {
              return const RouteForListSkillTrees();
            }),
          );
        },
      ),
    ];

    final buttonsContainer = cui.layOutButtonsCommonly(buttons, _bc);

    // BEGIN #history-A.3 hack around layout

    int headFlex = 3;
    int tailFlex = 2;

    if (2 < buttons.length) {
      headFlex--;
      tailFlex--;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: headFlex, child: HistoryListView(),),
          SizedBox(height: 10),
          BigCard(pair: pair),
          SizedBox(height: 10),
          buttonsContainer,
          if (3 > buttons.length) Spacer(flex: tailFlex),
        ],
      ),  // Column
    );
    // END #history-A.3 hack around layout
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

    final List<Text> cx = [
      Text(
        pair.first,
        style: style.copyWith(fontWeight: FontWeight.w200),
      ),
      Text(
        pair.second,
        style: style.copyWith(fontWeight: FontWeight.bold),
      ),
    ];

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          child: MergeSemantics(child: Wrap(children: cx)),
            // wrap compound word correctly when window is narrow
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    if (favorites.isEmpty) {
      return Center(
        child: Text('No favroites yet.'),
      );
    }

    final List<ListTile> favs = [
      for (var pair in favorites)
        ListTile(
          leading: IconButton(
            icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
            color: theme.colorScheme.primary,
            onPressed: () {
              appState.removeFavorite(pair);
            },
          ),
          title: Text(
            pair.asLowerCase,
            semanticsLabel: pair.asPascalCase,
          ),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text('You have '
              '${favorites.length} favorites:'),
        ),
        Expanded(
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: cui.THIS_WIDTH,
              childAspectRatio: cui.THIS_WIDTH / cui.THIS_HEIGHT,
            ),
            children: favs,
          ),
        ),
      ],
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}): super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key = GlobalKey();

  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                icon: appState.favorites.contains(pair)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(),
                label: Text(
                  pair.asLowerCase,
                  semanticsLabel: pair.asPascalCase,
                ),
              ),
            ),  // Center
          );  // SizeTransition
        },  // itemBuilder
      ),  // AnimatedList
    );  // ShaderMask
  }
}

/* BEGIN [#892.E]
We're trying to call the async functions from the sync world and this is eew
*/

// WRITE

void _createLike(MyAppState mas, WordPair pair) {
  mas.local_database.then((db) => _doCreateLike(db, pair));
}

void _deleteLike(MyAppState mas, WordPair pair) {
  mas.local_database.then((db) => _doDeleteLike(db, pair));
}

void _doCreateLike(AppDatabase db, WordPair pair) {
  final Like like = Like(null, pair.first, pair.second);  /* #[#892.E] `.id` */
  db.likeDAO.createLike(like)
    .then((int i) => print("(local db: CREATEd Like #${i})"));
}

void _doDeleteLike(AppDatabase db, WordPair pair) {
  /* Buckle up: It's a totally reasonable convention of RDBMS that we use
  (integer) primary key ID's to indicate a specific row (e.g when DELETEing).

  Floor bakes this assumption in to it and that is okay and normal and good.

  Note, however, that the google example app (word pairs) does NOT have as
  "robust" a manifestation of identity for its business objects: The identity
  of a word pair _is_ the two strings. We see this in multiple places where
  it simply calls `List.remove`, and there is some "identity function" that
  determines what to remove.

  It's worth noting that this analysis unintentionally reveals a behavioral
  grey area if not a bug: the RNG could (hypothetically) generate a duplicate
  word pair. The behavior of this edge case is undefined, as far as we know.
  */

  print("(local db: TRACE: DELETEing ('${pair.first}', '${pair.second}')");
  db.likeDAO.findAllLikesWithThisNaturalKeyAsStream(pair.first, pair.second)
    .then((List<Like> founds) => _doDoDeleteLike(db, founds, pair));
}

void _doDoDeleteLike(AppDatabase db, List<Like> founds, WordPair pair) {

  List<Like> deleteTheseLikes = [];  // this feels redundant now but ..
  // .. once upon a time, vendor returned <Stream<List<Like>>

  for (final like in founds) {
    deleteTheseLikes.add(like);
  }

  final len = deleteTheseLikes.length;
  if (1 < len) {
    print("(local db: INTERESTING: ${len} likes with same words?)");
  }
  else if (0 == len) {
    print("(local db: WARNING: corrupted? No items found for '${pair}')");
  }
  else {
    print("(local db: DELETEing ${len} Like(s))");
  }
  for (final like in deleteTheseLikes) {
    db.likeDAO.deleteLike(like)
      .then((int? i) => print("(local db: info: DELETEd a Like (rc: ${i}))"));
    // #[#892.E] expected PK but had 1/0 probably
  }
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
    print("(local db: info: zero likes in local database)");
    return;
  }

  print("(local db: info: adding ${likes.length} like(s) from local db)");

  for (final like in likes) {
    final newPair = WordPair(like.word1, like.word2);  // #[#892.E] unserialize
    favs.add(newPair);
  }
}

// END

/*
#history-A.3: hack around our ignorance of layout
#history-A.2: fold-in UI & func from advanced version of example
#history-A.1: per codelab
*/
