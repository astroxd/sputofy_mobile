import 'dart:io';
import 'package:youtube_explode_dart/youtube_explode_dart.dart'
    as youtubeExplode;
import 'package:flutter/material.dart';
import 'package:sputofy_2/theme/palette.dart';
import 'package:rxdart/rxdart.dart';

List<String> downloadSongs = [];
int initiaDownloadSongslLength = 0;
final _downloadStream = BehaviorSubject<int>();
Stream<int> get downloadStream => _downloadStream.stream;

showDownloadSongDialog(
    BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return DownloadSong(scaffoldKey);
    },
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24.0),
        topRight: Radius.circular(24.0),
      ),
    ),
  );
}

class DownloadSong extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  const DownloadSong(this._scaffoldKey, {Key? key}) : super(key: key);

  @override
  _DownloadSongState createState() => _DownloadSongState();
}

class _DownloadSongState extends State<DownloadSong> {
  GlobalKey<ScaffoldState> get scaffoldKey => widget._scaffoldKey;

  var textController = TextEditingController(text: '');
  bool isValid = true;
  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
          top: 16.0, left: 16.0, right: 16.0, bottom: bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "Download Songs",
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: EdgeInsets.only(bottom: 0.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'https://youtu.be/VEe_yIbW64w',
                hintStyle: TextStyle(color: kPrimaryColor),
                errorText: isValid ? null : 'Link can\'t be empty',
              ),
              autofocus: true,
              controller: textController,
            ),
          ),
          SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              MaterialButton(
                color: kSecondaryColor,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              MaterialButton(
                onPressed: () async {
                  if (textController.text.isEmpty) {
                    setState(() {
                      isValid = false;
                    });
                  } else {
                    setState(() {
                      isValid = true;
                    });

                    _downloadHandler(
                        textController.text, scaffoldKey.currentContext!);
                    Navigator.pop(context);
                  }
                },
                child: Text("Download"),
                color: kAccentColor,
              ),
            ],
          )
        ],
      ),
    );
  }
}

_downloadHandler(String URL, BuildContext context) {
  if (URL.contains('playlist')) {
    _downloadPlaylist(URL, context);
  } else {
    _downloadSong(URL, context);
  }
}

_downloadPlaylist(String playlistURL, BuildContext context) async {
  var yt = youtubeExplode.YoutubeExplode();
  var playlist = await yt.playlists.get(playlistURL);
  String title = playlist.title;
  await for (var video in yt.playlists.getVideos(playlistURL)) {
    downloadSongs.add(video.id.toString());
  }
  downloadSongs = downloadSongs.reversed.toList();
  initiaDownloadSongslLength = downloadSongs.length;
  yt.close();
  _downloadSong(downloadSongs.last, context, playlistName: title);
}

_downloadSong(String videoURL, BuildContext context,
    {String? playlistName}) async {
  try {
    var yt = youtubeExplode.YoutubeExplode();
    String videoID = videoURL.split('/').last;

    //* Get video metadata
    var video = await yt.videos.get(videoID);
    String videoTitle = video.title
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '');

    //*Get video manifest
    var manifest = await yt.videos.streamsClient.getManifest(videoID);
    var streamInfo = manifest.audioOnly.withHighestBitrate();
    Stream<List<int>> stream = yt.videos.streamsClient.get(streamInfo);

    File file = File('/storage/emulated/0/Music/$videoTitle.mp3');

    // Delete the file if exists.
    if (file.existsSync()) {
      file.deleteSync();
    }
    var fileSizeInBytes = streamInfo.size.totalBytes;

    var output = file.openWrite(mode: FileMode.writeOnlyAppend);

    var count = 0;
    var percentage = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder(
          stream: downloadStream,
          initialData: 0,
          builder: (context, snapshot) {
            var value = snapshot.data ?? 0;

            return AlertDialog(
              title: playlistName != null
                  ? Text(
                      'Downloading...\n$playlistName ${initiaDownloadSongslLength - (downloadSongs.length - 1)}/$initiaDownloadSongslLength')
                  : Text('Downloading...'),
              content: value == -1
                  ? Text("Download Completed")
                  : Text("$videoTitle: $value%"),
            );
          },
        );
      },
    );

    await for (final data in stream) {
      count += data.length;
      output.add(data);
      print(count);
      percentage = ((count / fileSizeInBytes) * 100).ceil();
      _downloadStream.add(percentage);
    }
    Navigator.of(context, rootNavigator: true).pop('dialog');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$videoTitle downloaded"),
        behavior: SnackBarBehavior.floating,
        elevation: 0.0,
        action: SnackBarAction(
          label: 'HIDE',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
    _downloadStream.add(-1);
    await output.close().then((value) {
      if (downloadSongs.length > 0) {
        downloadSongs.removeLast();
      }
      if (downloadSongs.isNotEmpty) {
        _downloadSong(downloadSongs.last, context, playlistName: playlistName);
      }
    });
    yt.close();
  } catch (e) {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('Can\'t download song'),
          actions: [
            TextButton(
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop('dialog'),
                child: Text('OK'))
          ],
        );
      },
    );
    // .then((value) => Navigator.of(context, rootNavigator: true).pop('dialog'));
    print("ERROR IN DOWNLOAD $e");
    downloadSongs.clear();
  }
}
