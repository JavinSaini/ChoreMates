import 'package:flutter/material.dart';
import 'add_chore_screen.dart';
import 'edit_chore_screen.dart';
import 'profile_screen.dart';
import 'db_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChoresMateApp());
}

class ChoresMateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChoresMate',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Chore> chores = [];
  DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadChores();
  }

  void _loadChores() async {
    List<Chore> loadedChores = await _dbHelper.getChores();
    setState(() {
      chores = loadedChores;
      print("Chores loaded at start: ${chores.length}");
    });
  }

  void _addChore(Chore chore) async {
    await _dbHelper.saveChore(chore);
    setState(() {
      chores.add(chore);
      print("Chore added: ${chore.name}");
    });
  }

  List<Widget> get _widgetOptions => [
    ChoresListScreen(chores: chores),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChoresMate'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[200]!, Colors.blue[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Chores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddChoreScreen(onAddChore: _addChore)),
          );
        },
        tooltip: 'Add Chore',
        child: Icon(Icons.add),
      ),
    );
  }
}


// Remaining classes (ChoresListScreen, Chore, etc.) remain unchanged.


class ChoresListScreen extends StatefulWidget {
  final List<Chore> chores;

  ChoresListScreen({Key? key, required this.chores}) : super(key: key);

  @override
  _ChoresListScreenState createState() => _ChoresListScreenState();
}

class _ChoresListScreenState extends State<ChoresListScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.chores.length,
      itemBuilder: (context, index) {
        Chore chore = widget.chores[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            leading: Icon(Icons.task_alt, color: _getStatusColor(chore.status)),
            title: Text(chore.name, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Status: ${chore.status}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.orange),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditChoreScreen(chore: chore, onUpdateChore: (updatedChore) {
                          setState(() {
                            widget.chores[index] = updatedChore;
                          });
                        }),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    DBHelper().deleteChore(widget.chores[index].id);  // Delete chore from the database
                    setState(() {
                      widget.chores.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.red;
      case 'In Progress':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class Chore {
  String id;
  String name;
  String status;
  int points;

  Chore({required this.id, required this.name, required this.status, this.points = 10});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'points': points,
    };
  }

  static Chore fromMap(Map<String, dynamic> map) {
    return Chore(
      id: map['id'],
      name: map['name'],
      status: map['status'],
      points: map['points'],
    );
  }
}

