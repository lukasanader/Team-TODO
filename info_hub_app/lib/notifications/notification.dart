class Notification {
  final String id;
  final String user;
  final String title;
  final String body;
  final DateTime timestamp;

  Notification({
    required this.id,
    required this.user,
    required this.title,
    required this.body,
    required this.timestamp,
  });
}
