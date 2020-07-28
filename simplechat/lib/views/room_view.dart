import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simplechat/models/room.dart';
import '../services/rooms.dart';
import 'chat_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomView extends StatefulWidget {
  final FirebaseUser user;
  RoomView(this.user);

  // ignore: empty_constructor_bodies
  @override
  _RoomViewState createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> {
  RoomService roomService = new RoomService();
  String _phoneNumber;
  Firestore fs = Firestore.instance;
  CollectionReference cf;

  @override
  void initState() {
    super.initState();
    _phoneNumber = widget.user.phoneNumber;
    cf = fs.collection("rooms");
  }

  @override
  Widget build(BuildContext context) {
    List<Room> rooms = new List<Room>();
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: Text(
            "Your Rooms",
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 5.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.more_horiz),
              iconSize: 30.0,
              color: Colors.white,
              onPressed: () {},
            ),
          ],
        ),
        body: StreamBuilder(
            stream:
                cf.where("members", arrayContains: _phoneNumber).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                rooms.clear();
                List<DocumentSnapshot> docs = snapshot.data.documents;
                docs.forEach((doc) {
                  rooms.add(Room.fromSnapshot(doc));
                });
                return ListView.builder(
                  padding: EdgeInsets.only(top: 15.0),
                  itemCount: rooms.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Room room = rooms[index];
                    return InkWell(
                        child: Container(
                            margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            height: 70,
                            color: Colors.amberAccent[400],
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    room.room,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ])),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatView(widget.user, room),
                            )));
                  },
                );
              }
              return CircularProgressIndicator();
            }));
  }

  void onRoomSelected(Room room) {
    print('Room Selected ' + room.room);
  }
}
