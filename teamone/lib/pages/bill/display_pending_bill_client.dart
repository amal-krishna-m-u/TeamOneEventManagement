import 'package:TeamOne/main.dart';
import 'package:TeamOne/pages/bill/generate_bill_client.dart';
import 'package:flutter/material.dart';
import 'package:TeamOne/services/supabase_client.dart';
import 'package:TeamOne/pages/bill/generate_bill_client.dart';

class DisplayPendingBillsClient extends StatefulWidget {
  const DisplayPendingBillsClient({Key? key}) : super(key: key);

  @override
  State<DisplayPendingBillsClient> createState() =>
      _DisplayPendingBillsClientState();
}

class _DisplayPendingBillsClientState extends State<DisplayPendingBillsClient> {
  DatabaseServices db = DatabaseServices(client);
  List<Map<String, dynamic>> pendingEvents = [];

  @override
  void initState() {
    super.initState();
    fetchPendingEvents();
  }

  Future<void> fetchPendingEvents() async {
    try {
      final events = await db.fetchAllEventsWithConditionsclient(
      );
      setState(() {
        pendingEvents = events;
      });
    } catch (error) {
      print('Error fetching pending events: $error');
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
          title: Text('Pending Bills for Clients'),
        ),
        body: pendingEvents.isNotEmpty
            ? ListView.builder(
                itemCount: pendingEvents.length,
                itemBuilder: (context, index) {
                  final event = pendingEvents[index];

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
                        // Navigate to the BillClient class
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BillClient(
                              eventId: event['id'],
                            ),
                          ),
                        );
                      },
                      child: Text('Generate Bill'),
                    ),
                  );
                },
              )
            : Center(child: Text('No pending bills for clients.')),
      ),
    );
  }
}
