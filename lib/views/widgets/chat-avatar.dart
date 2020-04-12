import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:Tether/domain/rooms/room/model.dart';

// TODO: make a proper widget instead of a selector

Widget buildChatAvatar({Room room}) {
  if (room.syncing) {
    return Container(
      margin: EdgeInsets.all(8),
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        value: null,
      ),
    );
  }

  if (room.avatar != null && room.avatar.data != null) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Image(
        width: 52,
        height: 52,
        image: MemoryImage(room.avatar.data),
      ),
    );
  }

  return Text(
    room != null && room.name != null
        ? room.name.substring(0, 2).toUpperCase()
        : '',
    style: TextStyle(fontSize: 18, color: Colors.white),
  );
}

Widget buildChatHero({Room room, double size, int fontSize}) {
  if (room.avatar != null && room.avatar.data != null) {
    return Image(
      fit: BoxFit.fitHeight,
      width: size ?? 52,
      height: size ?? 52,
      image: MemoryImage(room.avatar.data),
    );
  }

  return Container(
    child: Text(
      room != null && room.name != null
          ? room.name.substring(0, 2).toUpperCase()
          : '',
      style: TextStyle(fontSize: fontSize ?? 18, color: Colors.white),
    ),
  );
}