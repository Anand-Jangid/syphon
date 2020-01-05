import 'dart:typed_data';

import 'package:Tether/domain/index.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:redux_persist/redux_persist.dart';

const STORAGE_ENCRYPTION_KEY = 'tether@hivekey';
const HIVE_BOX_NAME = 'tether';
const APPSTATE_HIVE_KEY = 'app_state';

/**
 * Initializes encrypted storage that caches redux store 
 * Testing:
    print(box);
    print(box.keys);
    print(box.get('someone')); 
 */
Future<void> initHiveStorage() async {
  var appStorageLocation = await getApplicationDocumentsDirectory();
  Hive.init(appStorageLocation.path);

  final storage = new FlutterSecureStorage();

  // Check if storage has been created before
  var encryptionKeySerialized = await storage.read(key: STORAGE_ENCRYPTION_KEY);
  List<int> encryptionKey;

  // Create a encryptionKey if a serialized one is not found
  if (encryptionKeySerialized == null) {
    encryptionKey = Hive.generateSecureKey();
    await storage.write(
        key: STORAGE_ENCRYPTION_KEY, value: jsonEncode(encryptionKey));
  }

  encryptionKey = jsonDecode(encryptionKeySerialized).cast<int>();

  await Hive.openBox(HIVE_BOX_NAME, encryptionKey: encryptionKey);
}

AppState rehydateStore() {
  Box<dynamic> box = Hive.box(HIVE_BOX_NAME);
  AppState state = box.get(APPSTATE_HIVE_KEY);
  return state;
}

void cacheStore(AppState state) async {
  Box<dynamic> box = Hive.box(HIVE_BOX_NAME);
  box.put(APPSTATE_HIVE_KEY, state);
}

void clearStorage() {
  Box<dynamic> box = Hive.box(HIVE_BOX_NAME);
  box.put(APPSTATE_HIVE_KEY, null);
}

// Closes and saves storage
void closeStorage() async {
  Box<dynamic> box = Hive.box(HIVE_BOX_NAME);
  box.close();
  // print();
}

// TODO - finish this
// class SecureHiveStorage extends StorageEngine {
//   Box<dynamic> box;

//   @override
//   Future<Uint8List> load() async {
//     if (await file.exists()) {
//       return Uint8List.fromList(await file.readAsBytes());
//     }

//     return null;
//   }

//   @override
//   Future<void> save(Uint8List data) async {
//     await box.put(APPSTATE_HIVE_KEY, data);
//   }
// }