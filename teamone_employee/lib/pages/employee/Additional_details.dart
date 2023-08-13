import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teamone_employee/pages/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:teamone_employee/pages/dashboard/dashboard_screen.dart';
import 'package:teamone_employee/pages/employee/edit_details.dart';
import 'package:teamone_employee/services/supabase_config.dart';
import 'package:teamone_employee/services/supabase_client.dart';

class AdditionalDetailsScreen extends StatefulWidget {
  final String userId;

  const AdditionalDetailsScreen(this.userId, {Key? key}) : super(key: key);

  @override
  _AdditionalDetailsScreenState createState() =>
      _AdditionalDetailsScreenState();
}

class _AdditionalDetailsScreenState extends State<AdditionalDetailsScreen> {
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  bool _isSupervisor = false;

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
            builder: (context) => EditDetails(),
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
            builder: (context) => EditDetails(),
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
      body: Padding(
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
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                submitDetails();
              },
              child: Text(
                'Submit Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
     ),
      );
  }
}
