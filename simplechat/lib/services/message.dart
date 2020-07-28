import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:simplechat/models/message.dart';
import 'constants.dart';

class MessageService {
  Future<List<Message>> readMessages(roomId) async {
    final response = await http.post(Constants.origin + 'readMessages',
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"roomId": roomId}));
    if (response.statusCode == HttpStatus.ok) {
      dynamic jsonResult = jsonDecode(response.body);
      Iterable jsonMessages = jsonResult['result']['messages'];
      List<Message> messages =
          jsonMessages.map((x) => Message.fromJson(x)).toList();
      return messages;
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  Future<String> sendMessage(Message message) async {
    final response = await http.post(Constants.origin + 'sendMessage',
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(message));
    if (response.statusCode == HttpStatus.ok) {
      dynamic jsonResult = jsonDecode(response.body);
      String messageId = jsonResult['result']['id'];
      return messageId;
    } else {
      throw Exception('Failed to load rooms');
    }
  }
}
