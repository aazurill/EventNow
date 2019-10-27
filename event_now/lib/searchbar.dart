import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef StringCallback = void Function(String);

class SearchBar extends StatefulWidget implements PreferredSizeWidget {
  final double kToolbarHeight = 72;
  final String hint;
  final VoidCallback refreshCallback;
  final StringCallback submittedCallback;

  const SearchBar({Key key, @required this.hint, this.refreshCallback, this.submittedCallback}) : super(key: key);

  @override
  SearchBarState createState() => SearchBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class SearchBarState extends State<SearchBar> {
  TextEditingController tfController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: widget.kToolbarHeight,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Card(
            child: Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                  Container(
                    width: 12.0,
                  ),
                  Expanded(
                    child: TextField(
                      controller: tfController,
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: widget.hint,
                      ),
                      onSubmitted: widget.submittedCallback,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                    ),
                    onPressed: widget.refreshCallback,
                  ),
                ],
              )
            )
          )
        ),
      ),
    );
  }
}
