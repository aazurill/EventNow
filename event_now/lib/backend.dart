import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future<Data> fetchData() async {
  final response = await http.get('http://ec2-3-19-243-124.us-east-2.compute.amazonaws.com:8080/getEvent');
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
  final int clubId;
  final String club;
  final String description;
  final List<String> tags;
  final double lat;
  final double long;
  final DateTime startTime;
  final DateTime endTime;

  Event({this.name, this.clubId, this.club, this.description, this.tags, this.lat, this.long, this.startTime, this.endTime});

  factory Event.fromJson(Map<String, dynamic> json) {
    double lat = double.parse(json['lat']);
    double long = double.parse(json['long']);
    return Event(
      name: json['name'],
      clubId: json['ClubID'],
      club: json["group"],
      description: json['description'],
      tags: json['tags'],
      lat: lat,
      long: long,
      startTime: DateTime.fromMillisecondsSinceEpoch(json['start']),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['end']),
    );
  }

  String prettifyTime(DateTime cur) {
    DateFormat df = DateFormat("EEE, MMM d hh:mm aaa");
    if (this.startTime.compareTo(cur) < 0) {
      return df.format(this.startTime);
    } else {
      return "Ends at ${df.format(this.endTime)}";
    }
  }

  bool tagsContain(String query) {
    for (int i = 0; i < this.tags.length; i++) {
      if (this.tags[i].contains(query)) {
        return true;
      }
    }
    return false;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Event ${this.name} at (${this.lat}, ${this.long}) time (${this.startTime}, ${this.endTime})";
  }
}

