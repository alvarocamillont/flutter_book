  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network( //(1)
        comic["img"],
        height: 30,
        width: 30
      ),
      title: Text(comic["title"]), //(2)
      onTap: () { //(3)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ComicPage(comic)
          ),
        );
      },
    );
  }
