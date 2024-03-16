import 'package:flutter/material.dart';
import 'package:info_hub_app/models/livestream.dart';

/*
 * Will be used to display the webinar live streams as a card 
 * similar to youtube's videos and thumbnails
 */
class WebinarCard extends StatelessWidget {
  final Livestream _webinarLivestream;

  const WebinarCard(this._webinarLivestream, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {},
        child: Container(
            child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(_webinarLivestream.title),
          ),
        )));
  }
}
