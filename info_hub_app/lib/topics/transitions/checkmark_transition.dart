import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CheckmarkAnimationScreen extends StatefulWidget {
  final Key? key;

  const CheckmarkAnimationScreen({this.key}) : super(key: key);

  @override
  _CheckmarkAnimationScreenState createState() =>
      _CheckmarkAnimationScreenState();
}

class _CheckmarkAnimationScreenState extends State<CheckmarkAnimationScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitDoubleBounce(
              color: Colors.green,
              size: 70.0,
            ),
            SizedBox(height: 20),
            Text(
              'Your changes are on the way..',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
