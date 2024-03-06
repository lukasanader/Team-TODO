class Livestream {
  final String title;
  final String image;
  final String uid;
  final String lastName;
  final int viewers;
  final String channelId;

  Livestream({
    required this.title,
    required this.image,
    required this.uid,
    required this.lastName,
    required this.channelId,
    required this.viewers,
  });

  factory Livestream.fromMap(Map<String, dynamic> map) {
    return Livestream(
      title: map['title'] ?? '',
      image: map['thumbnail'] ?? '',
      uid: map['uid'] ?? '',
      lastName : map['webinarleadlname'] ?? '',
      viewers: map['views'] ?? '',
      channelId: map['channelId'] ?? '',
    );
  }
}
