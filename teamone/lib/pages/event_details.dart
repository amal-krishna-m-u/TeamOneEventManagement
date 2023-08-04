import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TeamOne/main.dart';
import 'package:TeamOne/pages/dashboard_screen.dart';
import 'package:TeamOne/pages/event_details.dart';
import 'package:TeamOne/services/supabase_client.dart';
import 'package:TeamOne/services/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum TimelineStatus {
  notStarted,
  workInProgress,
  workCompleted,
  paymentReceived,
  paymentClosed,
}

class MyEventsDetails extends StatefulWidget {
  final String eventName;
  const MyEventsDetails({Key? key, required this.eventName}) : super(key: key);

  @override
  State<MyEventsDetails> createState() => _MyEventDetailsState();
}

class _MyEventDetailsState extends State<MyEventsDetails> {
  final client = SupabaseClient(supabaseUrl, supabaseKey);
  List<Map<String, dynamic>> tableData = [];

  List<String> events = [];
  List<String> places = [];
  List<int> numberParticipants = [];
  List<int> employees = [];

  @override
  void initState() {
    super.initState();
    AuthServices authServices = AuthServices(client);
    if (authServices.isLoggedin()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    }

    fetchEventsFromSupabase();
  }

  Future<void> fetchEventsFromSupabase() async {
    String name = widget.eventName;
    final response = await client
        .from('events')
        .select()
        .eq('event_name', name) // Add the condition for name
        .limit(1) // Limit the result to 1 row
        .execute();

    if (response.data != null) {
      final data = response.data as List<dynamic>;

      if (data.isNotEmpty) {
        final event = data.first;

        setState(() {
          tableData = [
            {
              'name': event['event_name']?.toString() ?? '',
              'place': event['event_place']?.toString() ?? '',
              'participants': event['participants'] as int? ?? 0,
              'employees': event['no_of_employees'] as int? ?? 0,
            }
          ];
        });
      } else {
        // No matching event found
        setState(() {
          events = [];
          places = [];
          numberParticipants = [];
          employees = [];
        });
      }
    } else {
      // Handle error
      print('Error fetching events from Supabase: ${response.data.toString()}');
    }
  }
         
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventName),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to a separate screen to display event details
            },
            icon: Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to a separate screen to display event details
              },
              child: Text('Event Details'),
            ),
            SizedBox(height: 20),
            // Place other widgets here as needed
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              // Implement the logic to add or assign employees to the event
            },
            icon: Icon(Icons.person_add),
            label: Text('Assign Employee'),
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () {
              // Implement the logic to add or assign resources to the event
            },
            icon: Icon(Icons.inventory),
            label: Text('Assign Resources'),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

