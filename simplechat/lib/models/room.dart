import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  String id;
  String room;
  List members;

  Room({this.room, this.members});
  Room.withId({this.id, this.room, this.members});

  Room.fromSnapshot(DocumentSnapshot snapshot) {
    id = snapshot.documentID;
    room = snapshot.data['room'];
    members = snapshot.data['members'];
  }

  Room.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    room = json['room'];
    members = json['members'];
  }
}
