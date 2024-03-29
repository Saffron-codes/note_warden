import 'dart:io';

import 'package:note_warden/feature_collection/domain/model/collection_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

abstract class CollectionDataSource {
  Future<List<Collection>> getCollections();

  Future<Collection> insertCollection(String name);

  Future<void> deleteCollection(Collection collection);

  Future<List<Collection>> searchCollection(String name);
}

class CollectionDataSourceImpl implements CollectionDataSource {
  final Database db;

  CollectionDataSourceImpl(this.db);
  @override
  Future<void> deleteCollection(Collection collection) async {
    Directory? externalDirectory = await getExternalStorageDirectory();
    if (externalDirectory != null) {
      int index = externalDirectory.path.indexOf("/0/");
      String path = externalDirectory.path.substring(0, index + 3);

      Directory subDirectory = Directory('$path/NoteWarden/${collection.name}');

      if (subDirectory.existsSync()) {
        subDirectory.listSync().forEach((entity) {
          if (entity is File) {
            entity.deleteSync();
          }
        });
      }

      db.delete("Media", where: "collectionId=?", whereArgs: [collection.id]);

      db.delete("Collection", where: "id=?", whereArgs: [collection.id]);

      await subDirectory.delete();
    } else {
      return;
    }
  }

  @override
  Future<List<Collection>> getCollections() async {
    final rawCollections = await db.query("Collection");
    return List<Collection>.from(
        rawCollections.map((model) => Collection.fromJson(model)));
  }

  @override
  Future<Collection> insertCollection(String name) async {
    DateTime dt = DateTime.now();

    final Map<String, dynamic> collectionJson = {
      'name': name,
      'createdAt': dt.toIso8601String(),
      'updatedAt': dt.toIso8601String(),
    };

    int id = await db.insert('Collection', collectionJson);

    print("INSERTED COLLECTION ID  : $id");

    collectionJson['id'] = id;

    if (id != 0) {
      return Collection.fromJson(collectionJson);
    } else {
      throw Exception("Collection error");
    }
  }

  @override
  Future<List<Collection>> searchCollection(String name) async {
    final rawCollections = await db.query(
      "Collection",
      where: "name LIKE ?",
      whereArgs: ['%$name%'],
    );
    return List<Collection>.from(
        rawCollections.map((model) => Collection.fromJson(model)));
  }
}
