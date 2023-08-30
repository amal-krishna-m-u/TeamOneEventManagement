

import 'package:TeamOne/pages/app_colors.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:TeamOne/pages/dashboard/dashboard_screen.dart';
import 'package:TeamOne/pages/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_client.dart';
import '../../services/supabase_config.dart';
import 'package:TeamOne/services/supabase_client.dart';

class info_outline extends StatefulWidget {
  final String event;

  const info_outline({Key? key, required this.event}) : super(key: key);

  @override
  State<info_outline> createState() => _info_outlineState();
}

class _info_outlineState extends State<info_outline> {
   var eventid;
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
List<String> eventids = [];
List <String> empName =[];
List <int> careoffperemp =[];
int totalCareoffs =0;
List <int> assignid =[];
bool tap = true;


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
    //fetchTotalAssignedCareoffs();
    
  }


  Future<void> _refreshData() async {
    // Implement the data refreshing logic here
 Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                   info_outline (
                                                  event: widget.event,
                                                ),
                                              ),
                                            );
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
            {'eventids': events['id'] as int ?? 0,
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
             eventid = tableData[0]['eventids'] as int ;
             print('event id in setsate $eventid');
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
          eventids=[];
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
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading
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
                            'EMPLOYEES :      ${item['employees'].toString()}.          Total careoff: $totalCareoffs'),
                            onTap: () => fetchTotalAssignedCareoffs(),
                            
                            // Use 'employees' instead of 'no_of_employees'
                      ),
                      Divider(),
                          if (empName.isNotEmpty && careoffperemp.isNotEmpty)
        for (int i = 0; i < empName.length; i++)
          ListTile(
            title: Text('Employee Name: ${empName[i]}'),
            subtitle: Text('Careoff: ${careoffperemp[i]}'),
            onLongPress:(){  removeempfromevent(assignid[i]);
              ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unassigned employee: ${empName[i]}.'),
            ),
          );},
          ),
      
                   
                    ],
                  );
                },
              ),
      ),
    );
  }
Future<void> fetchTotalAssignedCareoffs() async {


  DatabaseServices db = DatabaseServices(client);

   int totalCareoff = 0;

   //set the values in empName to [] 
 
  final assignedEmployeeData = await db.fetchAssignedEmployeesForEvent(
    eventId: eventid,
  );

 

  for (final data in assignedEmployeeData) {
    final employeeId = data['emp_id'] as int;
    final careoffsData = await db.fetchData(
      tableName: 'assign',
      columnName: 'emp_id',
      columnValue: employeeId.toString(),
    );
    if (careoffsData.isNotEmpty && careoffsData[0]['careoff'] != null) {
      int  careoffs = careoffsData[0]['careoff'];
      assignid.add(careoffsData[0]['id']);
   
      totalCareoff += careoffs;




      final empData = await db.fetchData(tableName: 'employee', columnName: 'id', columnValue: employeeId.toString());
      if (empData.isNotEmpty && empData[0]['name']!= null && tap){
        
empName.add(empData[0]['name']);
          careoffperemp.add(careoffs);
       



      }
    }
  

  


}
   tap = false;
  print('Total Assigned Careoffs: $totalCareoffs');





  setState(() {
totalCareoffs = totalCareoff;
    // Here, you might want to update your UI with the totalCareoffs value.
  });
}

  Future <void>removeempfromevent ( id) async{



  DatabaseServices db = DatabaseServices(client);
  print('assign id is :$id');

db.deleteData(tableName: 'assign', columnName: 'id', columnValue: id.toString());


  }
}