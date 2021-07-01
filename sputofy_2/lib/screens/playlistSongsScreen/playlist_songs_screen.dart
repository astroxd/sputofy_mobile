import 'package:flutter/material.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/services/database.dart';
import 'package:sputofy_2/theme/palette.dart';

class PlaylistSongsScreen extends StatefulWidget {
  final Playlist playlist;
  const PlaylistSongsScreen(this.playlist, {Key? key}) : super(key: key);

  @override
  _PlaylistSongsScreenState createState() => _PlaylistSongsScreenState();
}

class _PlaylistSongsScreenState extends State<PlaylistSongsScreen> {
  List<Song> songs = List.generate(
      20,
      (index) =>
          Song(index, "path", "title", "author", "cover", Duration.zero));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildWidgetPlaylistInfo(context, widget.playlist),
            _buildWidgetPlaylistList(context, songs),
          ],
        ),
      ),
    );
  }
}

class _buildWidgetPlaylistInfo extends StatelessWidget {
  final BuildContext context;
  final Playlist playlist;
  const _buildWidgetPlaylistInfo(this.context, this.playlist, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildWidgetTopBar(context),
        SizedBox(height: 16.0),
        _buildWidgetPlaylistDescription(context, playlist),
        Stack(
          alignment: AlignmentDirectional.centerEnd,
          children: [
            Divider(
              thickness: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 255, 83, 81),
                      Color.fromARGB(255, 231, 38, 113)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    // stops: [0.1, 0.9],
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    primary: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.all(16.0),
                  ),
                  child: Icon(Icons.shuffle),
                  onPressed: () => print("object"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Align(
                heightFactor: 2.5,
                alignment: Alignment.bottomLeft,
                child: Text(
                  "100 SONGS, 38 MIN",
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildWidgetTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          onPressed: () => print("ob"),
          icon: Icon(Icons.sort),
          color: kThirdColor,
        ),
        IconButton(onPressed: () => print("ob"), icon: Icon(Icons.more_vert)),
      ],
    );
  }

  Widget _buildWidgetPlaylistDescription(
      BuildContext context, Playlist playlist) {
    return Container(
      padding: const EdgeInsets.only(right: 16.0),
      height: 150,
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios),
            //Icon(Icons.chevron_left),
          ),
          Image.asset(
            'cover.jpeg',
            width: 150,
            height: 150,
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      playlist.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      "${playlist.creationDate.year.toString()}-${playlist.creationDate.month.toString().padLeft(2, '0')}-${playlist.creationDate.day.toString().padLeft(2, '0')}",
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 16.0),
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: kSecondaryBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.play_arrow,
                          size: 24.0,
                          color: kThirdColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: kSecondaryBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.add,
                          size: 24.0,
                          color: kThirdColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _buildWidgetPlaylistList extends StatelessWidget {
  final BuildContext context;
  final List<Song> songs;

  const _buildWidgetPlaylistList(this.context, this.songs, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16.0),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          Song song = songs[index];
          return InkWell(
            onTap: () {},
            // onTap: () async {
            //   if (playingItem?.album != '-2') {
            //     await loadQueue(songs, songPath: song.path);
            //   } else {
            //     await AudioService.skipToQueueItem(song.path);
            //     await AudioService.play();
            //   }
            // },
            child: Container(
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: kPrimaryColor))),
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    "${index + 1}",
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Text(
                      song.title,
                      style: Theme.of(context).textTheme.subtitle1!,
                      // .copyWith(
                      //     color: playingItem?.id == song.path
                      //         ? kAccentColor
                      //         : null),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _getSongDuration(song.duration),
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  _buildWidgetMenuButton(song),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getSongDuration(Duration? songDuration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    String twoDigitSeconds = twoDigits(songDuration!.inSeconds.remainder(60));
    return "${songDuration.inMinutes}:$twoDigitSeconds";
  }

  Widget _buildWidgetMenuButton(Song song) {
    return PopupMenuButton<List>(
      onSelected: _handleClick,
      icon: Icon(Icons.more_vert),
      padding: EdgeInsets.zero,
      itemBuilder: (context) {
        return {'Delete Song'}.map((String choice) {
          return PopupMenuItem<List>(
            value: [choice, song],
            child: Text(choice),
          );
        }).toList();
      },
    );
  }

  void _handleClick(List params) {
    //* params = [choice, song]
    switch (params[0]) {
      case 'Delete Song':
        // _deleteSong(params[1]);
        break;
    }
  }
}
