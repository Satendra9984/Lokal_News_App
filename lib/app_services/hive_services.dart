import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorageServices {
  static final LocalStorageServices instance = LocalStorageServices._init();
  static late Box<Map<dynamic, dynamic>> _box;

  LocalStorageServices._init();

  Future<void> init() async {
    await Hive.initFlutter();
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    _box = await Hive.openBox<Map<dynamic, dynamic>>('bookmarked_tracks');
  }

  // Create
  Future<void> addItem(Map<dynamic, dynamic> data) async {
    // try {
    await _box.add(data);
    // } catch (e) {
    //   debugPrint(e.toString());
    // }
  }

  // Read
  dynamic getAllItems() {
    dynamic data = _box.values.toList();
    return data;
  }

  // Update
  Future<void> updateItem(int index, Map<dynamic, dynamic> newData) async {
    await _box.putAt(index, newData);
  }

  // Delete
  Future<void> deleteItem(int index) async {
    await _box.deleteAt(index);
  }

  // Close Hive box
  Future<void> closeBox() async {
    await _box.close();
  }
}
