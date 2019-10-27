import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'searchbar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'EventNow',
        theme: ThemeData(
          primaryColor: Colors.pink[300],
          accentColor: Colors.greenAccent[200],
        ),
        home: Home());
  }
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        body: Stack(
          children: <Widget>[
            MapWidget(),
            SearchBar(hint: "Search events, locations"),
          ],
        ));
  }
}

class MapWidget extends StatefulWidget {
  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kUCSD = CameraPosition(
    target: LatLng(32.8801, -117.2340),
    zoom: 15.0,
  );

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> key = GlobalKey();

    return new Scaffold(
      key: key,
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kUCSD,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _moveToCurrentPosition(key),
        child: Icon(Icons.my_location),
      ),
    );
  }

  Future<void> _moveToCurrentPosition(GlobalKey<ScaffoldState> key) async {
    final GoogleMapController controller = await _controller.future;
    Position p = await Geolocator().getCurrentPosition();
    if (p == null) {
      final snackbar = SnackBar(content: Text("Couldn't get current location"));
      key.currentState.showSnackBar(snackbar);
    } else {
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          zoom: 16.0,
          target:
              LatLng(p.latitude, p.longitude))));
    }
  }
}

