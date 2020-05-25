import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xkcd_app/main.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class MockHTTPClient extends Mock implements http.Client {}
class MyFile extends Mock implements File {}


const comics = [
"""
  {
    "month": "",
    "num": 1,
    "link": "",
    "year": "",
    "news": "",
    "safe_title": "The First Comic",
    "transcript": "",
    "alt": "first comic alt-text",
    "img": "https://example.com/1.png",
    "title": "The First Comic",
    "day": ""
  }
  """,
  """
  {
    "month": "",
    "num": 2,
    "link": "",
    "year": "",
    "news": "",
    "safe_title": "The Second Comic",
    "transcript": "",
    "alt": "second comic alt-text",
    "img": "https://example.com/2.png",
    "title": "The Second Comic",
    "day": ""
  }
  """
];

void main() {
  group('latest comic', () {
    test("get latest comic number test", () async {
      var latestComicNumberFile = MyFile();// (1)
      var latestComicNumberExists = false;
      String latestComicNumberString;
      var mockHttp = MockHTTPClient();

      when(mockHttp.read('https://xkcd.com/info.0.json')).thenAnswer(// (2)
        (_) => Future.value(comics[1])
      );

      when(latestComicNumberFile.createSync()).thenAnswer(// (3)
        (_) {
          latestComicNumberExists = true;
        }
      );

      when(latestComicNumberFile.create()).thenAnswer(// (4)
        (_) {
          latestComicNumberExists = true;
          return Future.value(latestComicNumberFile);
        }
      );

      when(latestComicNumberFile.writeAsStringSync("2")).thenAnswer(// (5)
        (_) {
          latestComicNumberExists = true;
          latestComicNumberString = "2";
        }
      );




      when(latestComicNumberFile.writeAsString("2")).thenAnswer(// (6)
        (_) {
          latestComicNumberExists = true;
          latestComicNumberString = "2";
          return Future.value(latestComicNumberFile);
        }
      );

      when(latestComicNumberFile.existsSync()).thenReturn(// (7)
        latestComicNumberExists
      );

      when(latestComicNumberFile.exists()).thenAnswer(// (8)
        (_) =>
          Future.value(latestComicNumberExists)
      );

      when(latestComicNumberFile.readAsStringSync()).thenAnswer(// (9)
        (_) {
          // if we try to read from a file that doesn't exist we've made a mistake
          assert(latestComicNumberExists, true);
          return "2";
        }
      );

      when(latestComicNumberFile.readAsString()).thenAnswer(// (10)
        (_) {
          assert(latestComicNumberExists, true);
          return Future.value(latestComicNumberString);
        }
      );

      expect(// (11)
        await getLatestComicNumber(
          httpClient: mockHttp,
          latestComicNFile: latestComicNumberFile,
        ),
        2
      );
    });
    test("SelectionPage fetchComic latest", () async {
      var latestComicFile = MyFile();
      var latestComicExists = false;
      String latestComicString;
      var latestImageFile = MyFile();
      Uint8List latestImageData;
      var latestImageExists = false;
      var mockHttp = MockHTTPClient();

      when(mockHttp.read('https://xkcd.com/2/info.0.json')).thenAnswer(
        (_) => Future.value(comics[1])
      );

      when(mockHttp.readBytes("https://example.com/2.png")).thenAnswer(
        (_) => Future.value(Uint8List.fromList([2]))
      );

      when(latestComicFile.createSync()).thenAnswer(
        (_) {
          latestComicExists = true;
        }
      );

      when(latestComicFile.create()).thenAnswer(
        (_) {
          latestComicExists = true;
          return Future.value(latestComicFile);
        }
      );

      when(latestComicFile.writeAsStringSync(comics[1])).thenAnswer(
        (_) {
          latestComicExists = true;
          latestComicString = comics[1];
        }
      );

      when(latestComicFile.writeAsString(comics[1])).thenAnswer(
        (_) {
          latestComicExists = true;
          latestComicString = comics[1];
          return Future.value(latestComicFile);
        }
      );

      when(latestComicFile.existsSync()).thenReturn(
        latestComicExists
      );

      when(latestComicFile.exists()).thenAnswer(
        (_) =>
          Future.value(latestComicExists)
      );

      when(latestComicFile.readAsStringSync()).thenAnswer(
        (_) {
          /*
	   * if we try to read from a file that doesn't
	   * exist it's because we've made a mistake
	   */
          assert(latestComicExists, true);
          return latestComicString;
        }
      );

      when(latestImageFile.readAsBytes()).thenAnswer(
        (_) {
          assert(latestImageExists, true);
          return Future.value(latestImageData);
        }
      );

      when(
        latestImageFile.writeAsBytesSync(
	  Uint8List.fromList([1])
	)
      ).thenAnswer(
        (_) {
          latestImageExists = true;
          latestImageData = Uint8List.fromList([1]);
        }
      );

      when(latestComicFile.writeAsString(comics[1])).thenAnswer(
        (_) {
          latestImageExists = true;
          latestImageData = Uint8List.fromList([1]);
          return Future.value(latestImageFile);
        }
      );

      var selPage = SelectionPage();

      expect(
        await selPage.fetchComic(
          "2",
          httpClient: mockHttp,
          comicFile: File("latestComicFole"),
          imageFile: File("latestComicFile"),
          imagePath: "https://example.com/2.png"
        ),
        json.decode(comics[1])
      );
    });
  });
}
