import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:TeamOne/services/supabase_client.dart';
import 'package:TeamOne/main.dart';
import 'package:TeamOne/pages/employee/edit_details.dart';

class EditEmployee extends StatefulWidget {
  const EditEmployee({Key? key}) : super(key: key);

  @override
  State<EditEmployee> createState() => _EditEmployeeState();
}

class _EditEmployeeState extends State<EditEmployee> {
  List<Map<String, dynamic>> employeeData = [];
  DatabaseServices db = DatabaseServices(client);

  @override
  void initState() {
    super.initState();
    fetchEmployeeData();
  }

  Future<void> fetchEmployeeData() async {
    try {
      final response = await db.selectAllData(tableName: 'employee');

      if (response != null) {
        setState(() {
          employeeData = response;
        });
      } else {
        showErrorMessage('Unable to fetch employee data.');
      }
    } catch (error) {
      showErrorMessage('An error occurred: $error');
    }
  }

  void showErrorMessage(String message) {
    Flushbar(
      message: message,
      duration: Duration(seconds: 3),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.light(
      primary: Color(0xFF283747),
      secondary: Colors.white,
    );

    return Theme(
      data: ThemeData.from(colorScheme: colorScheme),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Employees'),
        ),
        body: ListView.builder(
          itemCount: employeeData.length,
          itemBuilder: (context, index) {
            final employee = employeeData[index];

            return ListTile(
              title: Text(employee['name'] as String),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditDetails(userId: employee['userid']),
                    ),
                  );
                },
                child: Text('Edit'),
              ),
            );
          },
        ),
      ),
    );
  }
}
