class SelectionPage extends StatelessWidget {
 Future<Map<String, dynamic>> _fetchComic(int n) async {
   final dir = await getTemporaryDirectory();
   var comicFile = File("${dir.path}/$n.json");

   if(await comicFile.exists() && comicFile.readAsStringSync() != "")
     return json.decode(comicFile.readAsStringSync());
   else {
     final comic =
         await http.read('https://xkcd.com/$n/info.0.json');
     comicFile.writeAsString(comic);
     return json.decode(comic);
   }
 }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text("Comic selection"),
     ),
     body: Center(
       child: TextField(//(1)
         decoration: InputDecoration(
           labelText: "Insert comic #",
         ),
         keyboardType: TextInputType.number,//(2)
         autofocus: true,//(3)
         onSubmitted: (String a) => Navigator.push(
           context,
           MaterialPageRoute(
             builder: (context) => FutureBuilder(//(4)
               future: _fetchComic(a),
               builder: (context, snapshot) {
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
