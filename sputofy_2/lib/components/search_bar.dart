import 'dart:collection';
import 'package:flutter/material.dart';

import 'package:audio_service/audio_service.dart';

import 'package:provider/provider.dart';
import 'package:sputofy_2/providers/provider.dart';

import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/song_model.dart';

import 'package:sputofy_2/screens/playlistSongsScreen/playlist_songs_screen.dart';

import 'package:sputofy_2/theme/palette.dart';

import 'get_song_duration.dart';
import 'load_queue.dart';

class DataSearch extends SearchDelegate<String> {
  final BuildContext context;
  final int tabIndex;

  late final items;
  late HashMap<String, dynamic> hashItems;

  DataSearch(this.context, this.tabIndex) {
    if (tabIndex == 0) {
      items = Provider.of<DBProvider>(context, listen: false).songs;
      hashItems = HashMap.fromIterable(
        items,
        key: (song) => song.title,
        value: (song) => song,
      );
    } else {
      items = Provider.of<DBProvider>(context, listen: false).playlists;
      hashItems = HashMap.fromIterable(
        items,
        key: (playlist) => playlist.name,
        value: (playlist) => playlist,
      );
    }
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      colorScheme: ColorScheme(
        primary: kThirdColor,
        primaryVariant: kSecondAccentColor,
        secondary: kAccentColor,
        secondaryVariant: kSecondAccentColor,
        surface: kSecondaryBackgroundColor,
        background: kBackgroundColor,
        error: Colors.red,
        onPrimary: kThirdColor,
        onSecondary: kThirdColor,
        onSurface: kThirdColor,
        onBackground: kThirdColor,
        onError: Colors.black,
        brightness: Brightness.dark,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    //* Not used
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = hashItems.keys
        .where((element) => element.toLowerCase().contains(query))
        .toList();
    // final suggestionList = hashSongs.keys
    //     .map((e) => e.toLowerCase().allMatches(query).toString())
    //     .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        if (tabIndex == 0) {
          Song song = hashItems[suggestionList[index]]!;
          return ListTile(
            onTap: () {
              if (AudioService.currentMediaItem?.album != '-2') {
                loadQueue(-2, items, songPath: song.path);
              } else {
                AudioService.skipToQueueItem(song.path);
                AudioService.play();
              }
              close(context, suggestionList[index]);
            },
            title: RichText(
              text: TextSpan(
                text: suggestionList[index].substring(0, query.length),
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(color: kAccentColor),
                children: [
                  TextSpan(
                    text: suggestionList[index].substring(query.length),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              ),
            ),
            subtitle: Text(
              getSongDuration(song.duration),
              style: Theme.of(context).textTheme.subtitle2,
            ),
            trailing: Icon(
              Icons.play_arrow_outlined,
              color: kPrimaryColor,
            ),
          );
        } else {
          Playlist playlist = hashItems[suggestionList[index]];
          return ListTile(
            onTap: () {
              Provider.of<DBProvider>(context, listen: false)
                  .getPlaylist(playlist.id!);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistSongsScreen(playlist),
                ),
              );
            },
            title: Text(playlist.name),
          );
        }
      },
    );
  }
}
