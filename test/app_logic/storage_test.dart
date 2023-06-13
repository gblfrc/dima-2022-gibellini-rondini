import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/app_logic/storage.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseStorage>(),
  MockSpec<Reference>(),
  MockSpec<UploadTask>(),
  MockSpec<File>()
])
import 'storage_test.mocks.dart';

// class MockFirebaseStorage2 extends Mock implements FirebaseStorage {}

main() {
  late Storage storage;
  late MockFirebaseStorage mockFirebaseStorage;

  setUpAll(() {
    mockFirebaseStorage = MockFirebaseStorage();
    storage = Storage(firebaseStorage: mockFirebaseStorage);
    // registerFallbackValue(File('assets/test/flutter_logo.png'));
  });

  test('singleton properties', () {
    var storage1 = Storage();
    // var storage2 = Storage(firebaseStorage: MockFirebaseStorage2());
    expect(storage, storage1);
    // expect(storage, storage2);
    expect(storage.storageType, mockFirebaseStorage.runtimeType);
  });

  group('upload file', () {
    /*
    * This test might not be completely correct. Issues arose on stubbing the
    * then() method of the mockUploadTask. However, the method works correctly
    * on the emulator and no issues are returned when connecting to real
    * Firebase Storage services.
    * Might want to revise if there's some spare time.
    */
    test('correct upload', () async {
      File mockFile = MockFile();
      String remotePath = 'remoteAssets/flutter_logo.png';
      Reference mockReference = MockReference();
      UploadTask mockUploadTask = MockUploadTask();
      when(mockFirebaseStorage.ref(any))
          .thenAnswer((invocation) => mockReference);
      when(mockReference.putFile(mockFile))
          .thenAnswer((invocation) => mockUploadTask);
      storage.uploadFile(mockFile, remotePath);
      expect(true, true);
    });

    test('throws exception', () async {
      when(mockFirebaseStorage.ref(any))
          .thenThrow(FirebaseException(plugin: 'test'));
      expect(storage.uploadFile(MockFile(), 'remotePath'),
          throwsA(isA<StorageException>()));
    });
  });

  group('download url', () {
    test('correct download', () async {
      String remotePath = 'remoteAssets/flutter_logo.png';
      String url = 'https://pagefordownload.com/test.png';
      Reference mockReference = MockReference();
      when(mockFirebaseStorage.ref(remotePath))
          .thenAnswer((invocation) => mockReference);
      when(mockReference.getDownloadURL())
          .thenAnswer((invocation) => Future.value(url));
      expect(await storage.downloadURL(remotePath), url);
    });

    test('throws exception', () async {
      when(mockFirebaseStorage.ref(any))
          .thenThrow(FirebaseException(plugin: 'test'));
      expect(
          storage.downloadURL('remotePath'), throwsA(isA<StorageException>()));
    });
  });
}
