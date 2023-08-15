import 'package:flutter/material.dart';
import 'package:TeamOne/services/supabase_client.dart'; // Make sure to import the necessary packages
import 'package:TeamOne/main.dart';
import 'display_emp_bill.dart';

class GenerateBillEmp extends StatefulWidget {
  const GenerateBillEmp({Key? key, required this.eventId}) : super(key: key);

  final int eventId;

  @override
  State<GenerateBillEmp> createState() => _GenerateBillEmpState();
}

class _GenerateBillEmpState extends State<GenerateBillEmp> {
  DatabaseServices db =
      DatabaseServices(client); // Assuming you have the client instance

  List<Map<String, dynamic>> assignedEmployees = [];

  @override
  void initState() {
    super.initState();
    fetchAssignedEmployees();
  }

  Future<void> fetchAssignedEmployees() async {
    try {
      final assignedEmployeesData = await db.fetchAssignedEmployeesForEvent(
        eventId: widget.eventId,
      );
      setState(() {
        assignedEmployees = assignedEmployeesData;
      });
    } catch (error) {
      print('Error fetching assigned employees: $error');
    }
  }

  Future<List<Map<String, dynamic>>> fetchEmployeeDetails(
      List<int> employeeIds) async {
    try {
      final employeeDetailsList =
          await db.fetchEmployeeDetailsForIds(employeeIds);
      return employeeDetailsList;
    } catch (error) {
      print('Error fetching employee details: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Use the same theme as ApproveEmp
      data: ThemeData.from(
        colorScheme: ColorScheme.light(
          primary: Color(0xFF283747),
          secondary: Colors.white,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: Text('Generate Bill')),
        body: assignedEmployees.isNotEmpty
            ? FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchEmployeeDetails(
                    assignedEmployees.map((e) => e['emp_id'] as int).toList()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No assigned employees found.'));
                  } else {
                    final employeeDetailsList = snapshot.data!;
                    return ListView.builder(
                      itemCount: employeeDetailsList.length,
                      itemBuilder: (context, index) {
                        final employeeDetails = employeeDetailsList[index];
                        return ListTile(
                          title: Text(
                            'Employee: ${employeeDetails['name']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle:
                              Text('Employee ID: ${employeeDetails['id']}'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Navigate to create bill page for this employee
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DisplayEmpBill(
                                    eventId: widget.eventId,
                                    employeeId: employeeDetails['id'],
                                  ),
                                ),
                              );
                            },
                            child: Text('Create Bill'),
                          ),
                        );
                      },
                    );
                  }
                },
              )
            : Center(child: Text('No assigned employees for this event.')),
      ),
    );
  }
}

class CreateBillForEmployee extends StatelessWidget {
  final int eventId;
  final int employeeId;

  CreateBillForEmployee(
      {Key? key, required this.eventId, required this.employeeId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Bill')),
      body: Center(
        child: Text('Create bill for Event $eventId, Employee $employeeId'),
      ),
    );
  }
}
