
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/webinar/views/admin-webinar-screens/create_webinar_screen.dart';
import 'package:info_hub_app/webinar/helpers/stats_cards.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/webinar/controllers/webinar_controller.dart';
import 'package:info_hub_app/webinar/views/webinar-screens/webinar_view.dart';

class WebinarDashboard extends StatefulWidget {
  final UserModel user;
  final FirebaseFirestore firestore;
  final WebinarController webinarController;

  const WebinarDashboard(
      {super.key,
      required this.user,
      required this.firestore,
      required this.webinarController});

  @override
  _WebinarDashboardState createState() => _WebinarDashboardState();
}

class _WebinarDashboardState extends State<WebinarDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Webinar Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Webinar Analytics',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  StreamBuilder<String>(
                    stream: Stream.fromFuture(
                        widget.webinarController.getNumberOfLiveWebinars()),
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
                    stream: Stream.fromFuture(
                        widget.webinarController.getNumberOfUpcomingWebinars()),
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
                    stream: Stream.fromFuture(
                        widget.webinarController.getNumberOfLiveViewers()),
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
                    stream: Stream.fromFuture(
                        widget.webinarController.getNumberOfArchivedWebinars()),
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
                          webinarController: widget.webinarController,
                        );
                      },
                    ),
                  );
                },
                child: const Text(
                  'View Webinars',
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
                          webinarController: widget.webinarController,
                        );
                      },
                    ),
                  );
                },
                child: const Text(
                  'Create Webinars',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
