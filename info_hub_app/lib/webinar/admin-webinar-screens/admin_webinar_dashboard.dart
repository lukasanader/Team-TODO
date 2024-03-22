import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/webinar/admin-webinar-screens/create_webinar_screen.dart';
import 'package:info_hub_app/webinar/admin-webinar-screens/stats_cards.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:info_hub_app/webinar/webinar-screens/webinar_view.dart';

class WebinarDashboard extends StatefulWidget {
  final UserModel user;
  final FirebaseFirestore firestore;
  final WebinarService webinarService;

  const WebinarDashboard({
    super.key,
    required this.user,
    required this.firestore,
    required this.webinarService
    });

  @override
  _WebinarDashboardState createState() => _WebinarDashboardState();
}

class _WebinarDashboardState extends State<WebinarDashboard> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Webinar Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Webinar Analytics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  StreamBuilder<String>(
                    stream: Stream.fromFuture(widget.webinarService.getNumberOfLiveWebinars()),
                    builder: (context, snapshot) {
                      return StatisticCard(
                        label: 'Live Webinars',
                        value: snapshot.data ?? '',
                        icon: Icons.play_circle_filled,
                        color: Colors.green,
                      );
                    },
                  ),
                  StreamBuilder<String>(
                    stream: Stream.fromFuture(widget.webinarService.getNumberOfUpcomingWebinars()),
                    builder: (context, snapshot) {
                      return StatisticCard(
                        label: 'Upcoming Webinars',
                        value: snapshot.data ?? '',
                        icon: Icons.schedule,
                        color: Colors.blue,
                      );
                    },
                  ),
                  StreamBuilder<String>(
                    stream: Stream.fromFuture(widget.webinarService.getNumberOfLiveViewers()),
                    builder: (context, snapshot) {
                      return StatisticCard(
                        label: 'Live Viewers',
                        value: snapshot.data ?? '',
                        icon: Icons.visibility,
                        color: Colors.orange,
                      );
                    },
                  ),
                  StreamBuilder<String>(
                    stream: Stream.fromFuture(widget.webinarService.getNumberOfArchivedWebinars()),
                    builder: (context, snapshot) {
                      return StatisticCard(
                        label: 'Archived Webinars',
                        value: snapshot.data ?? '',
                        icon: Icons.archive,
                        color: Colors.grey,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (BuildContext context) {
                        return WebinarView(
                          firestore: widget.firestore,
                          user: widget.user,
                          webinarService: widget.webinarService,
                        );
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'View Webinars',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (BuildContext context) {
                        return CreateWebinarScreen(
                          firestore: widget.firestore,
                          user: widget.user,
                          webinarService: widget.webinarService,
                        );
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Create Webinars',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
