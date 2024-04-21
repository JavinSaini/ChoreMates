import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'event_bus.dart';  // Ensure correct import based on your project's directory structure
import 'points_event.dart';  // Ensure correct import based on your project's directory structure

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();

  static Future<void> addPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final currentPoints = prefs.getInt('totalPoints') ?? 0;
    final newTotalPoints = currentPoints + points;
    await prefs.setInt('totalPoints', newTotalPoints);
    eventBus.fire(PointsUpdateEvent(newTotalPoints));  // Notify the application of the point update
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  int totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    eventBus.on<PointsUpdateEvent>().listen((event) {
      setState(() {
        totalPoints = event.newPoints;  // Update points dynamically when event is received
      });
    });
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('name') ?? '';
      bioController.text = prefs.getString('bio') ?? '';
      totalPoints = prefs.getInt('totalPoints') ?? 0;
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameController.text);
    await prefs.setString('bio', bioController.text);
    await prefs.setInt('totalPoints', totalPoints);  // Save points as part of the profile
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: bioController,
                      decoration: InputDecoration(
                        labelText: 'Bio',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                      ),
                      onPressed: _saveProfile,
                      child: Text('Save Profile'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Total Points: $totalPoints',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
