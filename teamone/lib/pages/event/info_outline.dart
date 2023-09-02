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
  List<String> empName = [];
  List<int> careoffperemp = [];
  int totalCareoffs = 0;
  List<int> assignid = [];
  bool tap = true;

  TextEditingController eventsController = TextEditingController();
  TextEditingController placesController = TextEditingController();
  TextEditingController numberParticipantsController = TextEditingController();
  TextEditingController employeesController = TextEditingController();
  TextEditingController event_startedController = TextEditingController();
  TextEditingController event_completedController = TextEditingController();
  TextEditingController payment_receivedController = TextEditingController();
  TextEditingController payment_completedController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController event_typeController = TextEditingController();
  TextEditingController event_teamController = TextEditingController();
  TextEditingController eventnameController = TextEditingController();

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
        builder: (context) => info_outline(
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
            {
              'eventids': events['id'] as int ?? 0,
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
          eventid = tableData[0]['eventids'] as int;
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
          eventids = [];
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
   return Theme(
      data: ThemeData.from(
        colorScheme: ColorScheme.light(
          primary: Color(0xFF283747),
          secondary: Colors.white,
        ),
      ),
    
    
   child: Scaffold(
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
        actions: [
          IconButton(
            onPressed: () => editDetails(eventid),
            icon: Icon(Icons.date_range), // Replace with your desired icon
            tooltip: "Select Date Range", // Optional tooltip
          ),
        ],
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
                            onLongPress: () {


showConfirmationDialog('Confrim Employee Unassignment', 'Are You sure you want to unassign this employee,this will unassign the employee and his careoffs ', () => removeempfromevent(assignid[i]));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'employee: ${empName[i]}.'),
                                ),
                              );
                            },
                          ),
                    ],
                  );
                },
              ),
      ),
    
    
    
          
              bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          items: [
            // Placeholder item for Generate Bill
            BottomNavigationBarItem(
              icon: Icon(Icons.new_releases_outlined),
              label: ' Event Info',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
          ],
          onTap: (index) {
            if (index == 1) {
              // Navigate to the Dashboard class
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Dashboard()),
              );
            }
          },
        ),
    
    
    
    
    
    
   )
    
    
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
        int careoffs = careoffsData[0]['careoff'];
        assignid.add(careoffsData[0]['id']);

        totalCareoff += careoffs;

        final empData = await db.fetchData(
            tableName: 'employee',
            columnName: 'id',
            columnValue: employeeId.toString());
        if (empData.isNotEmpty && empData[0]['name'] != null && tap) {
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

  Future<void> removeempfromevent(id) async {
    DatabaseServices db = DatabaseServices(client);
    print('assign id is :$id');

    db.deleteData(
        tableName: 'assign', columnName: 'id', columnValue: id.toString());
  }



Future<void> editDetails(int eventid) async {



        eventsController.text = tableData[0]['eventname']?.toString() ?? '';
      placesController.text  = tableData[0]['place']?.toString() ?? '';
      numberParticipantsController.text  = tableData[0]['participants']?.toString() ?? '';
      employeesController.text  = tableData[0]['employees']?.toString() ?? '';
     event_startedController.text  = tableData[0]['event_started'];
      event_completedController.text = tableData[0]['event_completed'];
      payment_receivedController.text  = tableData[0]['payment_received'];
      payment_completedController.text  = tableData[0]['payment_completed'];
      dateController.text  = tableData[0]['event_date']?.toString() ?? '';
      event_typeController.text  = tableData[0]['event_type']?.toString() ?? '';
      event_teamController.text  = tableData[0]['event_team'].toString();


  DateTime selectedDate = DateTime.now(); // Initialize with current date
/*
  // Show a date picker dialog to select the event date
  selectedDate = (await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  ))!;
*/
  if (selectedDate != null) {
    // User selected a date, format it as needed
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Event Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: TextEditingController(text: formattedDate), // Set the selected date
                  readOnly: true, // Make it read-only
                  onTap: () async {
                    // Show the date picker again when the date field is tapped
                    selectedDate = (await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    ))!;
                    if (selectedDate != null) {
                      // Update the date field with the selected date
                      formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
                      dateController.text = formattedDate;
                    }
                  },
                  decoration: InputDecoration(labelText: 'Event Date'),
                ),
                TextFormField(
                  controller: eventsController,
                  decoration: InputDecoration(labelText: 'Event Name'),
                ),
                TextFormField(
                  controller: placesController,
                  decoration: InputDecoration(labelText: 'Event Place'),
                ),
                TextFormField(
                  controller: numberParticipantsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Participants'),
                ),
                TextFormField(
                  controller: employeesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'No. of Employees'),
                ),
                
                TextFormField(
                  controller: event_startedController,
                  decoration: InputDecoration(labelText: 'Event Started'),
                ),
                TextFormField(
                  controller: event_completedController,
                  decoration: InputDecoration(labelText: 'Event Completed'),
                ),
                TextFormField(
                  controller: payment_receivedController,
                  decoration: InputDecoration(labelText: 'Payment Received'),
                ),
                TextFormField(
                  controller: payment_completedController,
                  decoration: InputDecoration(labelText: 'Payment Completed'),
                ), 
                TextFormField(
                  controller: event_typeController,
                  decoration: InputDecoration(labelText: 'Event Type'),
                ),
                TextFormField(
                  controller: event_teamController,
                  decoration: InputDecoration(labelText: 'Event Management Team'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Generate a Supabase update query to update the event details
              final response = await client
  .from('events')
  .update({
    'event_name': eventsController.text != 'null' ? eventsController.text : null,
    'event_place': placesController.text != 'null' ? placesController.text : null,
    'participants': numberParticipantsController.text != 'null' ? int.parse(numberParticipantsController.text) : null,
    'no_of_employees': employeesController.text != 'null' ? int.parse(employeesController.text) : null,
    'event_started': event_startedController.text != 'null' ? event_startedController.text : null,
    'event_completed': event_completedController.text != 'null' ? event_completedController.text : null,
    'payment_received': payment_receivedController.text != 'null' ? payment_receivedController.text : null,
    'payment_completed': payment_completedController.text != 'null' ? payment_completedController.text : null,
    'event_date': formattedDate.isNotEmpty ? formattedDate : null,
    'event_type': event_typeController.text.isNotEmpty ? event_typeController.text : null,
    'event_management_team': event_teamController.text.isNotEmpty ? event_teamController.text : null,
  })
  .eq('id', eventid)
  .execute();

                if (response.status == 200 ||
                    response.status == 202 ||
                    response.status == 204) {
                  // Successful update
                  print('Event details updated successfully.');
                  // Close the dialog
                  Navigator.of(context).pop();
                  // You might want to refresh the UI to reflect the changes
                  // by calling a function to fetch updated data.
                  fetchEventsFromSupabase();
                } else {
                  // Error occurred while updating
                  print('Error updating event details: ${response.status}');
                  // Display an error message to the user if needed.
                  // You can use Flushbar or any other method for this.
                  // For example:
                  Flushbar(
                    title: 'Error',
                    message: 'Failed to update event details. Please try again.',
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  )..show(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}









Future<void> showConfirmationDialog(String title, String message, Function() onConfirm) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
              // Close the dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Employee remains assigned.'),
                                ),
                              ); 
              
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              onConfirm();
              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Employee Unassigned.'),
                                ),
                              ); // Call the provided function
            },
            child: Text('Confirm'),
          ),
        ],
      );
    },
  );
}

}
