showDialog(//(1)
 context: context,
 builder: (context) => SimpleDialog(//(2)
   title: Text("No Connection Available"),
   children: <Widget>[
     SimpleDialogOption(//(3)
       onPressed: () {Navigator.pop(context);},//(4)
       child: Row(//(5)
         children:[
           Padding(
             padding: EdgeInsets.all(5.0),
             child: Icon(Icons.replay),
           ),
           Text("Retry"),
         ]
        )
     )
   ],
 )
)