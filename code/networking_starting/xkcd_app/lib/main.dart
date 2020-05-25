import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';


Future<int> getLatestComicNumber() async =>
json.decode(
    await http.read('https://xkcd.com/info.0.json')
 )
 ["num"];



void main() async =>
 runApp(
   new MaterialApp(
     home: HomeScreen(
       title: 'XKCD app',
       latestComic: await getLatestComicNumber(),
     )
   )
 );

class ComicPage extends StatelessWidget {
 ComicPage(this.comic);

 final Map<String, dynamic> comic;

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(title: Text("#${comic["num"]}")),
     body: ListView(children: <Widget>[
       Center(
         child: Text(
           comic["title"],
           style: Theme.of(context).textTheme.display3,
         ),
       ),
       Image.network(comic["img"]),
       Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(comic["alt"])
       ),
     ],),

   );
 }
}

class ComicTile extends StatelessWidget {
  ComicTile({this.comic});

  final Map<String, dynamic> comic;


  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(
        comic["img"],
        height: 30,
        width: 30
      ),
      title: Text(comic["title"]),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
              ComicPage(comic)
          ),
        );
      },
    );
  }
}


class HomeScreen extends StatelessWidget {
 HomeScreen({this.title, this.latestComic});
 final int latestComic;
 final String title;

  Future<Map<String, dynamic>> _fetchComic(int n) async =>
    json.decode(
      await http.read(
        "https://xkcd.com/${latestComic-n}/info.0.json"
      )
    );

 @override
 Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
       title: Text(title),
     ),
     body: ListView.builder(
       itemCount: latestComic,
       itemBuilder:(context, i) => FutureBuilder(
         future: _fetchComic(i),
         builder: (context, comicResult) =>
           comicResult.hasData ?
           ComicTile(comic: comicResult.data) :
           Divider();
       ),
     ),
   );
 }
}
