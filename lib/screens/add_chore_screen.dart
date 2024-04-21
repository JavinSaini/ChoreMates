import 'package:flutter/material.dart';
import 'main.dart';

class AddChoreScreen extends StatefulWidget {
  final Function(Chore) onAddChore;

  AddChoreScreen({required this.onAddChore});

  @override
  _AddChoreScreenState createState() => _AddChoreScreenState();
}

class _AddChoreScreenState extends State<AddChoreScreen> {
  final TextEditingController _choreNameController = TextEditingController();
  String? _selectedStatus = 'Pending'; // Default status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Chore'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _choreNameController,
              decoration: InputDecoration(
                labelText: 'Chore Name',
                border: OutlineInputBorder(),
                fillColor: Colors.grey[200],
                filled: true,
              ),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedStatus,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue;
                });
              },
              items: <String>['Pending', 'In Progress', 'Completed']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // background (button) color
                onPrimary: Colors.white, // foreground (text) color
              ),
              child: Text('Add Chore'),
              onPressed: () {
                final newChore = Chore(
                  id: DateTime.now().toString(),
                  name: _choreNameController.text,
                  status: _selectedStatus!,
                );
                widget.onAddChore(newChore);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
