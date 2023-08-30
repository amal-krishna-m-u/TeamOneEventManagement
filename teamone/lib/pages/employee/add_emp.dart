import 'package:flutter/material.dart';
import 'package:TeamOne/services/supabase_client.dart';
import 'package:TeamOne/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  int totalAssignedCareoffs = 0;

  @override
  void initState() {
    super.initState();
    fetchEventIdAndUnassignedEmployees();
  }

  Future<void> fetchEventIdAndUnassignedEmployees() async {
    eventId = await db.getEventIdByEventName(widget.eventName);

    if (eventId != null) {
      await fetchUnassignedEmployees();
      await fetchTotalAssignedCareoffs();
    } else {
      // Handle error: Event not found or ID not available
    }
  }

  Future<void> fetchUnassignedEmployees() async {
    final assignedEmployeeData = await db.fetchAssignedEmployeesForEvent(
      eventId: eventId!,
    );

    final allEmployeeData = await db.selectAllData(tableName: 'employee');
    final Set<int> assignedEmployeeIds = Set.from(
      assignedEmployeeData.map((data) => data['emp_id'] as int),
    );

    final List<Future<Map<String, dynamic>>> unassignedEmployeeDataFutures = [];

    for (final data in allEmployeeData) {
      final employeeId = data['id'] as int;
      if (!assignedEmployeeIds.contains(employeeId)) {
        unassignedEmployeeDataFutures.add(db
            .fetchData(
              tableName: 'employee',
              columnName: 'id',
              columnValue: employeeId.toString(),
            )
            .then((value) => value[0]));
      }
    }

    final unassignedEmployeeList =
        await Future.wait(unassignedEmployeeDataFutures);
    setState(() {
      unassignedEmployees = unassignedEmployeeList;
    });
  }

  Future<void> fetchTotalAssignedCareoffs() async {
    final assignedEmployeeData = await db.fetchAssignedEmployeesForEvent(
      eventId: eventId!,
    );

    int totalCareoffs = 0;

    for (final data in assignedEmployeeData) {
      final employeeId = data['emp_id'] as int;
      final careoffsData = await db.fetchData(
        tableName: 'assign',
        columnName: 'emp_id',
        columnValue: employeeId.toString(),
      );

      if (careoffsData.isNotEmpty) {
        final careoffs = careoffsData[0]['careoff'] as int;
        print(careoffs);
        totalCareoffs += careoffs;
      }
    }

    setState(() {
      totalAssignedCareoffs = totalCareoffs;
    });
  }

  Future<void> assignEmployee(int employeeId, int careoffs) async {
    try {
      await db.insertIntoAssign(
        eventId: eventId!,
        employeeId: employeeId,
        careoff: careoffs,
      );

      // Refresh the screen
      fetchUnassignedEmployees();
      fetchTotalAssignedCareoffs();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error assigning employee.'),
        ),
      );
    }
  }

  final TextEditingController _careoffsController = TextEditingController();

  Future<void> _showCareoffsDialog(int employeeId) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assign Employee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter Careoffs:'),
              TextField(
                controller: _careoffsController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                assignEmployee(employeeId, int.parse(_careoffsController.text));
              },
              child: Text('Assign'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _careoffsController.dispose();
    super.dispose();
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
                'Total Assigned Careoffs: $totalAssignedCareoffs',
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
                          _showCareoffsDialog(unassignedEmployee['id'] as int),
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
