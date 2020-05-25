import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

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

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FirebaseUser _user;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _verificationComplete = false;

  Future<FirebaseUser> signUp(String email, String password) async =>
    _auth.createUserWithEmailAndPassword(
      email: email,
      password: password
    );

  Future<FirebaseUser> logIn(String email, String password) async =>
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
              style: Theme.of(context).textTheme.display1
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
                logIn(_emailController.text, _passwordController.text).then(
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
                        content: Text("You don't have an account. Please sign up.")
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
                  _user = await signUp(_emailController.text, _passwordController.text);
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
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();


  void setDataAndGoToChatPage(
    String name,
    String bio,
    BuildContext context
  ) {
    FirebaseAuth.instance.currentUser().then(
      (user) {
        var newUserInfo = UserUpdateInfo();
        newUserInfo.displayName = name;
        user.updateProfile(newUserInfo);
        Firestore
          .instance
          .collection("Users")
          .document(user.uid)
          .setData(
            {
              "bio": bio,
              "displayName": name,
              "email": user.email,
            }
          );
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
          TextField(
            decoration: InputDecoration(
              labelText: "Display Name"
            ),
            controller: _nameController,
          ),
          TextField(
            decoration: InputDecoration(
              labelText: "Bio"
            ),
            controller: _bioController,
          ),
          FlatButton(
            child: Text("Submit"),
            onPressed: () =>
              setDataAndGoToChatPage(
                _nameController.text,
                _bioController.text, context
              ),
          )
        ],
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  final _messageController =TextEditingController();

  void sendText(String text) =>
    FirebaseAuth.instance.currentUser().then(
      (user) =>
        Firestore.instance.collection("Messages").add(
          {
            "from": user.uid,
            "when": Timestamp.fromDate(DateTime.now().toUtc()),
            "msg": text,
          }
        )
    );

  Stream<QuerySnapshot> getMessages() =>
    Firestore.instance.collection("Messages").orderBy("when", descending: true).snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ChatOnFire"),
        actions: [
          IconButton(
            tooltip: "Change your bio",
            icon: Icon(Icons.edit),
            onPressed: () =>
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeBioPage()
                )
              ),
          )
        ],
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
                  padding: EdgeInsets.all(8.0),
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
    return (date1.year == date2.year) && (date1.month == date2.month) && (date1.day == date2.day);
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
        DateTime when = data.documents[i].data["when"].toDate().toLocal();
        var widgetsToShow = <Widget>[
          FutureBuilder(
            future: Firestore.instance
              .collection("Users")
              .document(data.documents[i].data["from"])
              .get(),
            builder: (context, snapshot) =>
              snapshot.hasData
              ? Message(
                from: (snapshot.data as DocumentSnapshot).data,
                msg: data.documents[i].data["msg"],
                when: when,
                uid: data.documents[i].data["from"]
              )
              : CircularProgressIndicator(),
          ),
        ];
        if(i == data.documents.length-1) {
          widgetsToShow.insert(
            0,
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
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
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                "${when.day} ${months[when.month-1]} ${when.year}",
                style: Theme.of(context).textTheme.subhead,
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
  Message({this.from, this.msg, this.when, this.uid});

  final Map<String, dynamic> from;
  final String uid;
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
            alignment: user.uid == uid
            ? Alignment.centerRight
            : Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width*2/3,
              child: Card(
                shape: StadiumBorder(),
                child: ListTile(
                  title: user.uid != uid
                    ?
                    InkWell(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 8.0,
                          left: 5.0
                        ),
                        child: Text(
                          from["displayName"],
                          style: Theme.of(context).textTheme.subtitle
                        ),
                      ),
                      onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(from)
                          )
                        ),
                    )
                    :
                    InkWell(
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.0),
                        child: Text(
                          "You",
                          style: Theme.of(context).textTheme.subtitle
                        ),
                      ),
                      onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(from)
                          )
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

class ProfilePage extends StatelessWidget {
  ProfilePage(this.user);

  final Map<String, dynamic> user;

  @override
  Widget build(context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              user["displayName"],
              style: Theme.of(context).textTheme.title
            ),
            Text(
              user["bio"],
              style: Theme.of(context).textTheme.subtitle
            ),
            FlatButton.icon(
              icon: Icon(Icons.email),
              label: Text("Send an e-mail to ${user["displayName"]}"),
              onPressed: () async {
                var url =
                  "mailto:${user["email"]}?body=${user["displayName"]},\n";
                if(await canLaunch(url)) {
                  launch(url);
                } else {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text("You don't have any e-mail app"),
                    )
                  );
                }
              }
            )
          ],
        ),
      )
    );
  }
}

class ChangeBioPage extends StatelessWidget {
  final _controller = TextEditingController();

  void _changeBio(String bio) =>
    FirebaseAuth.instance.currentUser().then(
      (user) {
        Firestore
          .instance
          .collection("Users")
          .document(user.uid)
          .updateData(
            {
              "bio": bio
            }
          );
      }
    );

  @override
  Widget build(context) =>
    Scaffold(
      appBar: AppBar(
        title: Text("Change your bio"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "New Bio"
                ),
                onSubmitted: (bio) {
                  _changeBio(bio);
                  Navigator.pop(context);
                }
              ),
            ),
            FlatButton(
              child: Text("Change Bio"),
              onPressed: () {
                _changeBio(_controller.text);
                Navigator.pop(context);
              }
            )
          ],
        ),
      )
    );
}
