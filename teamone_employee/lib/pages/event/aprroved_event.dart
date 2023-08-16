import 'package:flutter/material.dart';
import 'package:teamone_employee/pages/dashboard/dashboard_screen.dart';
import 'package:teamone_employee/services/supabase_client.dart';
import 'package:teamone_employee/main.dart';
import 'package:teamone_employee/pages/event/view_details.dart';

class ApprovedEvent extends StatefulWidget {
  const ApprovedEvent({Key? key}) : super(key: key);

  @override
  State<ApprovedEvent> createState() => _ApprovedEventState();
}

class _ApprovedEventState extends State<ApprovedEvent> {
  DatabaseServices db = DatabaseServices(client);
  int? employeeId; // Initialize as nullable

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
            'Approved Events',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Approved Events',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Here you can see your approved Work.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 30),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: db.fetchAllJoinEventData(userId: employeeId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Display a loading indicator
                    } else if (snapshot.hasError) {
                      // Error message
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No event data available.');
                    } else {
                      final upcomingEvents = snapshot.data!.where((event) {
                        return event['event_completed'] != '1';
                      }).toList();

                      if (upcomingEvents.isEmpty) {
                        return Text('No upcoming events.');
                      }

                      upcomingEvents.sort((a, b) {
                        final aDate = DateTime.parse(a['event_date']);
                        final bDate = DateTime.parse(b['event_date']);
                        return aDate.compareTo(bDate);
                      });

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: upcomingEvents.map((event) {
                          final eventName = event['event_name'];
                          final eventDate = event['event_date'];
                          final eventId = event['id'];
                          return Padding(
                            padding: EdgeInsets.only(left: 10, top: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewDetails(
                                      eventId: eventId,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF283747),
                              ),
                              child: Text('Event: $eventName  ||  Date: $eventDate'),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
                SizedBox(height: 30),
                Text(
                  'All Assigned Work',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Here you can see events assigned to you.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 30),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: db.fetchAssignedEvents(employeeId: employeeId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Display a loading indicator
                    } else if (snapshot.hasError) {
                      // Error message
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No assigned event data available.');
                    } else {
                      final assignedEvents = snapshot.data!.where((event) {
                        return event['event_completed'] != '1';
                      }).toList();

                      if (assignedEvents.isEmpty) {
                        return Text('No assigned events.');
                      }

                      assignedEvents.sort((a, b) {
                        final aDate = DateTime.parse(a['event_date']);
                        final bDate = DateTime.parse(b['event_date']);
                        return aDate.compareTo(bDate);
                      });

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: assignedEvents.map((event) {
                          final eventName = event['event_name'];
                          final eventDate = event['event_date'];
                          final eventId = event['id'];
                          return Padding(
                            padding: EdgeInsets.only(left: 10, top: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewDetails(
                                      eventId: eventId,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF283747),
                              ),
                              child: Text('Event: $eventName || Date: $eventDate'),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
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
