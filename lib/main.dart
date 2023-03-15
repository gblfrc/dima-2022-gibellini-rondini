import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _curScreen = 0;
  var screens = [HomePage(), SearchPage(), FriendsPage()];

  void _incrementCounter() { // TODO: This can be removed, it is not used anymore
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      //appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        //title: Text(widget.title),
      //),
      body: screens[_curScreen], // The actual body of the Scaffold depends on the currently selected tab in bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _curScreen,
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        unselectedItemColor: Theme.of(context).colorScheme.onPrimary.withOpacity(.6),
        selectedFontSize: 14,
        unselectedFontSize: 14,
        onTap: (value) {
          setState(() => {_curScreen = value}); // The current screen is changed
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Search',
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            label: 'Friends',
            icon: Icon(Icons.people),
          ),
          BottomNavigationBarItem(
            label: 'Account',
            icon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home page"),
      ),
      body: ListView(
        children: <Widget>[
          // const Text(
          //   'You have pushed the button this many times:',
          // ),
          // Text(
          //   '$_counter',
          //   style: Theme.of(context).textTheme.headlineMedium,
          // ),
          // ElevatedButton(
          //     onPressed: _incrementCounter,
          //     child: const Text("Increment")
          // ),
          ListTile(
            // Widget that allows to insert a title and (optionally) a sub-title
            title: Text("Latest sessions"),
          ),
          Card(
            child: InkWell(
              // This widget creates a feedback animation when the user taps on the card
              onTap: () => print("Card tap"),
              // TODO: The callback should show details about the session
              child: Column(
                children: [
                  FractionallySizedBox(widthFactor: 1),
                  // The box should take the entire width of the screen
                  ListTile(
                    title: Text("Session of Mar 14, 2023"),
                    subtitle: Text("Private"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text("1 h 23 min"),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.route,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text("5.98 km"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: InkWell(
              onTap: () => print("Card tap"),
              child: Column(
                children: [
                  FractionallySizedBox(widthFactor: 1),
                  ListTile(
                    title: Text("Session of Mar 15, 2023"),
                    subtitle: Text("Private"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text("0 h 49 min"),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.route,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text("4.20 km"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text("My goals"),
          ),
          Card(
            child: InkWell(
              onTap: () => print("Card tap"),
              child: Column(
                children: [
                  FractionallySizedBox(widthFactor: 1),
                  ListTile(
                    title: Text("Run for at least 20 km"),
                    subtitle: Text("In progress"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(
                      value: 10.18 / 20,
                      backgroundColor: Theme.of(context).focusColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // TODO: Change onPressed callback: this is not doing anything at the moment
        onPressed: _incrementCounter,
        tooltip: 'New session',
        child: const Icon(Icons.directions_run),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SearchPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Center( // TODO: Return Scaffold with AppBar (title + tabs) and Body (and not directly the body itself)
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Welcome to the search page!',
          ),
        ],
      ),
    );
  }
}

class FriendsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Friends"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Trainings"),
              Tab(text: "Friend list"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              children: [
                Card(
                  child: InkWell(
                    onTap: () => print("Card tap"),
                    child: Column(
                      children: [
                        FractionallySizedBox(widthFactor: 1),
                        ListTile(
                          title: Text("Proposed session at Parco Suardi"),
                          subtitle: Text("Shared with friends"),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  Text("Mar 21, 2023 16:30"),
                                ],
                              ),
                              ElevatedButton(
                                  onPressed: () => print("Pressed"),
                                  child: Text("Join training"),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: ListView(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(10)),
                  ListTile(
                    leading: Icon(Icons.account_circle, size: 60),
                    title: Text("Luca Rondini"),
                    onTap: () => print("Ciao"),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.account_circle, size: 60),
                    title: Text("Federico Gibellini"),
                    onTap: () => print("Ciao"),
                  ),
                  Divider(),
                  const Center(
                      child: Text(
                          "Use the Search section to find friends to add."))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
