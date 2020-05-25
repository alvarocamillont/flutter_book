import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<int> getLatestComicNumber() async {
  final dir = await getTemporaryDirectory();
  var file = File('${dir.path}/latestComicNumber.txt');
  int n = 1;

  try {
    n = json.decode(
      await http.read('https://xkcd.com/info.0.json')
    )["num"];
    file.exists().then(
      (exists) {
        if(!exists) file.createSync();
        file.writeAsString('$n');
      }
    );
  }
  catch(e) {
    if(
      file.existsSync() &&
      file.readAsStringSync() != ""
    )
      n = int.parse(file.readAsStringSync());
  }
  return n;
}


void main() async {
 runApp(
   new MaterialApp(
     home: HomeScreen(
       title: 'XKCD app',
       latestComic: await getLatestComicNumber(),
     )
   )
 );
}


class SelectionPage extends StatelessWidget {

 Future<Map<String, dynamic>> _fetchComic(String n) async {
   final dir = await getTemporaryDirectory();
   var comicFile = File("${dir.path}/$n.json");

  if(
    await comicFile.exists() &&
    comicFile.readAsStringSync() != ""
  )
    return json.decode(comicFile.readAsStringSync());
  else {
    comicFile.createSync();
    final comic = json.decode(
      await http.read('https://xkcd.com/$n/info.0.json')
    );

    File('${dir.path}/$n.png')
      .writeAsBytesSync(await http.readBytes(comic["img"]));
    comic["img"] = '${dir.path}/$n.png';
    comicFile.writeAsString(json.encode(comic));

    return comic;
  }
 }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text("Comic selection"),
     ),
     body: Center(
       child: TextField(
         decoration: InputDecoration(
           labelText: "Insert comic #",
         ),
         keyboardType: TextInputType.number,
         autofocus: true,
         onSubmitted: (String a) => Navigator.push(
           context,
           MaterialPageRoute(
             builder: (context) => FutureBuilder(
               future: _fetchComic(a),
               builder: (context, snapshot) {
                 if(snapshot.hasError) return ErrorPage();
                 if(snapshot.hasData) return ComicPage(snapshot.data);
                 return CircularProgressIndicator();
               }
             ),
           ),
         ),
       ),
     ),
   );
  }
}

class ComicPage extends StatefulWidget {
  ComicPage(this.comic);

  final Map<String, dynamic> comic;

  @override
  _ComicPageState createState() => _ComicPageState();
}

class _ComicPageState extends State<ComicPage> {


 bool isStarred;
 String docsDir;

  void _launchComic(int comicNumber) {
    launch("https://xkcd.com/$comicNumber/");
  }

  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then(
      (dir) {
        docsDir = dir.path;
        var file = File("$docsDir/starred");
        if(!file.existsSync()) {
          file.createSync();
          file.writeAsStringSync("[]");
          isStarred = false;
        }
        else {
          setState((){isStarred = _isStarred(widget.comic["num"]);});
        }
      }
    );
  }


  void _addToStarred(int num) {
    var file = File("$docsDir/starred");
    List<int> savedComics = json.decode(
      file.readAsStringSync()
    ).cast<int>();
    if(isStarred) {
      savedComics.remove(num);
    }
    else {
      savedComics.add(num);
    }
    file.writeAsStringSync(json.encode(savedComics));
   }

  bool _isStarred(int num) {
    var file = File("$docsDir/starred");
    List<int> savedComics = json.decode(
      file.readAsStringSync()
    ).cast<int>();
    if(savedComics.indexOf(num) != -1)
      return true;
    else
      return false;
  }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text("#${widget.comic["num"]}"),
       actions: <Widget>[
         IconButton(
          icon: isStarred == true ?
            Icon(Icons.star) :
            Icon(Icons.star_border),
          tooltip: "Star Comic",
          onPressed: () {
            _addToStarred(widget.comic["num"]);
            setState(() {
              isStarred = !isStarred;
            });
          }
         ),
       ],
     ),
     body: ListView(children: <Widget>[
       Center(
         child: Text(
           widget.comic["title"],
           style: Theme.of(context).textTheme.display3,
         ),
       ),

       InkWell(
         onTap: () {_launchComic(widget.comic["num"]);},
          child: Image.file(File(widget.comic["img"])),
       ),
       Padding(padding: EdgeInsets.all(8.0),child: Text(widget.comic["alt"])),
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
     // Setting max height and width for preview to 30x30px
     leading: Image.file(File(comic["img"]), height: 30, width: 30),
     title: Text(comic["title"]),
     onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => ComicPage(comic)
        ),
      );
    },
   );
 }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({this.title, this.latestComic});

  final int latestComic;
  Future<Map<String, dynamic>> _fetchComic(int n) async {

   final dir = await getTemporaryDirectory();
   int comicNumber = latestComic-n;
   var comicFile = File("${dir.path}/$comicNumber.json");
   if(
    await comicFile.exists() &&
    comicFile.readAsStringSync() != ""
   )
     return json.decode(comicFile.readAsStringSync());
   else {
     comicFile.createSync();
      final comic = json.decode(
       await http.read(
        'https://xkcd.com/$comicNumber/info.0.json'
       )
      );

      File('${dir.path}/$comicNumber.png')
        .writeAsBytesSync(await http.readBytes(comic["img"]));
      comic["img"] = '${dir.path}/$comicNumber.png';
      comicFile.writeAsString(json.encode(comic));

      return comic;

   }
  }


 final String title;

 @override
 Widget build(BuildContext context) {

   return Scaffold(
      appBar: AppBar(
       title: Text(title),
       actions: <Widget>[
          IconButton(
           icon: Icon(Icons.looks_one),
           tooltip: "Select Comics by Number",
           onPressed: () =>
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (BuildContext context) =>
                    SelectionPage()
               ),
             ),
         ),
         IconButton(
          icon: Icon(Icons.star),
          tooltip: "Browse Starred Comics",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) =>
                  StarredPage()
              ),
            );
          }
         ),
       ],
     ),
     body: ListView.builder(
       itemCount: latestComic,
       itemBuilder:(context, i) => FutureBuilder(
         future: _fetchComic(i),
         builder: (context, snapshot) {
           return snapshot.hasData ?
            ComicTile(comic: snapshot.data) :
            Container(
               width: 30,
              child: CircularProgressIndicator()
             );
         },
       ),
     ),
   );
 }
}

class StarredPage extends StatelessWidget {

  StarredPage();

  Future<Map<String, dynamic>> _fetchComic(String n) async {
    final dir = await getTemporaryDirectory();
    var comicFile = File("${dir.path}/$n.json");

    if(
      await comicFile.exists() &&
      comicFile.readAsStringSync() != ""
    )
      return json.decode(comicFile.readAsStringSync());
    else {
      comicFile.createSync();
      final comic = json.decode(
        await http.read('https://xkcd.com/$n/info.0.json')
      );

      File('${dir.path}/$n.png')
        .writeAsBytesSync(await http.readBytes(comic["img"]));
      comic["img"] = '${dir.path}/$n.png';
      comicFile.writeAsString(json.encode(comic));

      return comic;
    }
  }

  Future<List<Map<String, dynamic>>> _retrieveSavedComics() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    File file = File("${docsDir.path}/starred");
    List<Map<String, dynamic>> comics = [];

    if(!file.existsSync()) {
      file.createSync();
      file.writeAsStringSync("[]");
    } else {
      json.decode(file.readAsStringSync()).forEach(
        (n) async =>
          comics.add(await _fetchComic(n.toString()))
      );
    }
    return comics;
  }

  @override
  Widget build(BuildContext context) {
    var comics = _retrieveSavedComics();

    return Scaffold(
        appBar: AppBar(
          title: Text("Browse your Favorite Comics")
        ),
        body:
        FutureBuilder(
          future: comics,
          builder: (context, snapshot) =>
            snapshot.hasData && snapshot.data.isNotEmpty ?
            ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, i) =>
                ComicTile(comic: snapshot.data[i],),
            )
            :
            Column(
              children: [
                Icon(Icons.not_interested),
                Text("""
                  You haven't starred any comics yet.
                  Check back after you have found something worthy of being here.
                """),
              ]
            )
        )

      );
  }

}


class ErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Error Page"),
      ),
      body: Column(
              children: [
                Icon(Icons.not_interested),
                Text(
                  "The comics you have selected doesn't exist"+
                  "or isn't available"
                ),
              ]
            )
    );
  }
}
