class HomeScreen extends StatelessWidget {
 HomeScreen({this.title, this.latestComic});

 final int latestComic;
 Future<Map<String, dynamic>> _fetchComic(int n) async {
   final dir = await getTemporaryDirectory();
   int comicNumber = latestComic-n;
   var comicFile = File("${dir.path}/$comicNumber.json");
   if(await comicFile.exists() && comicFile.readAsStringSync() != "")
     return json.decode(comicFile.readAsStringSync());
   else {
     final comic =
         await http.read('https://xkcd.com/${latestComic - n}/info.0.json');
     comicFile.writeAsString(comic); // no need to use sync methods as we don't have to wait for it to finish caching
     return json.decode(comic);
   }
 }


 final String title;

 @override
 Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
       title: Text(title),
       actions: <Widget>[//(1)
          IconButton(
           icon: Icon(Icons.looks_one),
           tooltip: "Select Comics by Number",//(2)
           onPressed: () =>//(3)
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (BuildContext context) => SelectionPage()
               ),
             ),
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
