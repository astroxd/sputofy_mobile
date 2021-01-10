import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ChangeNotifier {
  Future _addPlaylist(String title) async {
    final data = await SharedPreferences.getInstance();

    await data.setString('playlist_title', title);
  }
}

// int intValue= await prefs.getInt('intValue') ?? 0;
