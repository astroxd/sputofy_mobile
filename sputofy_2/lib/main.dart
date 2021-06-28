import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/components/appbar.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/screens/songListScreen/song_list_screen.dart';
import 'package:sputofy_2/theme/style.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DBProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sputofy',
        theme: appTheme(),
        home: AudioServiceWidget(
          child: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: appBar(),
              body: TabBarView(
                children: [
                  SongListScreen(),
                  Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
