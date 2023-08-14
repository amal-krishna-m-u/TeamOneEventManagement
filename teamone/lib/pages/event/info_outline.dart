import 'package:TeamOne/pages/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:TeamOne/pages/dashboard/dashboard_screen.dart';
import 'package:TeamOne/pages/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_client.dart';
import '../../services/supabase_config.dart';

class info_outline extends StatefulWidget {
  final String event;

  const info_outline({Key? key, required this.event}) : super(key: key);

  @override
  State<info_outline> createState() => _info_outlineState();
}

class _info_outlineState extends State<info_outline> {
  final client = SupabaseClient(supabaseUrl, supabaseKey);
  List<Map<String, dynamic>> tableData = [];
  bool isLoading = true;

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
  List<String> event_team = [];
  List<String> eventname = [];

  @override
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
    String name = widget.event;
    final response = await client
        .from('events')
        .select()
        .eq('event_name', name) // Add the condition for name
        .limit(1) // Limit the result to 1 row
        .execute();

    print('Response data: ${response.data}');

    if (response.data != null) {
      final data = response.data as List<dynamic>;

      if (data.isNotEmpty) {
        final events = data.first;

        setState(() {
          tableData = [
            {
              'eventname': events['event_name']?.toString() ?? '',
              'place': events['event_place']?.toString() ?? '',
              'participants': events['participants'] as int? ?? 0,
              'employees': events['no_of_employees'] as int? ?? 0,
              'event_started': events['event_started'].toString(),
              'event_completed': events['event_completed'].toString(),
              'payment_received': events['payment_received'].toString(),
              'payment_completed': events['payment_completed'].toString(),
              'date': DateFormat('dd-MM-yyyy').format(
                  DateTime.parse(events['event_date']?.toString() ?? '')),
              'event_type': events['event_type']?.toString() ?? '',
              'event_team': events['event_management_team']?.toString() ?? '',
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
          eventname = [];
        });
      }
    } else {
      // Handle error
      print('Error fetching events from Supabase: ${response.data.toString()}');
    }
    setState(() {
      isLoading =
          false; // Set isLoading to false when data fetching is complete
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColorScheme.appColorScheme.secondary,
        ),
        backgroundColor: AppColorScheme.appColorScheme.primary,
        title: Text(
          'Info',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColorScheme.appColorScheme.secondary,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator(), // Show loader while fetching data
            )
          : ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                final item = tableData[0];
                return ListBody(
                  children: [
                    ListTile(
                      title: Text('Event Name:     ${item['eventname']}'),
                      subtitle: Text('Date:    ${item['date']}'),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                          'EVENT MANAGEMENT TEAM:     ${item['event_team']}'),
                      subtitle: Text('EVENT TYPE:     ${item['event_type']}'),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('PLACE :      ${item['place']}'),
                      subtitle: Text(
                          'PARTICIPANTS :           ${item['participants'].toString()}'), // Use 'participants' instead of 'number_participants'
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                          'EMPLOYEES :      ${item['employees'].toString()}'), // Use 'employees' instead of 'no_of_employees'
                    ),
                    Divider(),
                  ],
                );
              },
            ),
    );
  }
}
