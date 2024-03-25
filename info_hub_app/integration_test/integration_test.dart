import 'package:integration_test/integration_test.dart';
import '../topic_media_upload_test.dart' as testOne;
import '../webinar_file_picker_test.dart' as testTwo;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testOne.main();
}
