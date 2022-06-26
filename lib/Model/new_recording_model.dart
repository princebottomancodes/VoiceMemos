import 'package:localstore/localstore.dart';

/// Data Model
class NewRecordingModel {
  final String id;
  String title;
  DateTime time;
  bool done;
  NewRecordingModel({
    required this.id,
    required this.title,
    required this.time,
    required this.done,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time.millisecondsSinceEpoch,
      'done': done,
    };
  }

  factory NewRecordingModel.fromMap(Map<String, dynamic> map) {
    return NewRecordingModel(
      id: map['id'],
      title: map['title'],
      time: DateTime.fromMillisecondsSinceEpoch(map['time']),
      done: map['done'],
    );
  }
}

extension ExtNewRecordingModel on NewRecordingModel {
  Future save() async {
    final db = Localstore.instance;
    return db.collection('todos').doc(id).set(toMap());
  }

  Future delete() async {
    final db = Localstore.instance;
    return db.collection('todos').doc(id).delete();
  }
}
