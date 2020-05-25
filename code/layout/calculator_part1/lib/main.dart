import "package:flutter/material.dart";

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Calculator",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Colors.black26
      ),
      home: CalculatorHomePage(title: "Flutter Calculator", ),
    );
  }
}


class CalculatorHomePage extends StatefulWidget {
  CalculatorHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _CalculatorHomePageState createState() => _CalculatorHomePageState();
}


class _CalculatorHomePageState extends State<CalculatorHomePage> {

  String _str = "0";

  void add(String a) {
  }

  void deleteAll() {
  }

  void deleteOne() {
  }

  void getResult() {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Card(
            color: Colors.lightGreen[50],
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                _str,
                textScaleFactor: 2.0,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FlatButton(
                child: Text(
                  'C',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: (){deleteAll();},
                color: Colors.black54,
              ),
              FlatButton(
                child: Text(
                  '<-',
                  style: TextStyle(color: Colors.white)
                ),
                onPressed: (){deleteOne();},
                color: Colors.black87,
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    crossAxisAlignment:  CrossAxisAlignment.stretch,
                    children: <Widget>[
                      FlatButton(
                        child: Text(
                          '7',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {add('7');},
                        color: Colors.blueAccent,
                      ),
                      FlatButton(
                        child: Text(
                          '8',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {add('8');},
                        color: Colors.blueAccent,
                      ),
                      FlatButton(
                        child: Text(
                          '9',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {add('9');},
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment:  CrossAxisAlignment.stretch,
                    children:<Widget>[
                      FlatButton(
                        child: Text(
                          '4',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {add('4');},
                        color: Colors.blueAccent,
                      ),
                      FlatButton(
                        child: Text(
                          '5',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {add('5');},
                        color: Colors.blueAccent,
                      ),
                      FlatButton(
                        child: Text(
                          '6',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {add('6');},
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment:  CrossAxisAlignment.stretch,
                    children: <Widget>[
                      FlatButton(
                        child: Text(
                          '1',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {add('1');},
                        color: Colors.blueAccent,
                      ),
                      FlatButton(
                        child: Text(
                          '2',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {add('2');},
                        color: Colors.blueAccent,
                      ),
                      FlatButton(
                        child: Text(
                          '3',
                          style: TextStyle(color: Colors.white)
                        ),
                        onPressed: () {add('3');},
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment:  CrossAxisAlignment.stretch,
                    children: <Widget>[
                      FlatButton(
                        child: Text(
                          '0',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {add('0');},
                        color: Colors.blueAccent,
                      ),
                      FlatButton(
                        child: Text(
                          '.',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {add('.');},
                        color: Colors.blueAccent,
                      ),
                      FlatButton(
                        child: Text('='),
                        onPressed: () {
                          getResult();
                        },
                        color: Colors.blue[50],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FlatButton(
                    child: Image.asset(
                      "icons/divide.png",
                      width: 10.0,
                      height: 10.0,
                    ),
                    onPressed: () {add('÷');},
                    color: Colors.blue[50],
                  ),
                  FlatButton(
                    child: Text('x'),
                    onPressed: () {add('x');},
                    color: Colors.blue[50],
                  ),
                  FlatButton(
                    child: Text('-'),
                    onPressed: () {add('-');},
                    color: Colors.blue[50],
                  ),
                  FlatButton(
                    child: Text('+'),
                    onPressed: () {add('+');},
                    color: Colors.blue[50],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
