import 'package:flutter/material.dart';

class Canzoni {
  int id;
  String nome;
  bool clicked;

  Canzoni(this.id, this.nome, this.clicked);
}

class SelectSongList extends StatefulWidget {
  @override
  _SelectSongListState createState() => _SelectSongListState();
}

class _SelectSongListState extends State<SelectSongList> {
  List<Canzoni> canzs = [
    Canzoni(1, "canzone 1", false),
    Canzoni(2, "canzone 2", false),
    Canzoni(3, "canzone 3", null),
    Canzoni(4, "canzone 4", false),
  ];

  List<Canzoni> prova = [
    Canzoni(1, "canzone 1", false),
  ];

  @override
  void initState() {
    print(canzs.contains(Canzoni(1, "canzone 1", false)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: canzs.length,
        itemBuilder: (context, index) {
          print("contiene ?${prova.contains(canzs[index])}");
          return CheckboxListTile(
            activeColor: Colors.orange,
            title: Text(canzs[index].nome),
            value: prova.contains(canzs[index]),
            onChanged: (bool value) {
              setState(() {
                canzs[index].clicked = value;
              });
            },
          );
        },
      ),
    );
  }
}
