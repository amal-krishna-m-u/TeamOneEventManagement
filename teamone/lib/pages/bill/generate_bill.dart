import 'package:TeamOne/pages/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:TeamOne/services/supabase_client.dart'; // Import necessary packages
import 'display_emp_bill.dart';
import 'package:TeamOne/main.dart';

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

  Future<bool> doesPaymentExist(int employeeId, int eventId) async {
    final response = await client
        .from('payment')
        .select()
        .eq('emp_id', employeeId)
        .eq('event_id', eventId)
        .execute();

    if (response.status == 200) {
      final data = response.data as List<dynamic>;
      return data.isNotEmpty; // Return true if there are any entries
    } else {
      throw response;
    }
  }

  Future<void> _refreshData() async {
    // Implement the data refreshing logic here
 Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                   GenerateBillEmp (
                                                  eventId: widget.eventId,
                                                ),
                                              ),
                                            );
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
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: assignedEmployees.isNotEmpty
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
                          final employeeId = employeeDetails['id'] as int;

                          return ListTile(
                            title: Text(
                              'Employee: ${employeeDetails['name']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('Employee ID: $employeeId'),
                            trailing: FutureBuilder<bool>(
                              future: doesPaymentExist(
                                  employeeId, widget.eventId),
                              builder: (context, paymentSnapshot) {
                                if (paymentSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (paymentSnapshot.hasError) {
                                  return Text(
                                      'Error: ${paymentSnapshot.error}');
                                } else {
                                  final paymentExists =
                                      paymentSnapshot.data ?? false;

                                  return paymentExists
                                      ? Text('Payment Exists')
                                      : ElevatedButton(
                                          onPressed: () {
                                            // Navigate to create bill page for this employee
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DisplayEmpBill(
                                                  eventId: widget.eventId,
                                                  employeeId: employeeId,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text('Create Bill'),
                                        );
                                }
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                )
              : Center(
                  child: Text('No assigned employees for this event.'),
                ),
        ),


        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          items: [
            // Placeholder item for Generate Bill
            BottomNavigationBarItem(
              icon: Icon(Icons.pending_actions),
              label: 'Generate Bill',
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
      ),
    );
  }
}
