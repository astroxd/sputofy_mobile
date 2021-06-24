import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/app_icons.dart';
import 'package:sputofy_2/provider/provider.dart';
import 'package:sputofy_2/utils/palette.dart';

class SongList extends StatefulWidget {
  @override
  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  @override
  Widget build(BuildContext context) {
    Provider.of<DBProvider>(context, listen: false).getSongs();

    return Scaffold(
      backgroundColor: mainColor,
      body: Column(
        children: <Widget>[
          _buildWidgetButtonController(context),
          SizedBox(height: 8.0),
          _buildWidgetSongList()
        ],
      ),
    );
  }

  Widget _buildWidgetButtonController(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                AppIcon.shuffle,
              ),
              SizedBox(width: 8.0),
              Icon(
                Icons.repeat,
                size: 28,
              )
            ],
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.arrow_downward,
                size: 28,
              ),
              SizedBox(width: 8.0),
              Icon(
                Icons.thumbs_up_down_sharp,
                size: 28,
              ),
              SizedBox(width: 8.0),
              GestureDetector(
                child: Icon(
                  Icons.create_new_folder_outlined,
                  size: 28,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWidgetSongList() {
    return Expanded(
      child: FutureBuilder(
        future: Provider.of<DBProvider>(context).songs,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
              separatorBuilder: (context, index) => Divider(
                color: Colors.black,
              ),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text("cacca"),
                        subtitle: Text("merda"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.favorite_border),
                            SizedBox(width: 16.0),
                            Icon(Icons.more_vert)
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  // Widget expandedContent(List<FileSystemEntity> folderContent) {
  //   return Consumer<MyAudio>(
  //     builder: (context, audioPlayer, child) => ListView.builder(
  //       shrinkWrap: true,
  //       itemCount: folderContent.length,
  //       itemBuilder: (context, index) {
  //         return GestureDetector(
  //           // onTap: () => audioPlayer.pathPlay(folderContent[index]),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(
  //                     horizontal: 16.0, vertical: 16.0),
  //                 child: Row(
  //                   children: <Widget>[
  //                     Expanded(
  //                       child: Text(
  //                         getFileName(folderContent[index]),
  //                         overflow: TextOverflow.ellipsis,
  //                         style: TextStyle(
  //                           color: accentColor,
  //                           fontSize: 18,
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(width: 16),
  //                     Row(
  //                       children: <Widget>[
  //                         Icon(
  //                           Icons.favorite_border_rounded,
  //                           size: 28,
  //                         ),
  //                         SizedBox(
  //                           width: 8.0,
  //                         ),
  //                         Icon(
  //                           Icons.more_vert,
  //                           size: 28,
  //                         )
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               Divider(
  //                 thickness: .5,
  //                 color: Colors.black,
  //               )
  //             ],
  //           ),
  //           // child: Container(
  //           //   decoration: BoxDecoration(
  //           //     border: Border(
  //           //       bottom: BorderSide(color: Colors.black, width: .5),
  //           //     ),
  //           //   ),
  //           //   child: Row(
  //           //     children: <Widget>[
  //           //       Row(
  //           //         children: <Widget>[
  //           //           Text(getFileName(folderContent[index])),
  //           //         ],
  //           //       )
  //           //     ],
  //           //   ),
  //           // ),
  //         );
  //       },
  //     ),
  //   );
  // }
}
