import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/screens/create_topic.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chewie/chewie.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:async';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StoreData {
  final StorageService storageService;

  StoreData(this.storageService);

  Future<String> uploadVideo(String videoUrl) async {
    return storageService.uploadVideo(videoUrl);
  }
}

abstract class StorageService {
  Future<String> uploadVideo(String videoUrl);
}

class FirebaseStorageService implements StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<String> uploadVideo(String videoUrl) async {
    Reference ref = _storage.ref().child('videos/${DateTime.now()}.mp4');
    await ref.putFile(File(videoUrl));
    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }
}

class FakeStorageService implements StorageService {
  @override
  Future<String> uploadVideo(String videoUrl) async {
    return 'fake_download_url';
  }
}

class FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  final Completer<bool> initialized = Completer<bool>();
  final List<String> calls = <String>[];
  final List<DataSource> dataSources = <DataSource>[];
  final Map<int, StreamController<VideoEvent>> streams =
      <int, StreamController<VideoEvent>>{};
  final bool forceInitError;
  int nextTextureId = 0;
  final Map<int, Duration> _positions = <int, Duration>{};

  FakeVideoPlayerPlatform({
    this.forceInitError = false,
  });

  @override
  Future<int?> create(DataSource dataSource) async {
    calls.add('create');
    final StreamController<VideoEvent> stream = StreamController<VideoEvent>();
    streams[nextTextureId] = stream;
    if (forceInitError) {
      stream.addError(
        PlatformException(
          code: 'VideoError',
          message: 'Video player had error XYZ',
        ),
      );
    } else {
      stream.add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          size: const Size(100, 100),
          duration: const Duration(seconds: 1),
        ),
      );
    }
    dataSources.add(dataSource);
    return nextTextureId++;
  }

  @override
  Future<void> dispose(int textureId) async {
    calls.add('dispose');
  }

  @override
  Future<void> init() async {
    calls.add('init');
    initialized.complete(true);
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    return streams[textureId]!.stream;
  }

  @override
  Future<void> pause(int textureId) async {
    calls.add('pause');
  }

  @override
  Future<void> play(int textureId) async {
    calls.add('play');
  }

  @override
  Future<Duration> getPosition(int textureId) async {
    calls.add('position');
    return _positions[textureId] ?? Duration.zero;
  }

  @override
  Future<void> seekTo(int textureId, Duration position) async {
    calls.add('seekTo');
    _positions[textureId] = position;
  }

  @override
  Future<void> setLooping(int textureId, bool looping) async {
    calls.add('setLooping');
  }

  @override
  Future<void> setVolume(int textureId, double volume) async {
    calls.add('setVolume');
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {
    calls.add('setPlaybackSpeed');
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {
    calls.add('setMixWithOthers');
  }

  @override
  Widget buildView(int textureId) {
    return Texture(textureId: textureId);
  }
}

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  mockFilePicker() {
    const MethodChannel channelFilePicker =
        MethodChannel('miguelruivo.flutter.plugins.filepicker');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelFilePicker,
            (MethodCall methodCall) async {
      final ByteData data = await rootBundle.load('/assets/sample-5s.mp4');
      final Uint8List bytes = data.buffer.asUint8List();
      final Directory tempDir = await getTemporaryDirectory();
      final File file = await File(
        '${tempDir.path}/sample-5s.mp4',
      ).writeAsBytes(bytes);
      return [
        {
          'name': "sample-5s.mp4",
          'path': file.path,
          'bytes': bytes,
          'size': bytes.lengthInBytes,
        }
      ];
    });
  }

  setUp(() {
    mockFilePicker();

    final fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();

    VideoPlayerPlatform.instance = fakeVideoPlayerPlatform;

    final fakeStorageService = FakeStorageService();

    final storeData = StoreData(fakeStorageService);
  });
  testWidgets('Topic with title and description save',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.tap(find.byType(OutlinedButton));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(
      documents.any(
        (doc) => doc.data()?['title'] == 'Test title',
      ),
      isTrue,
    );

    expect(
      documents.any(
        (doc) => doc.data()?['description'] == 'Test description',
      ),
      isTrue,
    );
  });

  testWidgets('Topic with no title does not save', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
      ),
    ));

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.tap(find.byType(OutlinedButton));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(documents.isEmpty, isTrue);
  });

  testWidgets('Topic no description does not save',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.tap(find.byType(OutlinedButton));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(documents.isEmpty, isTrue);
  });

  testWidgets('Topic inavlid article link does not save',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.enterText(find.byKey(const Key('linkField')), 'invalidLink');

    await tester.tap(find.byType(OutlinedButton));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(documents.isEmpty, isTrue);
  });

  testWidgets('Topic with valid article link saves',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.enterText(find.byKey(const Key('linkField')),
        'https://pub.dev/packages?q=cloud_firestore_mocks');

    await tester.tap(find.byType(OutlinedButton));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(
      documents.any(
        (doc) => doc.data()?['title'] == 'Test title',
      ),
      isTrue,
    );

    expect(
      documents.any(
        (doc) => doc.data()?['description'] == 'Test description',
      ),
      isTrue,
    );

    expect(
      documents.any(
        (doc) =>
            doc.data()?['articleLink'] ==
            'https://pub.dev/packages?q=cloud_firestore_mocks',
      ),
      isTrue,
    );
  });

  testWidgets('Test all form fields are present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
      ),
    ));

    expect(find.text('Title *'), findsOneWidget);

    expect(find.text('Description *'), findsOneWidget);

    expect(find.text('Link article'), findsOneWidget);

    expect(find.text('Upload a video'), findsOneWidget);
  });

  testWidgets('Navigates back after submitting form',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');
    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    expect(find.byType(CreateTopicScreen), findsNothing);
  });

  testWidgets('Navigates back after submitting form',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');
    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    expect(find.byType(CreateTopicScreen), findsNothing);
  });

  testWidgets('Uploaded video is successful and displays',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
      ),
    ));
    expect(find.text('Upload a video'), findsOneWidget);
    await tester.tap(find.byKey(const Key('uploadVideoButton')));
    await tester.pumpAndSettle();

    bool videoFound = false;
    final startTime = DateTime.now();
    while (!videoFound) {
      await tester.pump();

      if (find.text('Change video').evaluate().isNotEmpty) {
        videoFound = true;
        break;
      }

      if (DateTime.now().difference(startTime).inSeconds > 240) {
        fail('Timed out waiting for the "Change video" text to appear');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    expect(find.text('Change video'), findsOneWidget);

    expect(find.byType(Chewie), findsOneWidget);

    expect(find.byKey(const Key('deleteButton')), findsOneWidget);
  });
}
