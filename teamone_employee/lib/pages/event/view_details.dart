import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teamone_employee/main.dart';
import 'package:teamone_employee/pages/event/event_request.dart';
import 'package:teamone_employee/pages/dashboard/dashboard_screen.dart';
import 'package:teamone_employee/services/supabase_client.dart';

class ViewDetails extends StatefulWidget {
final eventId;

  const ViewDetails({Key? key, required this.eventId}) : super(key: key);

  @override
  State<ViewDetails> createState() => _ViewDetailsState();
}

class _ViewDetailsState extends State<ViewDetails> {
  DatabaseServices db = DatabaseServices(client);
  int? employeeId; // Initialize as nullable
  TextEditingController _careoffsController =TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchEmployeeId();
  }

  Future<void> fetchEmployeeId() async {
    AuthServices auth = AuthServices(client);
    final userid = auth.getUserId();
    final employeeData = await db.fetchData(
        tableName: 'employee', columnName: 'userid', columnValue: userid);

    if (employeeData.isNotEmpty) {
      setState(() {
        employeeId = employeeData[0]['id'];
      });
    }
  }

  Future<bool> checkExistingRequest(int eventId, int? employeeId) async {
    final requestData = await db.fetchData(
        tableName: 'event_employee_request',
        columnName: 'event_id',
        columnValue: eventId.toString());

    bool exists = false;

    for (final request in requestData) {
      final eventMatches = request['event_id'] == eventId;
      final employeeMatches =
          employeeId != null && request['employee_id'] == employeeId;

      if (eventMatches && employeeMatches) {
        exists = true;
        break; // Exit the loop early since we found a match
      }
    }

    return exists;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.from(
        colorScheme: ColorScheme.light(
          primary: Color(0xFF283747),
          secondary: Colors.white,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'View Event Details',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event Details Page',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Here you can view event details.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 30),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: db.fetchData(
                    tableName: 'events',
                    columnName: 'id',
                    columnValue: widget.eventId.toString()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No event data available.');
                  } else {
                    final eventData = snapshot.data![0];
                    final eventName = eventData['event_name'];
                    final eventDate = eventData['event_date'];
                    final participants = eventData['participants'];
                    final employees = eventData['no_of_employees'];
                    final eventManagement = eventData['event_management_team'];
                    final place = eventData['event_place'];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Event Name: $eventName'),
                        SizedBox(height: 5),
                        Text('Event Date: $eventDate'),
                        SizedBox(height: 5),
                        Text('Number of participants: $participants'),
                        SizedBox(height: 5),
                        Text('Number of employees required: $employees'),
                        SizedBox(height: 5),
                        Text('Event Management Team: $eventManagement'),
                        SizedBox(height: 5),
                        Text('Event Place: $place'),
                        SizedBox(height: 15),
                        //input careoff here 
                        Text('Number of careoff ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),),
                        Text('(if only you insert 1 )'),
                      TextField(
                        
                controller: _careoffsController,
                keyboardType: TextInputType.number,
              ),
                        if (employeeId != null)
                          ElevatedButton(
                            onPressed: () async {
                              final requestExists = await checkExistingRequest(
                                  widget.eventId, employeeId);

                              if (!requestExists) {
                                db.insertData(
                                  tableName: 'event_employee_request',
                                  data: {
                                    'event_id': widget.eventId,
                                    'employee_id': employeeId,
                                    'careoff':int.parse(_careoffsController.text)
                                  },
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EventRequest(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'You have already requested this event.'),
                                  ),
                                );
                              }
                            },
                            child: Text('Request Event'),
                          ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Dashboard(),
                    ),
                  );
                },
                icon: Icon(Icons.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

