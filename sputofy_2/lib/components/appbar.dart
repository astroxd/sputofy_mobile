import 'package:flutter/material.dart';

AppBar appBar() {
  return AppBar(
    title: Text("Sputofy"),
    actions: <Widget>[
      IconButton(onPressed: () => print(""), icon: Icon(Icons.search)),
      IconButton(onPressed: () => print(""), icon: Icon(Icons.more_vert)),
      // InkWell(
      //   onTap: () => print(""),
      //   child: Icon(Icons.more_vert),
      // )
    ],
    bottom: TabBar(
      tabs: [
        Tab(
          text: "Songs",
        ),
        Tab(
          text: "Playlist",
        )
      ],
    ),
  );
}
