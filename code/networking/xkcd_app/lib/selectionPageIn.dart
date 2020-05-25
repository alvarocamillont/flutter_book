class SelectionPage extends StatelessWidget {
  Future<Map<String, dynamic>> _fetchComic(String n) async =>
   json.decode(
     await http.read('https://xkcd.com/$n/info.0.json')
   );
}
