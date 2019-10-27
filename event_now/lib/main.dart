import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
  Data dataFin;
  Set<Marker> markers = Set();
  Set<Marker> filteredMarkers = Set();

  GlobalKey<ScaffoldState> _sk = GlobalKey();
  GlobalKey<SearchBarState> _sb = GlobalKey();

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
    _streamSubscription =
        positionStream.listen((Position position) => setState(() {
              if (mounted) {
                _currentPosition = position;
              }
            }));
    setState(() {
      data = fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    googleMap = GoogleMap(
      mapType: MapType.hybrid,
      initialCameraPosition: _kUCSD,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      markers: filteredMarkers,
      onMapCreated: (GoogleMapController controller) {
        if (!_controller.isCompleted) {
          _controller.complete(controller);
        }
      },
    );

    Widget searchBar = SearchBar(
      key: _sb,
      hint: "Search events, locations",
      refreshCallback: () {
        if (_sb.currentState != null) {
          _sb.currentState.tfController.clear();
        }
        setState(() {
          data = fetchData();
        });
      },
      submittedCallback: (value) {
        Set<Marker> fm = Set();
        if (dataFin != null) {
          for (int i = 0; i < dataFin.events.length; i++) {
            Event e = dataFin.events[i];
            if (e.name.contains(value) || e.tagsContain(value)) {
              fm.add(
                Marker(
                  markerId: MarkerId(e.name),
                  position: LatLng(e.lat, e.long),
                  consumeTapEvents: true,
                  onTap: () {
                    _onMarkerTapped(context, e);
                  }));
            }
          }
        }

        setState(() {
          filteredMarkers = fm;
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
          key: _sk,
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
          stack.insert(
              2,
              SafeArea(
                  child: Align(
                      alignment: FractionalOffset(0.5, 0.125),
                      child: Container(
                          width: 50,
                          height: 50,
                          child: RefreshProgressIndicator()))));
        } else if (snapshot.hasError) {
          debugPrint('Error: ${snapshot.error}');
        } else {
          Future<BitmapDescriptor> icon;
        
          Set<Marker> res = Set();
          dataFin = snapshot.data;
          for (int i = 0; i < snapshot.data.events.length; i++) {
            Event e = snapshot.data.events[i];
            String markerId = e.name;
            if( e.tags.contains('sports')) {
               icon = BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size.square(0.1)), 'assets/sport.png');
            }
            else if( e.tags.contains('party')) {
               icon = BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size.square(0.1)), 'assets/party.png');
            }
            else if( e.tags.contains('learning')) {
               icon = BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size.square(0.1)), 'assets/learn.png');
            }
            else {
               icon = Future.value(BitmapDescriptor.defaultMarker);
            }
            DateTime now = DateTime.now();
            if (now.compareTo(e.endTime) < 0) {
              icon.then((icon) {
                res.add(Marker(
                    markerId: MarkerId(markerId),
                    position: LatLng(e.lat, e.long),
                    consumeTapEvents: true,
                    icon: icon,
                    onTap: () {
                      _onMarkerTapped(context, e);
                    }));
              });
            }
          }
          markers = res;
          filteredMarkers = res;
        }

        return main;
      },
    );
  }

  _onMarkerTapped(BuildContext context, Event e) {
    TextTheme tt = Theme.of(context).textTheme;
    _sk.currentState.showBottomSheet((context) {
      return FutureBuilder(
        future: Geolocator().placemarkFromCoordinates(e.lat, e.long),
        builder: (BuildContext context, AsyncSnapshot<List<Placemark>> snapshot) {
          String pos;

          if (snapshot.connectionState == ConnectionState.waiting) {
            pos = "(${e.lat}, ${e.long})";
          } else if (snapshot.hasError || snapshot.data == null || snapshot.data.isEmpty) {
            pos = "(${e.lat}, ${e.long})";
          } else {
            Placemark posM = snapshot.data[0];
            if (posM.thoroughfare.isEmpty) {
              pos = "(${e.lat}, ${e.long}); ${posM.locality} ${posM.postalCode}";
            } else {
              pos = "${posM.thoroughfare}, ${posM.locality} ${posM.postalCode}";
            }
          }

          return ConstrainedBox(
            constraints: new BoxConstraints(
              minHeight: 0,
              maxHeight: 350,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(e.name, style: TextStyle(fontSize: 24.0)),
                  Container(height: 4),
                  InputChip(
                      label: Text(e.club),
                      onPressed: () {}
                  ),
                  Container(height: 20),
                  Row(
                    children: <Widget>[
                      Icon(Icons.location_on),
                      Container(width: 20),
                      Text(pos, style: TextStyle(
                          fontSize: 16.0, letterSpacing: 0.3)),
                    ],
                  ),
                  Container(height: 16),
                  Row(
                    children: <Widget>[
                      Icon(Icons.timer),
                      Container(width: 20),
                      Text(e.prettifyTime(DateTime.now()), style: TextStyle(
                          fontSize: 16.0, letterSpacing: 0.3)),
                    ],
                  ),
                  Container(height: 16),
                  Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                          child: Text(e.description)
                      )
                  ),
                  Container(height: 16),
                  Row(
                    children: <Widget>[
                      InkWell(child: FloatingActionButton.extended(
                          onPressed: () async {
                            String url = 'https://www.google.com/maps/search/?api=1&query=${e.lat},${e.long}';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              _sk.currentState.showSnackBar(
                                SnackBar(content: Text("Couldn't open directions!"))
                              );
                            }
                          },
                          elevation: 0,
                          hoverElevation: 1,
                          highlightElevation: 1,
                          label: Text("Directions",
                              style: TextStyle(fontSize: 12.0))))
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );

    });
  }

  Future<void> _moveToCurrentPosition() async {
    final GoogleMapController controller = await _controller.future;
    if (_currentPosition == null) {
      _sk.currentState.hideCurrentSnackBar();
      final snackbar = SnackBar(content: Text("Couldn't get current location"));
      _sk.currentState.showSnackBar(snackbar);
    } else {
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          zoom: 16.0,
          target:
              LatLng(_currentPosition.latitude, _currentPosition.longitude))));
    }
  }
}
