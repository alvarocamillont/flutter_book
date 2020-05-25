import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  runApp(
    MyApp(
      (
        await FirebaseAuth.instance.currentUser()
      ) != null
    )
  );
}

class MyApp extends StatelessWidget {
  MyApp(this.isSignedIn);

  final bool isSignedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatOnFire',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isSignedIn ? ChatPage() : LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {

  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  FirebaseUser _user;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _verificationComplete = false;

  Future<FirebaseUser> signUp(
    String email, String password
  ) async =>
    _auth.createUserWithEmailAndPassword(
      email: email,
      password: password
    );

  Future<FirebaseUser> logIn(
    String email, String password
  ) async =>
    _auth.signInWithEmailAndPassword(
        email: email,
        password: password
    );

  @override
  Widget build(BuildContext context) {
    if(_verificationComplete) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConfigPage()
          )
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("ChatOnFire Login"),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              "Log In Using Your Phone Number",
              style: Theme.of(context).textTheme.display1,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email Address",
              ),
              autofocus: true,
            )
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              keyboardType: TextInputType.text,
              obscureText: true,
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Password",
              ),
            )
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: FlatButton(
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              child: Text("Log In".toUpperCase()),
              onPressed: () {
                logIn(
                  _emailController.text,
                  _passwordController.text
                ).then(
                  (user) {
                    _user = user;
                    if(!_user.isEmailVerified) {
                      _user.sendEmailVerification();
                    }
                    _verificationComplete = true;
                    Navigator.pushReplacement(
                      context, MaterialPageRoute(
                        builder: (context) => ConfigPage()
                      )
                    );
                  }
                ).catchError(
                  (e) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "You don't have an account. Please sign up."
                        )
                      )
                    );
                  }
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: FlatButton(
              color: Theme.of(context).hintColor,
              textColor: Colors.white,
              child: Text("Create an Account".toUpperCase()),
              onPressed: () async {
                try {
                  _user = await signUp(
                    _emailController.text,
                    _passwordController.text
                  );
                  if(!_user.isEmailVerified) {
                    _user.sendEmailVerification();
                  }
                  _verificationComplete = true;
                  Navigator.pushReplacement(
                    context, MaterialPageRoute(
                      builder: (context) => ConfigPage()
                    )
                  );
                }
                catch(e) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text("An error occurred")
                    )
                  );
                }
              },
            ),
          ),
        ],
      )
    );
  }
}

class ConfigPage extends StatelessWidget {
  final _controller = TextEditingController();

  void setNameAndGoToChatPage(String name, BuildContext context) {
    FirebaseAuth.instance.currentUser().then(
      (user) {
        var newUserInfo = UserUpdateInfo();
        newUserInfo.displayName = name;
        user.updateProfile(newUserInfo);
      }
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Configure you account's basic information")),
      body: ListView(
        children: <Widget>[
          TextField(decoration: InputDecoration(
              labelText: "Display Name"
            ),
            onSubmitted: (displayName) =>
              setNameAndGoToChatPage(displayName, context),
            controller: _controller,
          ),
          FlatButton(
            child: Text("Submit"),
            onPressed: () =>
              setNameAndGoToChatPage(_controller.text, context),
          )
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  var _messageController =TextEditingController();

  void sendText(String text) =>
    FirebaseAuth.instance.currentUser().then(
      (user) =>
        Firestore.instance.collection("Messages").add(
          {
            "from": user != null ? user.displayName : "Anonymous",
            "when": Timestamp.fromDate(DateTime.now().toUtc()),
            "msg": text,
          }
        )
    );

  Stream<QuerySnapshot> getMessages() =>
    Firestore
      .instance
      .collection("Messages")
      .orderBy("when", descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ChatOnFire"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: getMessages(),
              builder: (context, snapshot) =>
                snapshot.hasData ?
                  MessagesList(snapshot.data as QuerySnapshot)
                :
                  Center(child: CircularProgressIndicator())
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _messageController,
                    keyboardType: TextInputType.text,
                    onSubmitted: (txt) {
                      sendText(txt);
                      _messageController.clear();
                    }
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  sendText(_messageController.text);
                  _messageController.clear();
                }
              )
            ],
          )
        ],
      ),
    );
  }
}


class MessagesList extends StatelessWidget {
  MessagesList(this.data);

  final QuerySnapshot data;

  bool areSameDay(Timestamp a, Timestamp b) {
    var date1 = a.toDate().toLocal();
    var date2 = b.toDate().toLocal();
    return
      (date1.year == date2.year)
      &&
      (date1.month == date2.month)
      &&
      (date1.day == date2.day);
  }

  @override
  Widget build(BuildContext context) =>
    ListView.builder(
      reverse: true,
      itemCount: data.documents.length,
      itemBuilder: (context, i) {
        var months = [
          "January",
          "February",
          "March",
          "April",
          "May",
          "June",
          "July",
          "August",
          "September",
          "October",
          "November",
          "December"
        ];
        DateTime when = data
                         .documents[i]
                         .data["when"]
                         .toDate()
                         .toLocal();
        var widgetsToShow = <Widget>[
          Message(
            from: data.documents[i].data["from"],
            msg: data.documents[i].data["msg"],
            when: when
          ),
        ];
        if(i == data.documents.length-1) {
          widgetsToShow.insert(
            0,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                "${when.day} ${months[when.month-1]} ${when.year}",
                style: Theme.of(context).textTheme.subhead,
              ),
            )
          );
        } else if(
          !areSameDay(
            data.documents[i+1].data["when"],
            data.documents[i].data["when"]
          )
        ) {
          widgetsToShow.insert(
            0,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                "${when.day} ${months[when.month-1]} ${when.year}",
                style: Theme.of(context).textTheme.subhead
              ),
            )
          );
        }
        return Column(
          children: widgetsToShow
        );
      }
    );
}

class Message extends StatelessWidget {
  Message({this.from, this.msg, this.when});

  final String from;
  final String msg;
  final DateTime when;

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          FirebaseUser user = snapshot.data;
          return Container(
            alignment: user.displayName == from
              ?
              Alignment.centerRight
              :
              Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width/3*2,
              child: Card(
                shape: StadiumBorder(),
                child: ListTile(
                  title: user.displayName != from
                    ? Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        left: 5.0
                      ),
                      child: Text(
                        from,
                        style: Theme.of(context).textTheme.subtitle
                      ),
                    )
                    : Padding(
                        padding: EdgeInsets.only(left: 5.0),
                        child: Text(
                          "You",
                          style: Theme.of(context).textTheme.subtitle
                        ),
                      ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10.0,
                      left: 5.0
                    ),
                    child: Text(
                      msg,
                      style: Theme.of(context).textTheme.body1
                    ),
                  ),
                  trailing: Text("${when.hour}:${when.minute}"),
                )
              ),
            )
          );
        } else {
          return CircularProgressIndicator();
        }
      }
    );
  }
}
