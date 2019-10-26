import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget implements PreferredSizeWidget {
  final double kToolbarHeight = 160;

  const SearchBar({Key key, @required String hint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2.0,
      borderRadius: BorderRadius.circular(4.0),
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Container(
            color: Colors.red,
            padding: EdgeInsets.all(5),
            child: Row(children: [
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.verified_user),
                onPressed: () => null,
              ),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
