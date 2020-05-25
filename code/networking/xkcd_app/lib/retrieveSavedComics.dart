  Future<List<Map<String, dynamic>>> _retrieveSavedComics() async {
    Directory docsDir = await getApplicationDocumentsDirectory(); //(1)
    File file = File("${docsDir.path}/starred");
    List<Map<String, dynamic>> comics = [];

    if(!file.existsSync()) { //(2)
      file.createSync();
      file.writeAsStringSync("[]");
    } else {
      json.decode(file.readAsStringSync()).forEach( //(3)
        (n) async =>
          comics.add(await _fetchComic(n.toString()))
      );
    }
    return comics;
  }
