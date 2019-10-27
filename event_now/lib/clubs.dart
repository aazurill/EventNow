import 'package:flutter/material.dart';

import 'backend.dart';

class ClubWidget extends StatelessWidget {

  final EventData ed;
  final ClubData cd;
  final Club c;

  ClubWidget({Key key, this.c, this.ed, this.cd}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(c.name),
            ),
          ),
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Yeet"),
                  Text("YEET!!!")
                ],
              ),
            )
          )
        ],
      )
    );
  }
}