import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;Future<http.Response> fetchPost() {
  return http.get('XXXXXXXPLACEWEBSITEXXXXXXXX');
}

Future<Event> fetchEvent() async {
  final response =
  await http.get('https://jsonplaceholder.typicode.com/posts/1');

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON.
    return Event.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load post');
  }
}
class Data {
  List<Event> events = new List<Event>();
}

class Event {
  final String name;
  final int lat;
  final int long;
  final int startTime;
  final int endTime;

  Event({this.name, this.lat, this.long, this.startTime, this.endTime});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'],
      lat: json['lat'],
      long: json['long'],
      startTime: json['start'],
      endTime: json['end'],
    );
  }
}

