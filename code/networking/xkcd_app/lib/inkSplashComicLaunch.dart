Material(
  child: Ink.image(
    image: FileImage(File(widget.comic["img"])),
    height: 300,
    width: 200,
    child: InkWell(
      onTap: () {_launchComic(widget.comic["num"]);},
    ),
  ),
),
       
