

import 'package:TeamOne/main.dart';
import 'package:TeamOne/pages/employee/edit_emp.dart';
import 'package:TeamOne/pages/employee/emp_manage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:TeamOne/pages/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:TeamOne/pages/dashboard/dashboard_screen.dart';
import 'package:TeamOne/pages/employee/edit_details.dart';
import 'package:TeamOne/services/supabase_config.dart';
import 'package:TeamOne/services/supabase_client.dart';

class EditDetails extends StatefulWidget {

  final String userId; // Declare the parameter

  const EditDetails({required this.userId, Key? key}) : super(key: key);


  @override
  _EditDetailsState createState() =>
      _EditDetailsState();
}

class _EditDetailsState extends State<EditDetails> {
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  bool _isSupervisor = false;
  bool _isLoading = true;



@override
  void initState() {
    super.initState();
    fetchExistingData(); // Call this method to fetch existing data
  }


Future<void> fetchExistingData() async {
    final supabase = Supabase.instance;

    final response = await supabase.client
        .from('employee')
        .select()
        .eq('userid', widget.userId)
        .execute();

    if (response.data.length > 0) {
      final existingData = response.data[0];
      setState(() {
        _fullNameController.text = existingData['name'] as String;
        _upiIdController.text = existingData['upi_id'] as String;
        _phoneNumberController.text = existingData['phone_number'] as String;
        _isSupervisor = existingData['is_supervisor'] as bool;
      });
    }
    _isLoading = false;
  }




  Future<void> submitDetails() async {
    final supabase = Supabase.instance;

    final response1 = await supabase.client
        .from('employee')
        .select()
        .eq('userid', widget.userId)
        .execute();
    if (response1.data.length == 0) {
      final response = await supabase.client.from('employee').insert([
        {
          'name': _fullNameController.text,
          'upi_id': _upiIdController.text,
          'phone_number': _phoneNumberController.text,
          'is_supervisor': _isSupervisor,
          'userid': widget.userId,
        },
      ]).execute();

      if (response.status != 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditEmployee(),
          ),
        );
        // Details submitted successfully
        // Navigate to the desired screen
      } else {
        // Handle error
        print('Error: ${response}');
      }
    } else {
//update the table
      final response = await supabase.client
          .from('employee')
          .update({
            'name': _fullNameController.text,
            'upi_id': _upiIdController.text,
            'phone_number': _phoneNumberController.text,
            'is_supervisor': _isSupervisor,
            'userid': widget.userId,
          })
          .eq('userid', widget.userId)
          .execute();
      if (response.status != 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditEmployee(),
          ),
        );
        // Details submitted successfully
        // Navigate to the desired screen
      } else {
        // Handle error
        print('Error: ${response}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme(
      primary: Color(0xFF283747), // Dark blue
      secondary: Colors.white, // White
      surface: Color.fromARGB(255, 200, 198, 198), // Light gray
      background: Colors.grey[300]!, // Light gray
      error: Colors.red, // Red
      onPrimary: Colors.white, // White (text/icon color on primary color)
      onSecondary: Colors.black, // Black (text/icon color on secondary color)
      onSurface:
          Color.fromARGB(255, 12, 12, 12), // Black (text color on surface)
      onBackground: Colors.black, // Black (text color on background)
      onError: Colors.white, // White (text color on error)
      brightness: Brightness.light, // Set to Brightness.light for light theme
    );

    final Color color = colorScheme.surface;
    final Color shadowcolor = colorScheme.onSurface.withOpacity(1);
    final Color surfacetint = colorScheme.secondary.withOpacity(0.8);
    final BorderRadius borderRadius = BorderRadius.all(Radius.circular(8.0));

    return  Theme(
      data: ThemeData.from(colorScheme: colorScheme),

    child :Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text('Additional Details'),
      ),
      body: _isLoading
            ? Center(
                child:
                    CircularProgressIndicator(), // Show loader while fetching data
              )
            :
      
      
      
      
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _upiIdController,
              decoration: InputDecoration(labelText: 'UPI ID'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            /* CheckboxListTile(
              title: Text('Is Supervisor'),
              value: _isSupervisor,
              onChanged: (newValue) {
                setState(() {
                  _isSupervisor = newValue ?? false;
                });
              },
            ),
            */
            SizedBox(height: 56),

            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    showConfirmationDialog('Confrim Updation ', 'This will update the userdetails throughout the system  ', () => submitDetails());

                  },
                  child: Text(
                    'Submit Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            
            

 SizedBox(width: 46),
            ElevatedButton(
              onPressed: () {
showConfirmationDialog('Confrim Deletion ', 'This will delete the user and all associated details inlcuding assignments and payment history ', () => deleteUser());
              },
              child: Text(
                'Delete User',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
              ],
              )




          ],
        ),
      ),
    
    
    
        
          
              bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          items: [
            // Placeholder item for Generate Bill
            BottomNavigationBarItem(
              icon: Icon(Icons.new_releases_outlined),
              label: ' Event Details',
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
  
Future<void> deleteUser() async {

  DatabaseServices db = DatabaseServices(client);

  final response = db.deleteData(tableName: 'employee', columnName: 'userid', columnValue: widget.userId);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EmpManage(),
    ),
  );
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
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              onConfirm(); // Call the provided function
            },
            child: Text('Confirm'),
          ),
        ],
      );
    },
  );
}



}
