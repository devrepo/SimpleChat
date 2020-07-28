import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:simplechat/models/room.dart';
import 'constants.dart';

class RoomService {
  Future<List<Room>> getMyRooms(userId) async {
    final response = await http.post(Constants.origin + 'getMyRooms',
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}));
    if (response.statusCode == HttpStatus.ok) {
      dynamic jsonResult = jsonDecode(response.body);
      Iterable jsonRooms = jsonResult['result']['rooms'];
      List<Room> myRooms = jsonRooms.map((x) => Room.fromJson(x)).toList();
      return myRooms;
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  Future<List<Room>> getAllRooms() async {
    final response = await http.post(Constants.origin + 'getAllRooms',
        headers: {"Content-Type": "application/json"});
    if (response.statusCode == HttpStatus.ok) {
      dynamic jsonResult = jsonDecode(response.body);
      Iterable jsonRooms = jsonResult['result']['rooms'];
      List<Room> allRooms = jsonRooms.map((x) => Room.fromJson(x)).toList();
      return allRooms;
    } else {
      throw Exception('Failed to load rooms');
    }
  }
}
