import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/providers/provider.dart';

void removeAllSongs(BuildContext context) {
  Provider.of<DBProvider>(context, listen: false).deleteSong(null);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('All songs have been removed'),
    ),
  );
}
