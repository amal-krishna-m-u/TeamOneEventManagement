import 'package:TeamOne/pages/components/my_timeline_tile.dart';
import 'package:TeamOne/pages/event/info_outline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TeamOne/main.dart';
import 'package:TeamOne/pages/dashboard/dashboard_screen.dart';
import 'package:TeamOne/pages/event/event_details.dart';
import 'package:TeamOne/services/supabase_client.dart';
import 'package:TeamOne/services/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  List<String> event_started = [];
  List<String> event_completed = [];
  List<String> payment_received = [];
  List<String> payment_completed = [];
  List<String> date = [];
  List<String> event_type = [];
  List<String>event_team = [];



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
              'place': event['event_place']?.toString() ?? '',
              'participants': event['participants'] as int? ?? 0,
              'employees': event['no_of_employees'] as int? ?? 0,
              'event_started': event['event_started'].toString(),
              'event_completed': event['event_completed'].toString(),
              'payment_received': event['payment_received'].toString(),
              'payment_completed': event['payment_completed'].toString(),
              'date': DateFormat('dd-MM-yyyy')
                  .format(DateTime.parse(event['event_date']?.toString() ?? '')),
              'event_type': event['event_type']?.toString() ?? '',
              'event_team': event['event_management_team']?.toString() ?? '',

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
          event_started = [];
          event_completed = [];
          payment_received = [];
          payment_completed = [];
          date = [];
          event_type = [];
          event_team = [];
          
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
            Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => info_outline(event: widget.eventName),
  ),
);


              // Navigate to a separate screen to display event details
            },
            icon: Icon(Icons.info_outline),
          ),
        ],
      ),
      body: ListView(
        children: [
          MyTimeLineTile(
              isFirst: true,
              isLast: false,
              isPast: true,
              eventCard: Text("Event Created"),
              heroIndex: 1),
          MyTimeLineTile(
            isFirst: false,
            isLast: false,
            isPast: tableData[0]['event_started'] == '1' ? true : false,
            eventCard: Text('Event Started'),
            heroIndex: 2,
          ),
          MyTimeLineTile(
              isFirst: false,
              isLast: false,
              isPast: tableData[0]['event_completed'] == '1' ? true : false,
              eventCard: Text('Event  Completed'),
              heroIndex: 3),
          MyTimeLineTile(
              isFirst: false,
              isLast: false,
              isPast: tableData[0]['payment_received'] == '1' ? true : false,
              eventCard: Text('Payment Recieved from Client'),
              heroIndex: 4),
          MyTimeLineTile(
              isFirst: false,
              isLast: true,
              isPast: tableData[0]['payment_completed'] == '1' ? true : false,
              eventCard: Text("Payment Completed to Employees"),
              heroIndex: 5),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            backgroundColor: Colors.white,
            onPressed: () {



              
              // Implement the logic to add or assign employees to the event
            },
            icon: Icon(Icons.person_add),
            label: Text('Assign Employee'),
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            //error thrown here
            backgroundColor: Colors.white,
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
