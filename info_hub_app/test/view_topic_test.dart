import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/topics/view_topic.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

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

class MockUrlLauncher extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  String? url;
  PreferredLaunchMode? launchMode;
  bool? useSafariVC;
  bool? useWebView;
  bool? enableJavaScript;
  bool? enableDomStorage;
  bool? universalLinksOnly;
  Map<String, String>? headers;

  bool? response;

  bool closeWebViewCalled = false;
  bool canLaunchCalled = false;
  bool launchCalled = false;

  void setCanLaunchExpectations(String url) {
    this.url = url;
  }

  void setLaunchExpectations({
    required String url,
    PreferredLaunchMode? launchMode,
    bool? useSafariVC,
    bool? useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
  }) {
    this.url = url;
    this.launchMode = launchMode;
    this.useSafariVC = useSafariVC;
    this.useWebView = useWebView;
    this.enableJavaScript = enableJavaScript;
    this.enableDomStorage = enableDomStorage;
    this.universalLinksOnly = universalLinksOnly;
    this.headers = headers;
  }

  void setResponse(bool response) {
    this.response = response;
  }

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async {
    expect(url, this.url);
    canLaunchCalled = true;
    return response!;
  }

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    expect(url, this.url);
    expect(options.webViewConfiguration.enableJavaScript, enableJavaScript);
    expect(options.webViewConfiguration.enableDomStorage, enableDomStorage);
    expect(options.webViewConfiguration.headers, headers);
    launchCalled = true;
    return response!;
  }

  @override
  Future<void> closeWebView() async {
    closeWebViewCalled = true;
  }
}

void main() {
  late MockUrlLauncher mock;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  setUp(() {
    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@example.com',
    );

    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    firestore = FakeFirebaseFirestore();

    firestore.collection('Users').doc('user123').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    final fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();

    VideoPlayerPlatform.instance = fakeVideoPlayerPlatform;

    mock = MockUrlLauncher();
    UrlLauncherPlatform.instance = mock;
  });

  testWidgets('ViewTopicScreen shows title', (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0,
      'dislikes': 0,
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
    ));
    await tester.pumpAndSettle();

    expect(find.text('no video topic'), findsOneWidget);

    expect(find.text('Test Description'), findsOneWidget);
  });

  testWidgets('ViewTopicScreen shows correct fields with video',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();

    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl':
          'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
      'likes': 0,
      'dislikes': 0,
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    // Pass a valid URL when creating the VideoPlayerController instance
    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
    ));
    await tester.pumpAndSettle();

    expect(find.text('video topic'), findsOneWidget);

    expect(find.text('Test Description'), findsOneWidget);

    expect(find.widgetWithText(ElevatedButton, 'Read Article'), findsOneWidget);

    expect(find.byType(Chewie), findsOneWidget);
  });

  testWidgets('Test article link opens', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();

    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'video topic',
      'description': 'Test Description',
      'articleLink': 'http://www.javatpoint.com/heap-sort',
      'videoUrl':
          'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
      'likes': 0,
      'dislikes': 0,
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();
    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
    ));

    mock
      ..setLaunchExpectations(
        url: 'http://www.javatpoint.com/heap-sort',
        useSafariVC: false,
        useWebView: false,
        universalLinksOnly: false,
        enableJavaScript: true,
        enableDomStorage: true,
        headers: <String, String>{},
      )
      ..setResponse(true);

    final elevatedButton = find.widgetWithText(ElevatedButton, 'Read Article');
    expect(elevatedButton, findsOneWidget);

    await tester.tap(elevatedButton);

    await tester.pumpAndSettle();
  });

  testWidgets('Test orientation changes correctly with video fullscreen',
      (tester) async {
    final logs = [];
    final firestore = FakeFirebaseFirestore();

    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'video topic',
      'description': 'Test Description',
      'articleLink': 'http://www.javatpoint.com/heap-sort',
      'videoUrl':
          'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
      'likes': 0,
      'dislikes': 0,
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (methodCall) async {
      if (methodCall.method == 'SystemChrome.setPreferredOrientations') {
        logs.add((methodCall.arguments as List)[0]);
      }
      return null;
    });

    expect(logs.length, 0);

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
    ));

    await tester.pumpAndSettle();

    expect(find.byType(Chewie), findsOneWidget);

    final Chewie chewieWidget = tester.widget<Chewie>(find.byType(Chewie));

    chewieWidget.controller.enterFullScreen();
    await tester.pumpAndSettle();

    expect(logs.length, 1,
        reason:
            'It should have added an orientation log after the fullscreen entry');

    chewieWidget.controller.exitFullScreen();

    expect(logs.length, 2,
        reason:
            'It should have added an orientation log after the fullscreen exit');

    expect(logs.last, 'DeviceOrientation.portraitUp',
        reason:
            'It should be in the portrait view after the fullscreen actions done');

    await tester.pumpAndSettle();
  });

  testWidgets('ViewTopicScreen shows like and dislike buttons',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0,
      'dislikes': 0,
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.thumb_up), findsOneWidget);
    expect(find.byIcon(Icons.thumb_down), findsOneWidget);
  });

  testWidgets('Test tapping thumb up icon increments likes by one',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // Add a topic with initial likes count of 0
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0, // Initial likes count
      'dislikes': 0,
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    // Create the ViewTopicScreen widget with the test topic
    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
    ));
    await tester.pumpAndSettle();

    // Tap the thumb up icon
    await tester.tap(find.byIcon(Icons.thumb_up));

    await tester.pumpAndSettle();

    DocumentSnapshot topicSnapshot = await topicDocRef.get();

    // Verify that the 'likes' field has been incremented by one
    expect(topicSnapshot['likes'], 1);
  });

  testWidgets('Test tapping thumb down icon increments dislikes by one',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // topic with initial likes and dislikes count of 0
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0, // Initial likes count
      'dislikes': 0,
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
    ));
    await tester.pumpAndSettle();

    // Tap the thumb up icon
    await tester.tap(find.byIcon(Icons.thumb_down));

    await tester.pumpAndSettle();

    DocumentSnapshot topicSnapshot = await topicDocRef.get();

    // Verify that the 'disikes' field has been incremented by one
    expect(topicSnapshot['dislikes'], 1);
  });

  testWidgets('Test tapping dislike button removes past like',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // Add a topic with initial likes count of 0
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0, // Initial likes count
      'dislikes': 0,
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    // Create the ViewTopicScreen widget with the test topic
    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
    ));
    await tester.pumpAndSettle();

    // Tap the thumb up icon
    await tester.tap(find.byIcon(Icons.thumb_up));

    // Wait for the asynchronous operations to complete
    await tester.pumpAndSettle();

    // Retrieve the updated topic document from Firestore
    DocumentSnapshot topicSnapshot = await topicDocRef.get();

    // Verify that the 'likes' field has been incremented by one
    expect(topicSnapshot['likes'], 1);

    // Tap the thumb up icon
    await tester.tap(find.byIcon(Icons.thumb_down));

    // Wait for the asynchronous operations to complete
    await tester.pumpAndSettle();

    // Retrieve the updated topic document from Firestore
    DocumentSnapshot dislikeSnapshot = await topicDocRef.get();

    // Verify that the 'likes' field has been incremented by one
    expect(dislikeSnapshot['dislikes'], 1);

    // check that likes field is back to 0
    expect(dislikeSnapshot['likes'], 0);
  });

  testWidgets('Test tapping like button removes past dislike',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // topic with initial likes and dislikes count of 0
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0, // Initial likes count
      'dislikes': 0,
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
    ));
    await tester.pumpAndSettle();

    // dislike topic
    await tester.tap(find.byIcon(Icons.thumb_down));

    await tester.pumpAndSettle();

    DocumentSnapshot topicSnapshot = await topicDocRef.get();

    // Verify that the 'dislikes' field has been incremented by one
    expect(topicSnapshot['dislikes'], 1);

    // like topic
    await tester.tap(find.byIcon(Icons.thumb_up));

    await tester.pumpAndSettle();

    DocumentSnapshot likeSnapshot = await topicDocRef.get();

    // Verify that the 'likes' field has been incremented by one
    expect(likeSnapshot['likes'], 1);

    // check that dislikes field is back to 0
    expect(likeSnapshot['dislikes'], 0);
  });

  testWidgets('Test tapping like button twice removes like',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // topic with initial likes and dislikes count of 0
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0, // Initial likes count
      'dislikes': 0,
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
    ));
    await tester.pumpAndSettle();

    // Like topic
    await tester.tap(find.byIcon(Icons.thumb_up));

    await tester.pumpAndSettle();

    DocumentSnapshot topicSnapshot = await topicDocRef.get();

    // Verify that the 'likes' field has been incremented by one
    expect(topicSnapshot['likes'], 1);

    // like topic again
    await tester.tap(find.byIcon(Icons.thumb_up));

    // Wait for the asynchronous operations to complete
    await tester.pumpAndSettle();

    DocumentSnapshot likeSnapshot = await topicDocRef.get();

    // Verify that the 'dislikes' field has been reset
    expect(likeSnapshot['likes'], 0);
  });

  testWidgets('Test tapping dislike button twice removes dislike',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0,
      'dislikes': 0,
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
    ));
    await tester.pumpAndSettle();

    // dislike topic
    await tester.tap(find.byIcon(Icons.thumb_down));

    await tester.pumpAndSettle();

    DocumentSnapshot topicSnapshot = await topicDocRef.get();

    // Verify that the 'dislikes' field has been incremented by one
    expect(topicSnapshot['dislikes'], 1);

    // dislike topic again
    await tester.tap(find.byIcon(Icons.thumb_down));

    await tester.pumpAndSettle();

    DocumentSnapshot dislikeSnapshot = await topicDocRef.get();

    // Verify that the 'dislikes' field has been reset

    expect(dislikeSnapshot['dislikes'], 0);
  });
}
