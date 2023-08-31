import 'package:flutter/material.dart';
import 'package:TeamOne/services/supabase_client.dart';
import 'package:TeamOne/main.dart';

class SelectEmp extends StatefulWidget {
  final int eventId;

  const SelectEmp({required this.eventId, Key? key}) : super(key: key);

  @override
  State<SelectEmp> createState() => _SelectEmpState();
}

class _SelectEmpState extends State<SelectEmp> {
  DatabaseServices db = DatabaseServices(client);
  late Future<List<Map<String, dynamic>>> employeeDataFuture;
  late GlobalKey<RefreshIndicatorState> refreshKey;

  @override
  void initState() {
    super.initState();
    employeeDataFuture = db.fetchAllEmployeesForEvent(eventId: widget.eventId);
    refreshKey = GlobalKey<RefreshIndicatorState>();
  }

  Future<void> _refreshData() async {
    setState(() {
      employeeDataFuture =
          db.fetchAllEmployeesForEvent(eventId: widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.from(
        colorScheme: ColorScheme.light(
          primary: Color(0xFF283747), // Dark shade of grey
          secondary: Colors.white,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Select Employees'),
        ),
        body: RefreshIndicator(
          key: refreshKey,
          onRefresh: _refreshData,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: employeeDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text('No employees found for the selected event.'));
              } else {
                final employeeData = snapshot.data!;
                return ListView.builder(
                  itemCount: employeeData.length,
                  itemBuilder: (context, index) {
                    final employee = employeeData[index];
                    final employeeName = employee['name'];
                    final employeeId = employee['id'];
                    final issup = employee['is_supervisor'];
                    final careoff = employee['careoff'];
                    return ListTile(
                      title: Text('\n $employeeName \n supervisor : $issup'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              // Show a dialog to confirm the careoff number
                              final careoffController = TextEditingController(
                                  text: careoff.toString());
                              bool confirm = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Confirm Careoff'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Enter Careoff Number:'),
                                        SizedBox(height: 8),
                                        TextField(
                                          controller: careoffController,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(
                                              context, false); // Cancel
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(
                                              context, true); // Confirm
                                        },
                                        child: Text('Confirm'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm == true) {
                                // Update the database with the edited careoff number
                                final editedCareoff =
                                    int.tryParse(careoffController.text);
                                if (editedCareoff != null) {
                                  await db.updateEmployeeApproval(
                                      eventId: widget.eventId,
                                      employeeId: employeeId,
                                      approve: true,
                                      careoff: editedCareoff);
                                  // Refresh the data
                                  await _refreshData();
                                  refreshKey.currentState?.show();
                                }
                              }
                            },
                            child: Text('Approve'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              // Delete record from the event_employee_request table
                              await db.deleteEventEmployeeRequest(
                                  eventId: widget.eventId,
                                  employeeId: employeeId);
                              // Refresh the data
                              await _refreshData();
                              refreshKey.currentState?.show();
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
