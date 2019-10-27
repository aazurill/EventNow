import 'package:flutter/material.dart';

import 'backend.dart';

class ClubWidget extends StatefulWidget {

  final EventData ed;
  final ClubData cd;
  final Club c;

  ClubWidget({Key key, this.c, this.ed, this.cd}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ClubWidgetState();
}

class ClubWidgetState extends State<ClubWidget> {

  List<Event> es;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.es = widget.ed.events.where((e) => e.clubId == widget.c.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.c.name),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: EdgeInsets.only(left: 72.0, top: 24.0, right: 8.0),
                child: Text(
                  "DESCRIPTION",
                  style: TextStyle(
                    fontSize: 10.0,
                    letterSpacing: 1.2,
                    color: Colors.grey,
                  )
                )
              ),
              Padding(
                padding: EdgeInsets.only(left: 72.0, top: 8.0, right: 8.0, bottom: 12.0),
                child: Text(
                  "This is a test of some text that I need to type dasdasldkjsafls slkjda lksjdal sd",
                  style: TextStyle(
                    fontSize: 22.0,
                    letterSpacing: 0.3,
                  )
                )
              ),
              Divider(),
              Padding(
                  padding: EdgeInsets.only(left: 72.0, top: 12.0, right: 8.0),
                  child: Text(
                      "EVENTS",
                      style: TextStyle(
                        fontSize: 10.0,
                        letterSpacing: 1.2,
                        color: Colors.grey,
                      )
                  )
              ),
              Padding(
                  padding: EdgeInsets.only(left: 72.0, top: 12.0, right: 8.0, bottom: 4.0),
                  child: Text(
                    "${this.es.length} upcoming event(s)",
                    style: TextStyle(
                      fontSize: 18.0,
                      letterSpacing: 0.5,
                    )
                  )
              ),
            ]..addAll(es.map((e) => Padding(
                padding: EdgeInsets.only(left: 52.0, top: 4.0, right: 8.0),
                child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(e.name, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500)),
                          Container(height: 4.0),
                          Text(e.prettifyTime(now), style: TextStyle(color: Colors.grey)),
                          Container(height: 8.0),
                          Text(e.description),
                        ],
                      ),
                    )
                )
            )))),
          )
        ],
      )
    );
  }
}