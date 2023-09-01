import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamone_employee/pages/dashboard/dashboard_screen.dart';
import 'package:teamone_employee/pages/event/view_details.dart';
import 'package:teamone_employee/services/supabase_client.dart';
import 'package:teamone_employee/services/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:teamone_employee/main.dart';

class EventRequest extends StatefulWidget {
  const EventRequest({Key? key}) : super(key: key);

  @override
  State<EventRequest> createState() => _EventRequestState();
}

class _EventRequestState extends State<EventRequest> {
  DatabaseServices db = DatabaseServices(client);
  DateTime? startDate = DateTime.now();
  DateTime? endDate;

  void _selectDateRange(BuildContext context) async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023), // Replace with your desired start date
      lastDate: DateTime(2030),  // Replace with your desired end date
    );

    if (pickedRange != null) {
      setState(() {
        startDate = pickedRange.start;
        endDate = pickedRange.end;
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
            'Event Request',
            style: TextStyle(
              color: Colors.white,
            ),
          ),



          actions: [
    IconButton(
      onPressed: () => _selectDateRange(context),
      icon: Icon(Icons.date_range), // Replace with your desired icon
      tooltip: "Select Date Range", // Optional tooltip
    ),
  ],

        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event Request Page',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Here you can request a Work.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 30),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: db.selectAllData(tableName: 'events'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No event data available.');
                    } else {
                      final currentDate = DateTime.now();
                      final formattedCurrentDate =
                          DateTime(currentDate.year, currentDate.month, currentDate.day);

                      final filteredEvents = snapshot.data!.where((event) {
                        final eventDate = DateTime.parse(event['event_date']);
                        return (startDate == null || eventDate.isAfter(startDate!.add(Duration(days: -1)))) &&
                            (endDate == null || eventDate.isBefore(endDate!.add(Duration(days: 1))));
                      }).toList();

                      if (filteredEvents.isEmpty) {
                        return Text('No events found within the selected date range.');
                      }

                      filteredEvents.sort((a, b) {
                        final aDate = DateTime.parse(a['event_date']);
                        final bDate = DateTime.parse(b['event_date']);
                        return aDate.compareTo(bDate);
                      });

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: filteredEvents.map((event) {
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
                              child: Text(
                                '\nEvent:\n\t$eventName\n\nDate:\n\t$eventDate\n',
                              ),
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
