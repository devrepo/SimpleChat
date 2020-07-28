import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simplechat/models/room.dart';
import '../models/message.dart';

class ChatView extends StatefulWidget {
  final FirebaseUser user;
  final Room room;
  final List<Message> messages = List<Message>();

  ChatView(this.user, this.room);

  // ignore: empty_constructor_bodies
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _messageEntryController = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  Firestore fs = Firestore.instance;
  CollectionReference cf;

  @override
  void initState() {
    super.initState();
    cf = fs.collection("rooms");
  }

  /*Future _loadMessages() async {
    _loading = true;
    try {
      var result = await messageService.readMessages(_roomId);
      setState(() {
        widget.messages.addAll(result);
      });
      _loading = false;
    } catch (exception) {
      print('Failed getting Rooms.' + exception.toString());
    }
  }*/

  void onMessageSend() async {
    String msg = _messageEntryController.text.trim();
    int time = DateTime.now().millisecondsSinceEpoch;
    Message composedMessage = new Message(
        msg, false, time.toString(), widget.user.phoneNumber, widget.room.id);
    try {
      await cf
          .document(widget.room.id)
          .collection("messages")
          .add(composedMessage.toJson());
      _messageEntryController.text = "";
    } catch (exception) {
      print('Failed sending message');
    }
  }

  _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              controller: _messageEntryController,
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: onMessageSend,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Message> messages = widget.messages;
    double responsiveWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: Text(
            widget.room.room,
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0.0,
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
                cf.document(widget.room.id).collection("messages").snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                messages.clear();
                List<DocumentSnapshot> docs = snapshot.data.documents;
                docs.sort((DocumentSnapshot a, DocumentSnapshot b) =>
                    b.data['time'].compareTo(a['time']));
                docs.forEach((doc) {
                  messages.add(Message.fromSnapshot(doc));
                });
                return Column(children: <Widget>[
                  Expanded(
                      child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.only(top: 15.0),
                          itemCount: widget.messages.length,
                          reverse: true,
                          itemBuilder: (BuildContext context, int index) {
                            final message = widget.messages[index];
                            final bool isMe =
                                message.user == widget.user.phoneNumber;
                            return InkWell(
                              child: Container(
                                  margin:
                                      EdgeInsets.only(top: 5.0, bottom: 5.0),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  color: (isMe
                                      ? Colors.grey
                                      : Colors.amberAccent[400]),
                                  child: Row(
                                      mainAxisAlignment: isMe
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.all(16.0),
                                          width: responsiveWidth,
                                          child: new Column(
                                            crossAxisAlignment: isMe
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                message.message,
                                                textAlign: isMe
                                                    ? TextAlign.end
                                                    : TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ])),
                            );
                          })),
                  _buildMessageComposer()
                ]);
              }
              return CircularProgressIndicator();
            }));
  }
}
