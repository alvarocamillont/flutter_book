  @override
  Widget build(BuildContext context) {
    var comics = _retrieveSavedComics();//(1)

    return Scaffold(
        appBar: AppBar(
          title: Text("Browse your Favorite Comics")
        ),
        body: FutureBuilder(
          future: comics,
          builder: (context, snapshot) =>
            snapshot.hasData && snapshot.data.isNotEmpty ?//(2)
            ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, i) =>
                ComicTile(comic: snapshot.data[i],),
            )
            ://(3)
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
