import 'topic_media_upload.dart' as topic_media_test;
import 'webinar_file_picker.dart' as webinar_file_test;
import 'package:integration_test/integration_test.dart';


void main(){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  topic_media_test.main();
  webinar_file_test.main();
}