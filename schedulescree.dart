import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  CollectionReference schedulesCollection =
      FirebaseFirestore.instance.collection('schedules');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inspection Schedule',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: schedulesCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final schedules = snapshot.data!.docs
              .map((doc) => Schedule.fromSnapshot(doc))
              .toList();

          return ListView.builder(
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              return Card(
                child: ListTile(
                  title: Text(schedule.title),
                  subtitle: Text(
                      'Date: ${schedule.date.toString().substring(0, 10)}, Time: ${schedule.time.format(context)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => showDeleteConfirmationDialog(schedule),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddScheduleScreen(schedulesCollection)),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> deleteSchedule(Schedule schedule) async {
    try {
      await schedulesCollection.doc(schedule.id).delete();
      print('Schedule deleted from Firestore');
    } catch (error) {
      print('Failed to delete schedule: $error');
    }
  }

  Future<void> showDeleteConfirmationDialog(Schedule schedule) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Do you really want to delete this schedule?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteSchedule(schedule);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class AddScheduleScreen extends StatefulWidget {
  final CollectionReference schedulesCollection;

  AddScheduleScreen(this.schedulesCollection);

  @override
  _AddScheduleScreenState createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  void _showDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _showTimePicker() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _addSchedule() async {
    if (_titleController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      return;
    }

    final newSchedule = Schedule(
      title: _titleController.text,
      date: _selectedDate!,
      time: _selectedTime!,
      id: '',
    );

    await widget.schedulesCollection.add(newSchedule.toMap());
    print('Schedule added to Firestore');

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Schedule'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: _showDatePicker,
              child: Text(_selectedDate != null
                  ? 'Selected Date: ${_selectedDate!.toString().substring(0, 10)}'
                  : 'Select Date'),
            ),
            SizedBox(height: 8.0),
            TextButton(
              onPressed: _showTimePicker,
              child: Text(_selectedTime != null
                  ? 'Selected Time: ${_selectedTime!.format(context)}'
                  : 'Select Time'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addSchedule,
              child: Text('Add Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}

class Schedule {
  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay time;

  Schedule({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
  });

  Schedule.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot.id,
        title = (snapshot.data() as Map<String, dynamic>)['title'] as String,
        date = ((snapshot.data() as Map<String, dynamic>)['date'] as Timestamp).toDate(),
        time = TimeOfDay.fromDateTime(
            ((snapshot.data() as Map<String, dynamic>)['date'] as Timestamp).toDate());

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
    };
  }
}
