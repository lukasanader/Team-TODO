
class Livestream {
  final String webinarID;
  final String title;
  final String image;
  final String youtubeURL;
  final String startedBy;
  final int viewers;
  final String startTime;
  final String status;
  final bool chatEnabled;
  final List<String> selectedTags;

  Livestream({
    required this.webinarID,
    required this.title,
    required this.image,
    required this.viewers,
    required this.youtubeURL,
    required this.startedBy,
    required this.startTime,
    required this.status,
    required this.chatEnabled,
    required this.selectedTags,
  });

  factory Livestream.fromMap(Map<String, dynamic> map) {
    return Livestream(
      webinarID: map['id'],
      title: map['title'] ?? '',
      youtubeURL: map['url'] ?? '',
      image: map['thumbnail'] ?? '',
      startedBy : map['webinarleadname'] ?? '',
      startTime: map['startTime'] ?? '',
      viewers: map['views'] ?? '',
      status: map['status'] ?? '',
      chatEnabled: map['chatenabled'] ?? false,
      selectedTags: List<String>.from(map['selectedtags'] ?? []),
    );
  }
}
