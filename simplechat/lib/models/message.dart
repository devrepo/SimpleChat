import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String id;
  String message;
  bool seen;
  String time;
  String user;
  String roomId;

  Message(this.message, this.seen, this.time, this.user, this.roomId);
  Message.withId(
      this.id, this.message, this.seen, this.time, this.user, this.roomId);

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'seen': seen,
      'time': time,
      'user': user,
      'roomId': roomId,
      'id': id
    };
  }

  Message.fromSnapshot(DocumentSnapshot snapshot) {
    id = snapshot.documentID;
    message = snapshot.data['message'];
    seen = snapshot.data['seen'];
    time = snapshot.data['time'];
    user = snapshot.data['user'];
    roomId = snapshot.data['roomId'];
  }

  Message.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    message = json['message'];
    seen = json['seen'];
    time = json['time'];
    user = json['user'];
    roomId = json['roomId'];
  }
}
