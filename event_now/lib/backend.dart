import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Data> fetchData() async {
  final response = await http.get('http://ec2-3-19-243-124.us-east-2.compute.amazonaws.com:3001/getData');
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON.
    return Data.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load post');
  }
}

class Data {
  final List<Event> events;

  Data({this.events});

  factory Data.fromJson(List<dynamic> json) {
    List<Event> res = [];
    for (int i = 0; i < json.length; i++) {
      Map<String, dynamic> x = json[i];
      res.add(Event.fromJson(x));
    }
    return Data(events: res);
  }

  @override
  String toString() {
    return "Data: ${this.events.toString()}";
  }
}

class Event {
  final String name;
  final double lat;
  final double long;
  final DateTime startTime;
  final DateTime endTime;

  Event({this.name, this.lat, this.long, this.startTime, this.endTime});

  factory Event.fromJson(Map<String, dynamic> json) {
    double lat = json['lat'];
    double long = json['long'];
    return Event(
      name: json['name'],
      lat: lat,
      long: long,
      startTime: DateTime.fromMillisecondsSinceEpoch(json['start'], isUtc: true),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['end'], isUtc: true),
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Event ${this.name} at (${this.lat}, ${this.long}) time (${this.startTime}, ${this.endTime})";
  }
}

