import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sputofy_2/main.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/screens/SongDetailScreen/song_detail_screen.dart';
import 'package:sputofy_2/theme/palette.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({Key? key}) : super(key: key);
  Stream<CurrentPlayingMediaItem> get _playingMediaItemStream =>
      Rx.combineLatest3<MediaItem?, Duration, PlaybackState,
              CurrentPlayingMediaItem>(
          AudioService.currentMediaItemStream,
          AudioService.positionStream,
          AudioService.playbackStateStream,
          (mediaItem, position, playbackState) =>
              CurrentPlayingMediaItem(mediaItem, position, playbackState));

  @override
  Widget build(BuildContext context) {
    // void _handleClick(List params) async {
    //   //* params = [choice, mediaItem]
    //   MediaItem mediaItem = params[1];
    //   switch (params[0]) {
    //     case 'Delete Song':
    //       if (mediaItem.album == '-2') {
    //         Provider.of<DBProvider>(context, listen: false)
    //             .deleteSong(mediaItem.extras?['id']);
    //       } else {
    //         Provider.of<DBProvider>(context, listen: false).deletePlaylistSong(
    //             int.parse(mediaItem.album), mediaItem.extras?['id']);
    //         await AudioService.removeQueueItem(mediaItem);
    //       }
    //       break;
    //   }
    // }

    // Widget _buildWidgetMenuButton(MediaItem? mediaItem) {
    //   return PopupMenuButton<List>(
    //     onSelected: _handleClick,
    //     icon: Icon(Icons.more_vert),
    //     padding: EdgeInsets.zero,
    //     itemBuilder: (context) {
    //       return {'Delete Song'}.map((String choice) {
    //         return PopupMenuItem<List>(
    //           value: [choice, mediaItem],
    //           child: Row(
    //             mainAxisSize: MainAxisSize.min,
    //             children: <Widget>[
    //               Icon(Icons.delete),
    //               SizedBox(width: 2.0),
    //               Text(choice),
    //             ],
    //           ),
    //         );
    //       }).toList();
    //     },
    //   );
    // }

    return StreamBuilder<CurrentPlayingMediaItem>(
      stream: _playingMediaItemStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container(height: 0.0);

        final playingMediaItem = snapshot.data;
        MediaItem? playingItem = playingMediaItem?.playingItem;
        Duration? position = playingMediaItem?.position ?? Duration(seconds: 1);
        PlaybackState? playbackState = playingMediaItem?.playbackState;
        Duration duration = playingItem?.duration ?? Duration(seconds: 1);
        if (playingItem == null) return Container(height: 0.0);
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(_createRoute());
          },
          child: Container(
            color: kBackgroundColor.withOpacity(0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kAccentColor),
                  minHeight: 3.0,
                  backgroundColor: Colors.transparent,
                  value: position.inSeconds / duration.inSeconds,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: kSecondaryBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            playbackState?.playing ?? false
                                ? await AudioService.pause()
                                : await AudioService.play();
                          },
                          child: Icon(
                            playbackState?.playing ?? false
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 24.0,
                            color: kThirdColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              // playingItem?.title ?? 'Unknown Title',
                              playingItem.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(fontSize: 14.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              // playingItem?.artist ?? 'Unkwon Artist',
                              playingItem.artist ?? 'Unkwon Artist',
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ],
                        ),
                      ),
                      // _buildWidgetMenuButton(playingItem),
                      songMenuButton(
                        Song.fromMediaItem(playingItem),
                        context,
                        icon: Icons.more_vert,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CurrentPlayingMediaItem {
  MediaItem? playingItem;
  Duration? position;
  PlaybackState? playbackState;
  CurrentPlayingMediaItem(this.playingItem, this.position, this.playbackState);
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SongDetailScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
