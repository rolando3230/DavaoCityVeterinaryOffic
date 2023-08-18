import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateReport extends StatefulWidget {
  const CreateReport({
    Key? key,
    required this.postid,
  }) : super(key: key);

  final String postid;

  @override
  State<CreateReport> createState() => _CreateReportState();
}

class _CreateReportState extends State<CreateReport> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late TextEditingController establishment;
  late TextEditingController typeofmeat;
  late TextEditingController headcount;
  late TextEditingController kg;
  late TextEditingController condemned;
  late TextEditingController location;
  late DateTime selectedDate;
  String? currentLocation;
  late String selectedMeat; // Initialize selectedMeat with a default value

  String currentUserDisplayName = 'Unknown'; // Add this variable to hold the current user's display name

  @override
  void initState() {
    super.initState();
    establishment = TextEditingController();
    typeofmeat = TextEditingController();
    headcount = TextEditingController();
    kg = TextEditingController();
    condemned = TextEditingController();
    location = TextEditingController();
    selectedDate = DateTime.now();
    selectedMeat = 'Chicken'; // Set the default selected meat type
    getCurrentLocation();
    getCurrentUserDisplayName();
  }

  @override
  void dispose() {
    establishment.dispose();
    typeofmeat.dispose();
    headcount.dispose();
    kg.dispose();
    condemned.dispose();
    location.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Inspection Report'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Column(
            children: [
              _buildTextFieldWithTitle(
                controller: establishment,
                title: 'Establishment',
              ),
              _buildDropdownFieldWithTitle(
                title: 'Type of Meat',
              ),
              _buildNumericTextFieldWithTitle(
                controller: headcount,
                title: 'Headcount',
              ),
              _buildNumericTextFieldWithTitle(
                controller: kg,
                title: 'Kg',
              ),
              _buildNumericTextFieldWithTitle(
                controller: condemned,
                title: 'Condemned',
              ),
              _buildTextFieldWithTitle(
                controller: location,
                title: 'Location',
                readOnly: true,
              ),
              const SizedBox(height: 20.0),
              _buildSelectDateButton(),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  await getCurrentLocation();
                  createReport();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  primary: Theme.of(context).primaryColor, // Set button background color
                ),
                child: const Text(
                  'Add Report',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set text color
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithTitle({
    required TextEditingController controller,
    required String title,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0, // Set title text size
            color: Colors.blue, // Set title text color
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          color: Colors.grey[200], // Set text field background color
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: Color(0xFF0000B3), // Set text color
            ),
            readOnly: readOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: readOnly ? 'Fetching location...' : '',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildDropdownFieldWithTitle({
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0, // Set title text size
            color: Colors.blue, // Set title text color
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          color: Colors.grey[200], // Set dropdown field background color
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: DropdownButtonFormField<String>(
            value: selectedMeat,
            onChanged: (newValue) {
              setState(() {
                selectedMeat = newValue!;
              });
            },
            items: ['Chicken', 'Pork', 'Cattle', 'Fish', 'Goat'].map((meat) {
              return DropdownMenuItem<String>(
                value: meat,
                child: Text(meat),
              );
            }).toList(),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildNumericTextFieldWithTitle({
    required TextEditingController controller,
    required String title,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0, // Set title text size
            color: Colors.blue, // Set title text color
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          color: Colors.grey[200], //
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  if (!readOnly) {
                    int currentValue = int.tryParse(controller.text) ?? 0;
                    setState(() {
                      controller.text = (currentValue - 1).toString();
                    });
                  } 
                },
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number, // Set keyboard type to numeric
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only digits
                  style: const TextStyle(
                    color: Color(0xFF0000B3), // Set text color
                  ),
                  readOnly: readOnly,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: readOnly ? 'Fetching location...' : '',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  if (!readOnly) {
                    int currentValue = int.tryParse(controller.text) ?? 0;
                    setState(() {
                      controller.text = (currentValue + 1).toString();
                    });
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildSelectDateButton() {
    return Column(
      children: [
        Text(
          'Select Date:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: () async {
            await _selectDate();
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            primary: Theme.of(context).primaryColor, // Set button background color
          ),
          child: Text(
            DateFormat('yyyy-MM-dd').format(selectedDate),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Set text color
            ),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> createReport() async {
    try {
      final docUser = FirebaseFirestore.instance.collection('Report').doc();

      // Fetch the current user's display name from the state
      String submittedBy = currentUserDisplayName;

      final newReport = Report(
        typeofmeat: selectedMeat,
        establishment: establishment.text,
        headcount: headcount.text,
        kg: kg.text,
        condemned: condemned.text,
        postid: widget.postid,
        location: currentLocation ?? '',
        date: DateFormat('yyyy-MM-dd').format(selectedDate),
        submittedBy: submittedBy, // Use the current user's display name here
      );

      final json = newReport.toJson();
      await docUser.set(json);

      setState(() {
        establishment.text = '';
        typeofmeat.text = '';
        headcount.text = '';
        kg.text = '';
        condemned.text = '';
        location.text = '';
      });

      // Show success alert
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Report submitted successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error creating report: $e');
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to submit report. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      final permissionStatus = await Geolocator.checkPermission();
      if (permissionStatus == LocationPermission.denied ||
          permissionStatus == LocationPermission.deniedForever) {
        final permissionResult = await Geolocator.requestPermission();
        if (permissionResult != LocationPermission.whileInUse &&
            permissionResult != LocationPermission.always) {
          // Permission not granted, handle accordingly
          return;
        }
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks.first;
        final String formattedAddress =
            "${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
        setState(() {
          currentLocation = formattedAddress;
          location.text = currentLocation!;
        });
      }
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> getCurrentUserDisplayName() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
        if (userDoc.exists) {
          final name = userDoc.get('name'); // Fetch the 'name' field from the document
          if (name != null) {
            setState(() {
              currentUserDisplayName = name;
            });
          }
        }
      }
    } catch (e) {
      print('Error getting current user display name: $e');
    }
  }
}

class Report {
  final String typeofmeat;
  final String establishment;
  final String headcount;
  final String kg;
  final String condemned;
  final String postid;
  final String location;
  final String date;
  final String submittedBy;

  Report({
    required this.typeofmeat,
    required this.establishment,
    required this.headcount,
    required this.kg,
    required this.condemned,
    required this.postid,
    required this.location,
    required this.date,
    required this.submittedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'typeofmeat': typeofmeat,
      'establishment': establishment,
      'headcount': headcount,
      'kg': kg,
      'condemned': condemned,
      'postid': postid,
      'location': location,
      'date': date,
      'submittedBy': submittedBy,
    };
  }
}
