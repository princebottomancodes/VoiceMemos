import 'package:localstore/localstore.dart';

/// Data Model
class FolderModel {
  String title;
  final String id;
  FolderModel({
    required this.title,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
    };
  }

  factory FolderModel.fromMap(Map<String, dynamic> map) {
    return FolderModel(
      title: map['title'],
      id: map['id']
    );
  }
}

extension ExtFolderModel on FolderModel {
  Future save() async {
    final _db = Localstore.instance;
    return _db.collection('folders').doc(id).set(toMap());
  }

  Future delete() async {
    final _db = Localstore.instance;
    return _db.collection('folders').doc(id).delete();
  }
}
