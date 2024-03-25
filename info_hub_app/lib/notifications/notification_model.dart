class Notification {
  final String id;
  final String uid;
  final String title;
  final String body;
  final DateTime timestamp;
  final String route;
  bool deleted;

  Notification({
    required this.id,
    required this.uid,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.route,
    required this.deleted,
  });
}
