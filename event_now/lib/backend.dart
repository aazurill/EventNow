import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ClubData {
  final List<Club> clubs;

  ClubData({this.clubs});

  factory ClubData.fromJson(List<dynamic> json) {
    List<Club> res = [];
    for (int i = 0; i < json.length; i++) {
      Map<String, dynamic> x = json[i];
      res.add(Club.fromJson(x));
    }
    return ClubData(clubs: res);
  }

  @override
  String toString() {
    return "Data: ${this.clubs.toString()}";
  }

  static Future<ClubData> fetchData() async {
    final response = await http.get('http://ec2-3-19-243-124.us-east-2.compute.amazonaws.com:8080/getClub');
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return ClubData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load clubs');
    }
  }

}

class Club {
  final int id;
  final String name;
  final String description;

  Club({this.id, this.name, this.description});

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      name: json['group'],
      id: json['ClubID'],
      description: json['Description'],
    );
  }


  @override
  String toString() {
    // TODO: implement toString
    return "Club ${this.name} [${this.id}] - ${this.description}";
  }
}

class EventData {
  final List<Event> events;

  EventData({this.events});

  factory EventData.fromJson(List<dynamic> json) {
    List<Event> res = [];
    for (int i = 0; i < json.length; i++) {
      Map<String, dynamic> x = json[i];
      res.add(Event.fromJson(x));
    }
    return EventData(events: res);
  }

  @override
  String toString() {
    return "Data: ${this.events.toString()}";
  }

  static Future<EventData> fetchData() async {
    final response = await http.get('http://ec2-3-19-243-124.us-east-2.compute.amazonaws.com:8080/getEvent');
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return EventData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load events');
    }
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
      description: json['Description'],
      tags: List<String>.from(json['Tags']),
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

