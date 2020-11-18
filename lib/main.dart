import 'package:flutter/material.dart';

void main() {
  runApp(BooksApp());
}
//Navigator 2.0

/*
1.Page: Navigator 에 쌓여질 변하지 않는객체 화면을 보여주는 객체라 생각해도 좋을것 같다.
2.Router: 상태가 변경될 때 마다 감지하여 RouterDelegate 에게 알려줘 새로운 페이지를 교체 하도록 도와준다.
3.RouterInformationParser 앱의 경로를 변환하여 RouterDelegate 에 새로운 경로를 업데이트 해준다.
4.BackButtonDispatcher 앱의 뒤로가기 버튼이 눌릴때 RouterDelegate 에게 전달하여 작동하게 한다. (Navigator.OnPopPage)
*/

/*
class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

class BooksApp extends StatefulWidget {
  @override
  _BooksAppState createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  Book _selectedBook;

  List<Book> books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Books App',
      home: Navigator(
        //MaterialPage 후에 안에서 MaterialPageRoute 사용 Screen 이동
        //변수가 변경될 때 마다 이곳에서 다시 이동하는
        pages: [
          MaterialPage(
            key: ValueKey('BooksListPage'),
            child: BooksListPage(
              books: books,
              onTapped: _handleBookTapped,
            ),
          ),
          if (_selectedBook != null) BookDetailsPage(book: _selectedBook)
        ],
        //Popup 되었을 때
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }
          // Update the list of pages by setting _selectedBook to null
          setState(() {
            _selectedBook = null;
          });

          return true;
        },
      ),
    );
  }

  void _handleBookTapped(Book book) {
    setState(() {
      _selectedBook = book;
    });
  }
}

class BookDetailsPage extends Page {
  final Book book;

  BookDetailsPage({
    this.book,
  }) : super(key: ValueKey(book));

  //요구되는 함수, BookDetailPage 함수가 호출되면 createRoute 호출
  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return BookDetailsScreen(book: book);
      },
    );
  }

}

class BooksListPage extends StatelessWidget {
  final List<Book> books;
  final ValueChanged<Book> onTapped;

  BooksListPage({
    @required this.books,
    @required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          for (var book in books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () => onTapped(book),
            )
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  BookDetailsScreen({@required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book != null) ...[
              Text(
                book.title,
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                book.author,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
*/

/*
class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

class BooksApp extends StatefulWidget {
  @override
  _BooksAppState createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  BookRouterDelegate _routerDelegate = BookRouterDelegate();
  BookRouteInformationParser _routeInformationParser =
      BookRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _routeInformationParser,
      routerDelegate: _routerDelegate,
      title: 'Books App',
    );
  }
}

class BookRouteInformationParser extends RouteInformationParser<BookRoutePath> {
  //routeInformation 을 받아서 BookRoutePath 반환
  //처음 앱이 로드될때 parseRouteInformation 호출되어 routeInformation 을 이용해 path 를 지정
  @override
  Future<BookRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);
    // Handle '/'
    if (uri.pathSegments.length == 0) {
      return BookRoutePath.home();
    }
    // Handle '/book/:id'
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] != 'book') {
        return BookRoutePath.unknown();
      }
      var remaining = uri.pathSegments[1];
      var id = int.tryParse(remaining);
      if (id == null) {
        return BookRoutePath.unknown();
      }
      return BookRoutePath.details(id);
    }

    return BookRoutePath.unknown();
  }

  //BookRoutePath 받아서 RouteInformation 반환 
  //RouterDelegate 에서 최근 Path 를 가져올 때 
  @override
  RouteInformation restoreRouteInformation(BookRoutePath path) {
    if (path.isUnknown) {
      return RouteInformation(location: '/404');
    }
    if (path.isHomePage) {
      return RouteInformation(location: '/');
    }
    if (path.isDetailsPage) {
      return RouteInformation(location: '/book/${path.id}');
    }
    return null;
  }
}


class BookRouterDelegate extends RouterDelegate<BookRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BookRoutePath> {
  
  final GlobalKey<NavigatorState> navigatorKey;

  Book _selectedBook;
  bool show404 = false;

  List<Book> books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  BookRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        //1.BookListPage -> BookListScreen
        MaterialPage(
          key: ValueKey('BooksListPage'),
          child: BooksListScreen(
            books: books,
            onTapped: _handleBookTapped,
          ),
        ),
        //show404 가 true 라면 UnknownPage -> UnknownScreen, false 라면, UnknownScreen
        if (show404)
          MaterialPage(key: ValueKey('UnknownPage'), child: UnknownScreen())
        else if (_selectedBook != null)
          //MaterialPageRoute 는 BookDetailsPage 에서 한다.
          BookDetailsPage(book: _selectedBook)
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        //뒤로 이동 했다면 _selectedBook=null, show404=false 
        _selectedBook = null;
        show404 = false;
        //변화 됐다고 알려줌
        notifyListeners();
        return true;
      },
    );
  }

  //최근의 BookRoutePath 를 가져온다.
  @override
  BookRoutePath get currentConfiguration {
    if (show404) {
      return BookRoutePath.unknown();
    }

    return _selectedBook == null
        ? BookRoutePath.home()
        : BookRoutePath.details(books.indexOf(_selectedBook));
  }

  //RoutePath 가 재지정 될 때 마다 호출
  @override
  Future<void> setNewRoutePath(BookRoutePath path) async {
    if (path.isUnknown) {
      _selectedBook = null;
      show404 = true;
      return;
    }

    if (path.isDetailsPage) {
      if (path.id < 0 || path.id > books.length - 1) {
        show404 = true;
        return;
      }

      _selectedBook = books[path.id];
    } else {
      _selectedBook = null;
    }

    show404 = false;
  }

  void _handleBookTapped(Book book) {
    _selectedBook = book;
    notifyListeners();
  }
}

class BookDetailsPage extends Page {
  final Book book;

  BookDetailsPage({
    this.book,
  }) : super(key: ValueKey(book));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return BookDetailsScreen(book: book);
      },
    );
  }
}

class BookRoutePath {
  final int id;
  final bool isUnknown;

  BookRoutePath.home()
      : id = null,
        isUnknown = false;

  BookRoutePath.details(this.id) : isUnknown = false;

  BookRoutePath.unknown()
      : id = null,
        isUnknown = true;

  bool get isHomePage => id == null;
  bool get isDetailsPage => id != null;
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  BookDetailsScreen({
    @required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book != null) ...[
              Text(book.title, style: Theme.of(context).textTheme.headline6),
              Text(book.author, style: Theme.of(context).textTheme.subtitle1),
            ],
          ],
        ),
      ),
    );
  }
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;
  final ValueChanged<Book> onTapped;

  BooksListScreen({
    @required this.books,
    @required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          for (var book in books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () => onTapped(book),
            )
        ],
      ),
    );
  }
}

class UnknownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('404!'),
      ),
    );
  }
}

*/

//Navigator 1.0
/*
이름지어진 Route 를 관리하는 발전된 방법으로는 onGenerateRoute 를 사용하는 방법이 있다.
onGenerateRoute 는 모든 경로를 관리 할 수 있게 해준다.
Navigator.pushNamed 가 발생하면 onGenerateRoute 가 호출되고 settigs 값에서 경로에 대한 정보를 가져와
Route 와 page 를 만든다.
*/

/*
1.1 간단한 Navigator 의 개념
Navigator: Route 를 관리하는 Widget
Route: Navigator 에 의해 관리되며, screen 을 이동시키는, MaterialPageRoute 를 사용
HomScreen 에서 DetailScreen 으로 push 로 넘어가면 HomeScreen 위에 DetailScreen 이 Stack 과 같이 쌓이는 것
*/

/*
class Nav2App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FlatButton(
          child: Text("View Dtails"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return DetailScreen();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FlatButton(
          child: Text('Pop!'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
*/

/*
1.2.Route 는 Navigator 에 의헤 관리되며 Page 를 이동하는 역할을 하는 것을 앞에 배웠다.
Route 는 이름을 지정하여 관리 할 수 있다. 사용하려면 꼭 MaterialApp 에서 Route 의 이름을 미리 선언 해 주어야 한다.
*/

/*
class Nav2App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => HomeScreen(),
        '/details': (context) => DetailScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FlatButton(
          child: Text("View Dtails"),
          onPressed: () {
            Navigator.pushNamed(context, '/details');
          },
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FlatButton(
          child: Text('Pop!'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
*/

//1.3. onGenerateRoute 를 이용해 좀 더 상세하게 naming 된 Screen 으로 이동 할 수 있다.
/*
class Nav2App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        //setting 의 name 속성에 경로가 저장되고 그것으로 route 와 screen 을 만든다.
        // Handle '/'
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => HomeScreen());
        }

        // Handle '/details/:id'
        var uri = Uri.parse(settings.name);
        //uri pathSegments[0] = details uri pathSegments[1] = 1
        if (uri.pathSegments.length == 2 &&
            uri.pathSegments.first == 'details') {
          //settings 에서 받아온 경로 id 로 page 제작
          var id = uri.pathSegments[1];
          return MaterialPageRoute(builder: (context) => DetailScreen(id: id));
        }

        return MaterialPageRoute(builder: (context) => UnknownScreen());
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FlatButton(
          child: Text("View Dtails"),
          onPressed: () {
            Navigator.pushNamed(context, '/details/1');
          },
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  String id;

  DetailScreen({this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FlatButton(
          child: Text('Pop!'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class UnknownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('404!'),
      ),
    );
  }
}
*/

