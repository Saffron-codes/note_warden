import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import 'package:note_warden/models/collection_model.dart';

class CollectionService {
  final Database db;
  CollectionService(this.db);

  Logger logger = Logger();

  Future<List<Collection>> loadCollections() async {
    final rawCollections = await db.query("Collection");
    return List<Collection>.from(
        rawCollections.map((model) => Collection.fromJson(model)));
  }

  Future<Collection> addCollection({required String name}) async {
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

  Future<int> getMediaCount({required int collectionId}) async {
    List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT COUNT(*) AS mediaCount FROM Media WHERE collectionId = ?',
        [collectionId]);
    
    // logger.i(result);
    
    int? mediaCount = Sqflite.firstIntValue(result);

    // logger.i(mediaCount);

    return mediaCount ?? 0;
  }
}
