import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/providers/provider.dart';

import 'components/playlist_tile.dart';

class PlaylistListScreen extends StatefulWidget {
  const PlaylistListScreen({Key? key}) : super(key: key);

  @override
  _PlaylistListScreenState createState() => _PlaylistListScreenState();
}

class _PlaylistListScreenState extends State<PlaylistListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DBProvider>(
        builder: (context, database, child) {
          List<Playlist> playlists = database.playlists;
          return Column(
            children: <Widget>[
              PlaylistList(context, playlists),
              SizedBox(height: 32.0),
            ],
          );
        },
      ),
    );
  }
}

class PlaylistList extends StatelessWidget {
  final BuildContext context;
  final List<Playlist> playlists;

  const PlaylistList(this.context, this.playlists, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          Playlist playlist = playlists[index];
          return PlaylistTile(playlist);
        },
      ),
    );
  }
}

// void handleClick(List params, BuildContext context) {
//   //* params = [choice, playlist]
//   switch (params[0]) {
//     case 'Delete Playlist':
//       if (params[1].id == 0) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text("Favorite playlist can't be deleted"),
//           action: SnackBarAction(
//               label: 'HIDE',
//               onPressed: () =>
//                   ScaffoldMessenger.of(context).hideCurrentSnackBar()),
//         ));
//       } else {
//         Provider.of<DBProvider>(context, listen: false)
//             .deletePlaylist(params[1].id);
//       }
//       break;
//   }
// }

// Widget PlaylistbuildWidgetMenuButton(Playlist playlist, BuildContext context) {
//   return PopupMenuButton<List>(
//     onSelected: (List params) => handleClick(params, context),
//     icon: Icon(Icons.more_vert),
//     padding: EdgeInsets.zero,
//     itemBuilder: (context) {
//       return {'Delete Playlist'}.map((String choice) {
//         return PopupMenuItem<List>(
//           value: [choice, playlist],
//           child: Text(choice),
//         );
//       }).toList();
//     },
//   );
// }
