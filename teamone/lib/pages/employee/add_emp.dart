import 'package:flutter/material.dart';
import 'package:TeamOne/services/supabase_client.dart';
import 'package:TeamOne/main.dart';

class AssignEmp extends StatefulWidget {
  final String eventName;

  const AssignEmp({Key? key, required this.eventName}) : super(key: key);

  @override
  State<AssignEmp> createState() => _AssignEmpState();
}

class _AssignEmpState extends State<AssignEmp> {
  List<Map<String, dynamic>> unassignedEmployees = [];
  DatabaseServices db = DatabaseServices(client);
  int? eventId;
  int assignedEmployeeCount = 0;

  @override
  void initState() {
    super.initState();
    fetchEventIdAndUnassignedEmployees();
  }

  Future<void> fetchEventIdAndUnassignedEmployees() async {
    eventId = await db.getEventIdByEventName(widget.eventName);

    if (eventId != null) {
      await fetchUnassignedEmployees();
    } else {
      // Handle error: Event not found or ID not available
    }
  }

  Future<void> fetchUnassignedEmployees() async {
    final assignedEmployeeData = await db.fetchAssignedEmployeesForEvent(
      eventId: eventId!, // Use the fetched event ID
    );

    assignedEmployeeCount = assignedEmployeeData.length;

    final allEmployeeData = await db.selectAllData(tableName: 'employee');
    final Set<int> assignedEmployeeIds = Set.from(
      assignedEmployeeData.map((data) => data['emp_id'] as int),
    );

    final List<Future<Map<String, dynamic>>> unassignedEmployeeDataFutures = [];

    for (final data in allEmployeeData) {
      final employeeId = data['id'] as int;
      if (!assignedEmployeeIds.contains(employeeId)) {
        unassignedEmployeeDataFutures.add(db.fetchData(
          tableName: 'employee',
          columnName: 'id',
          columnValue: employeeId.toString(),
        ).then((value) => value[0]));
      }
    }

    final unassignedEmployeeList = await Future.wait(unassignedEmployeeDataFutures);
    setState(() {
      unassignedEmployees = unassignedEmployeeList;
    });
  }

  Future<void> assignEmployee(int employeeId) async {
    try {
      await db.insertIntoAssign(
        eventId: eventId!,
        employeeId: employeeId,
      );

      // Refresh the screen
      fetchUnassignedEmployees();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error assigning employee.'),
        ),
      );
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
          title: Text('Unassigned Employees'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Assigned Employees: $assignedEmployeeCount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: unassignedEmployees.length,
                itemBuilder: (context, index) {
                  final unassignedEmployee = unassignedEmployees[index];

                  return ListTile(
                    title: Text(unassignedEmployee['name'] as String),
                    subtitle: Text('ID: ${unassignedEmployee['id']}'),
                    trailing: ElevatedButton(
                      onPressed: () =>
                          assignEmployee(unassignedEmployee['id'] as int),
                      child: Text('Assign'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
