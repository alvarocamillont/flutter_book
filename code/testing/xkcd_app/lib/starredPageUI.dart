  @override
  Widget build(BuildContext context) {
    var comics = _retrieveSavedComics();//(1)

    return Scaffold(
        appBar: AppBar(//(2)
          title: Text("Browse your Favorite Comics")
        ),
        body: FutureBuilder(//(3)
          future: comics,
          builder: (context, snapshot) =>
            snapshot.hasData && snapshot.data.isNotEmpty ?//(4)
            ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, i) =>
                ComicTile(comic: snapshot.data[i],),
            )
            ://(5)
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
