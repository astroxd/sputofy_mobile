import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/theme/palette.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({Key? key}) : super(key: key);

  @override
  _SongListScreenState createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _buildActionButtons(context),
            SizedBox(height: 16.0),
            _buildListSongs(context),
          ],
        ),
      ),
    );
  }
}

class _buildListSongs extends StatelessWidget {
  final BuildContext context;
  _buildListSongs(this.context);

  final List<Song> songs = List.generate(
      10,
      (index) => Song(index, "path", "title", "author", "cover",
          Duration(milliseconds: 300000)));

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        // separatorBuilder: (context, index) => Divider(
        //   indent: 16.0,
        // ),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          Song song = songs[index];
          return Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: kSecondaryColor))),
            margin: const EdgeInsets.only(left: 16.0),
            child: InkWell(
              onTap: () => print("object"),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            "${index + 1}",
                            style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    ?.fontSize,
                                color: kSecondaryColor),
                          ),
                          SizedBox(width: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                song.title,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              Text(_getSongDuration(song.duration),
                                  style: TextStyle(color: kSecondaryColor)),
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () => print("object"),
                            icon: Icon(Icons.favorite_border),
                            color: kSecondaryColor,
                          ),
                          IconButton(
                            onPressed: () => print("object"),
                            icon: Icon(Icons.more_horiz),
                            color: kSecondaryColor,
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 12.0),
                ],
              ),
            ),
          );
          // return ListTile(
          //   contentPadding: const EdgeInsets.only(left: 8.0, right: 0.0),
          //   minLeadingWidth: 4.0,
          //   leading: Text("$index"),
          //   title: Text(song.title),
          //   subtitle: Text(
          //     song.duration.toString(),
          //     style: TextStyle(color: kSecondaryColor),
          //   ),
          //   trailing: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: <Widget>[
          //       IconButton(
          //         onPressed: () => print("object"),
          //         icon: Icon(Icons.favorite_border),
          //         color: kSecondaryColor,
          //       ),
          //       IconButton(
          //         onPressed: () => print("object"),
          //         icon: Icon(Icons.more_horiz),
          //         color: kSecondaryColor,
          //       ),
          //     ],
          //   ),
          // );
        },
      ),
    );
  }

  String _getSongDuration(Duration songDuration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    String twoDigitSeconds = twoDigits(songDuration.inSeconds.remainder(60));
    return "${songDuration.inMinutes}:$twoDigitSeconds";
  }
}

class _buildActionButtons extends StatelessWidget {
  final BuildContext context;
  _buildActionButtons(this.context);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            onPressed: () => print("object"),
            icon: Icon(
              Icons.shuffle,
            ),
            iconSize: 32.0,
          ),
          IconButton(
            onPressed: () => print("object"),
            icon: Icon(
              Icons.repeat,
            ),
            iconSize: 32.0,
          ),
        ],
      ),
    );
  }
}
