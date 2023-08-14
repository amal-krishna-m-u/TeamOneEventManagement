import 'package:flutter/material.dart';
import 'package:TeamOne/pages/bill/display_pending_bill_client.dart';
import 'package:TeamOne/pages/bill/display_pending.dart';
import 'package:TeamOne/services/supabase_client.dart';
import 'package:TeamOne/pages/bill/generate_bill.dart';
import 'package:TeamOne/main.dart';
class DisplayPendingBillsEmp extends StatefulWidget {
  const DisplayPendingBillsEmp({super.key});

  @override
  State<DisplayPendingBillsEmp> createState() =>
      _DisplayPendingBillsEmpState();
}

class _DisplayPendingBillsEmpState extends State<DisplayPendingBillsEmp> {
  DatabaseServices db = DatabaseServices(client);
  List<Map<String, dynamic>> eventsData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final eventData = await db.fetchAllEventsWithConditions();
      setState(() {
        eventsData = eventData;
      });
    } catch (error) {
      print('Error fetching events: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a ThemeData object to use the same theme as ApproveEmp
    final ThemeData theme = ThemeData.from(
      colorScheme: ColorScheme.light(
        primary: Color(0xFF283747),
        secondary: Colors.white,
      ),
    );

    return Theme(
      data: theme, // Use the theme here
      child: Scaffold(
        appBar: AppBar(title: Text('Pending Bills for Employees')),
        body: eventsData.isNotEmpty
            ? ListView.builder(
                itemCount: eventsData.length,
                itemBuilder: (context, index) {
                  final event = eventsData[index];
                  return ListTile(
                    title: Text(
                      'Event: ${event['event_name']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Event ID: ${event['id']}',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Navigate to the generate bill page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GenerateBillEmp(eventId: event['id']),
                          ),
                        );
                      },
                      child: Text('Generate Bill'),
                    ),
                    onTap: () {
                      // Handle tapping on event
                    },
                  );
                },
              )
            : Center(child: Text('No pending bills for employees.')),
      ),
    );
  }
}
