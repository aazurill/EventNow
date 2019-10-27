import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'backend.dart';
import 'searchbar.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'EventNow',
        theme: ThemeData(
          primaryColor: Colors.pink[300],
          accentColor: Colors.greenAccent[200],
        ),
        home: MapWidget());
  }
}

class MapWidget extends StatefulWidget {
  @override
  MapWidgetState createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  Completer<GoogleMapController> _controller = Completer();
  StreamSubscription<Position> _streamSubscription;
  Position _currentPosition;

  GoogleMap googleMap;

  Future<Data> data;
  Set<Marker> markers = Set();

  static final CameraPosition _kUCSD = CameraPosition(
    target: LatLng(32.8801, -117.2340),
    zoom: 15.0,
  );

  @override
  void initState() {
    super.initState();
    const LocationOptions locationOptions =
    LocationOptions(accuracy: LocationAccuracy.best, distanceFilter: 10);
    final Stream<Position> positionStream =
    Geolocator().getPositionStream(locationOptions);
    _streamSubscription = positionStream.listen(
            (Position position) => setState(() { if (mounted) { _currentPosition = position; }}));
    data = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    googleMap = GoogleMap(
      mapType: MapType.hybrid,
      initialCameraPosition: _kUCSD,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      markers: markers,
      onMapCreated: (GoogleMapController controller) {
        if (!_controller.isCompleted) {
          _controller.complete(controller);
        }
      },
    );

    Widget searchBar = SearchBar(
      hint: "Search events, locations",
      refreshCallback: () {
        setState(() {
          data = fetchData();
        });
      },
    );

    return FutureBuilder(
      future: data,
      builder: (BuildContext context, AsyncSnapshot<Data> snapshot) {
        List<Widget> stack = <Widget>[
          googleMap,
          searchBar,
        ];

        Widget main = Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: _moveToCurrentPosition,
            child: Icon(Icons.my_location),
          ),
          drawer: Drawer(
            // Add a ListView to the drawer. This ensures the user can scroll
            // through the options in the drawer if there isn't enough vertical
            // space to fit everything.
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Text('Anonymous user'),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                ListTile(
                  title: Text('Item 1'),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Item 2'),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          body: Stack(children: stack),
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint("We waitin boys");
          stack.insert(2, SafeArea(
            child: Align(
              alignment: FractionalOffset(0.5, 0.125),
              child: Container(
                width: 50,
                height: 50,
                child: RefreshProgressIndicator()
                )
              )
            ));
        } else if (snapshot.hasError) {
          debugPrint('Error: ${snapshot.error}');
        } else {
          debugPrint('${(snapshot.data.events.toString())}');
          Set<Marker> res = Set();
          for (int i = 0; i < snapshot.data.events.length; i++) {
            Event e = snapshot.data.events[i];
            String markerId = 'marker_id_$i';
            res.add(Marker(
              markerId: MarkerId(markerId),
              position: LatLng(e.lat, e.long),
              onTap: () { _onMarkerTapped(i); }
            ));
          }
          markers = res;
        }

        return main;
      },
    );
  }

  _onMarkerTapped(int ix) {
    // TODO: Implement
  }

  Future<void> _moveToCurrentPosition() async {
    final GoogleMapController controller = await _controller.future;
    if (_currentPosition == null) {
      final snackbar = SnackBar(content: Text("Couldn't get current location"));
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(snackbar);
    } else {
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          zoom: 16.0,
          target:
          LatLng(_currentPosition.latitude, _currentPosition.longitude))));
    }
  }
}
