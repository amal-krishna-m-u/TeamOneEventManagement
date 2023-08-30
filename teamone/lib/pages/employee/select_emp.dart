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
      employeeDataFuture = db.fetchAllEmployeesForEvent(eventId: widget.eventId);
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
                return Center(child: Text('No employees found for the selected event.'));
              } else {
                final employeeData = snapshot.data!;
                return ListView.builder(
                  itemCount: employeeData.length,
                  itemBuilder: (context, index) {
                    final employee = employeeData[index];
                    final employeeName = employee['name'];
                    final employeeId = employee['id'];
                    final issup = employee['is_supervisor'];
                    return ListTile(
                      title: Text('$employeeName                 supervisor : $issup'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              // Approve employee and insert into the assign table
                            //  await db.insertIntoAssign(eventId: widget.eventId, employeeId: employeeId);
                              // Set 'approve' to true in event_employee_request table
                              await db.updateEmployeeApproval(eventId: widget.eventId, employeeId: employeeId, approve: true);
                              // Refresh the data
                              await _refreshData();
                              refreshKey.currentState?.show();
                            },
                            child: Text('Approve'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              // Delete record from the event_employee_request table
                              await db.deleteEventEmployeeRequest(eventId: widget.eventId, employeeId: employeeId);
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
