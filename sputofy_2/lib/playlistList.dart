import 'package:flutter/material.dart';
import 'package:sputofy_2/playlistScreen.dart';

class PlaylistList extends StatefulWidget {
  @override
  _PlaylistListState createState() => _PlaylistListState();
}

class _PlaylistListState extends State<PlaylistList> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double paddingBottom = mediaQueryData.padding.bottom;
    return Scaffold(
      body: Container(
        width: widthScreen,
        child: Column(
          children: <Widget>[
            _buildWidgetButtonController(),
            _buildWidgetPlaylistList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetButtonController() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () => null,
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.shuffle,
                    size: 20.0,
                  ),
                  Text(
                    " Shuffle playback ",
                    style: Theme.of(context).textTheme.subtitle2.merge(
                          TextStyle(color: Colors.black),
                        ),
                  )
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 17.0, right: 16.0),
          child: GestureDetector(
            onTap: () => null,
            child: Icon(Icons.add),
          ),
        )
      ],
    );
  }

  Widget _buildWidgetPlaylistList() {
    return Expanded(
      child: GridView.count(
        padding: EdgeInsets.only(left: 20.0),
        crossAxisCount: 2,
        children: List.generate(
          5,
          (index) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistScreen(),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        width: 165.0,
                        height: 150.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("cover.jpeg"),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 115.0, right: 30.0),
                          child: GestureDetector(
                            onTap: () => print("play"),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueGrey[800],
                              ),
                              child: Icon(Icons.play_arrow,
                                  color: Colors.white, size: 32.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0, left: 10.0),
                        child: Text(
                          'Playlist',
                          style: Theme.of(context).textTheme.subtitle2.merge(
                                TextStyle(color: Colors.black, fontSize: 16.0),
                              ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => print("more vert"),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2.0, right: 21.0),
                          child: Icon(Icons.more_vert_outlined),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
