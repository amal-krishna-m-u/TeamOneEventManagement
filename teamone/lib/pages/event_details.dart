import 'package:flutter/material.dart';
import 'package:smartdeckapp/pages/dashboard_screen.dart';
import 'package:smartdeckapp/pages/register_screen.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smartdeckapp/services/supabase_config.dart';
import 'package:smartdeckapp/services/supabase_client.dart';
import 'package:smartdeckapp/main.dart';

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
        .eq('name', name) // Add the condition for name
        .limit(1) // Limit the result to 1 row
        .execute();

    if (response.data != null) {
      final data = response.data as List<dynamic>;

      if (data.isNotEmpty) {
        final event = data.first;

        setState(() {
tableData = [
          {
            'name': event['name']?.toString() ?? '',
            'place': event['place']?.toString() ?? '',
            'participants': event['participants'] as int? ?? 0,
            'employees': event['employees'] as int? ?? 0,
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
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          children: [
            /*Text('Events: ${events.join(", ")}'),
            Text('Places: ${places.join(", ")}'),
            Text('Number of Participants: ${numberParticipants.join(", ")}'),
            Text('Employees: ${employees.join(", ")}'),
            ElevatedButton(
              onPressed: fetchEventsFromSupabase,
              child: Text('Refresh events Status'),
            ),*/
           Expanded(
              child: Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bar_chart_rounded,
                            size: 20,
                            color: Colors.black,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Event Status',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 28,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row( 
                        children: [
                          Icon(
                            Icons.event_note_rounded,
                            size: 20,
                            color: Colors.black,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Event Name',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(width: 30),
                          Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.black,
                          ),
                          
                          Text(
                            'Total participants',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            )
                          ),
                          
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: tableData.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(tableData[index]['name'],
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  )
                              ),
                              subtitle: Text(tableData[index]['place'],
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  )
                              ),
                              leading: Icon(Icons.event),
                              trailing: Text(tableData[index]['participants']
                                  .toString(),
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  )

                                  ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          
          
          ],
        ),
      ),
    );
  }
}
