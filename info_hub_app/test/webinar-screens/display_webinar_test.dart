import 'dart:ffi';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:info_hub_app/webinar/webinar-screens/display_webinar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http_client/console.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'dart:io';


// class MyInAppWebViewPlatform extends PlatformInterface {
//   MyInAppWebViewPlatform() : super(token: _token);

//   static MyInAppWebViewPlatform? _instance;

//   // Token used for verifying the instance
//   static final Object _token = Object();

//   // Getter for the instance
//   static MyInAppWebViewPlatform? get instance => _instance;

//   // Setter for the instance
//   static set instance(MyInAppWebViewPlatform? instance) {
//     // Verify the instance using the token
//     PlatformInterface.verifyToken(instance!, _token);
//     _instance = instance;
//   }
// }

// // Mock implementation for testing
// class MockInAppWebViewPlatform extends MyInAppWebViewPlatform {
//   // Implement the necessary methods here if needed for testing
// }

class FakeBuildContext extends Fake implements BuildContext{}

class MockWebViewPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements InAppWebViewPlatform {}

class MockPlatformCookieManager extends Mock
    with MockPlatformInterfaceMixin
    implements PlatformCookieManager {}

class MockWebViewWidget extends Mock
    with MockPlatformInterfaceMixin
    implements PlatformInAppWebViewWidget {}

class FakeCookieParams extends Fake
    implements PlatformCookieManagerCreationParams {}

class FakeWebUri extends Fake implements WebUri {}

class FakeWidgetParams extends Fake
    implements PlatformInAppWebViewWidgetCreationParams {}

class MockWebViewDependencies {
  static const MethodChannel channel = MethodChannel('fk_user_agent');

  Future<void> init() async {
    registerFallbackValue(FakeCookieParams());
    registerFallbackValue(FakeWebUri());
    registerFallbackValue(FakeWidgetParams());
    registerFallbackValue(FakeBuildContext());

    // Mock webview widget
    final mockWidget = MockWebViewWidget();
    when(() => mockWidget.build(any())).thenReturn(const SizedBox.shrink());

    // Mock cookie manager
    final mockCookieManager = MockPlatformCookieManager();
    when(() => mockCookieManager.deleteAllCookies())
        .thenAnswer((_) => Future.value(true));
    when(() => mockCookieManager.setCookie(
          url: any(named: 'url'),
          name: any(named: 'name'),
          value: any(named: 'value'),
          path: any(named: 'path'),
          domain: any(named: 'domain'),
          expiresDate: any(named: 'expiresDate'),
          maxAge: any(named: 'maxAge'),
          isSecure: any(named: 'isSecure'),
          isHttpOnly: any(named: 'isHttpOnly'),
          sameSite: any(named: 'sameSite'),
          // ignore: deprecated_member_use
          iosBelow11WebViewController:
              any(named: 'iosBelow11WebViewController'),
          webViewController: any(named: 'webViewController'),
        )).thenAnswer((_) => Future.value(true));

    // Mock webview platform
    final mockPlatform = MockWebViewPlatform();
    when(() => mockPlatform.createPlatformInAppWebViewWidget(any()))
        .thenReturn(mockWidget);
    when(() => mockPlatform.createPlatformCookieManager(any()))
        .thenReturn(mockCookieManager);

    // Use mock
    InAppWebViewPlatform.instance = mockPlatform;

   

    // Mock user agent in setUp or setUpAll
    
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel,      
      (MethodCall methodCall) async {
      return {'webViewUserAgent': 'userAgent'};
    });
  }


  /// This double pump is needed for triggering the build of the webview
  /// otherwise it will fail
  Future<void> doublePump(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
  }
}

void main() {
  late UserModel testUser;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseStorage mockFirebaseStorage;
  late WebinarService webinarService;
  late Widget webinarScreen;
  late InAppWebViewPlatform? plat;
  final MockWebViewDependencies mockWebViewDependencies = MockWebViewDependencies();
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockFirebaseStorage = MockFirebaseStorage();
    webinarService = WebinarService(firestore: fakeFirestore, storage: mockFirebaseStorage);
    await mockWebViewDependencies.init();
    // MyInAppWebViewPlatform._instance = MockInAppWebViewPlatform();
    // InAppWebViewPlatform.instance!;
    // plat = InAppWebViewPlatform.instance;
    
    testUser = UserModel(
      uid: 'mockUid',
      firstName: 'John',
      lastName: 'Doe',
      roleType: 'Healthcare Professional',
      email: 'testemail@email.com',
      likedTopics: [],
      dislikedTopics: [],
    );


    webinarScreen = MaterialApp(
      home: WebinarScreen(
        webinarID: '123',
        youtubeURL: 'https://www.youtube.com/watch?v=tSXZ8hervyY',
        firestore: fakeFirestore,
        currentUser: testUser,
        title: 'Test',
        webinarService: webinarService,
        status: "Live"
      ),
    );

  });

  testWidgets('Test Webinar Title appears', (WidgetTester tester) async {
    provideMockedNetworkImages(() async {
      String url = await webinarService.uploadImageToStorage('webinar-thumbnails', newImage, '123');
      await fakeFirestore.collection('Webinars').add({
        'id' : '123',
        'title' : 'Test',
        'url' :  'https://www.youtube.com/watch?v=tSXZ8hervyY',
        'thumbnail' : url,
        'webinarleadname' : 'John Doe',
        'startTime' : DateTime.now().toString(),
        'views' : 0,
        'dateStarted' : DateTime.now().toString(),
        'status' : 'Live',
      });
      await tester.pumpWidget(webinarScreen);
      expect(find.text('Test'),findsOneWidget);
    });
  });

  testWidgets('Test Dialog appears successfully', (WidgetTester tester) async {
    provideMockedNetworkImages(() async {
      String url = await webinarService.uploadImageToStorage('webinar-thumbnails', newImage, '123');
      await fakeFirestore.collection('Webinars').add({
        'id' : '123',
        'title' : 'Test',
        'url' :  'https://www.youtube.com/watch?v=tSXZ8hervyY',
        'thumbnail' : url,
        'webinarleadname' : 'John Doe',
        'startTime' : DateTime.now().toString(),
        'views' : 0,
        'dateStarted' : DateTime.now().toString(),
        'status' : 'Live',
      });
      await tester.pumpWidget(webinarScreen);
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();
      expect(find.text('Webinar Guide and Expectations'), findsOneWidget);
    });
  });

  testWidgets('Test Dialog redirects back to main screen', (WidgetTester tester) async {
    provideMockedNetworkImages(() async {
      String url = await webinarService.uploadImageToStorage('webinar-thumbnails', newImage, '123');
      await fakeFirestore.collection('Webinars').add({
        'id' : '123',
        'title' : 'Test',
        'url' :  'https://www.youtube.com/watch?v=tSXZ8hervyY',
        'thumbnail' : url,
        'webinarleadname' : 'John Doe',
        'startTime' : DateTime.now().toString(),
        'views' : 0,
        'dateStarted' : DateTime.now().toString(),
        'status' : 'Live',
      });
      await tester.pumpWidget(webinarScreen);
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();
      expect(find.text('Webinar Guide and Expectations'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byWidget(webinarScreen), findsOneWidget);
    });

  });

  testWidgets('Test Live Viewers text appears', (WidgetTester tester) async {
    provideMockedNetworkImages(() async {
      String url = await webinarService.uploadImageToStorage('webinar-thumbnails', newImage, '123');
      await fakeFirestore.collection('Webinars').add({
        'id' : '123',
        'title' : 'Test',
        'url' :  'https://www.youtube.com/watch?v=tSXZ8hervyY',
        'thumbnail' : url,
        'webinarleadname' : 'John Doe',
        'startTime' : DateTime.now().toString(),
        'views' : 0,
        'dateStarted' : DateTime.now().toString(),
        'status' : 'Live',
      });
      await tester.pumpWidget(webinarScreen);
      expect(find.text('1 watching'), findsOneWidget);
    });

  });
}

R provideMockedNetworkImages<R>(R body()) {
  return HttpOverrides.runZoned(
    body,
    createHttpClient: (_) => _createMockImageHttpClient(_, _transparentImage),
  );
}

class MockHttpClient extends Mock implements HttpClient {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {}

class MockHttpHeaders extends Mock implements HttpHeaders {}

// Returns a mock HTTP client that responds with an image to all requests.
MockHttpClient _createMockImageHttpClient(
  SecurityContext? _,
  List<int> imageBytes,
) {
  final client = MockHttpClient();
  final request = MockHttpClientRequest();
  final response = MockHttpClientResponse();
  final headers = MockHttpHeaders();

  registerFallbackValue(Uri());
  when(() => client.getUrl(any<Uri>())).thenAnswer(
    (_) => Future<HttpClientRequest>.value(request),
  );
  when(() => request.headers).thenReturn(headers);
  when(request.close).thenAnswer(
    (_) => Future<HttpClientResponse>.value(response),
  );
  when(() => response.contentLength).thenReturn(_transparentImage.length);
  when(() => response.statusCode).thenReturn(HttpStatus.ok);
  when(() => response.listen(any())).thenAnswer((Invocation invocation) {
    final void Function(List<int>) onData = invocation.positionalArguments[0];
    final void Function() onDone = invocation.namedArguments[#onDone];
    final void Function(
      Object, [
      StackTrace,
    ]) onError = invocation.namedArguments[#onError];
    final bool cancelOnError = invocation.namedArguments[#cancelOnError];

    return Stream<List<int>>.fromIterable(<List<int>>[imageBytes]).listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  });
  return client;
}

const List<int> _transparentImage = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
];

Uint8List newImage = Uint8List.fromList(_transparentImage);