import 'package:flutter/material.dart';
import 'package:teamone_employee/main.dart';
import 'package:teamone_employee/pages/employee/Additional_details.dart';
import 'package:teamone_employee/services/supabase_client.dart';
import 'package:teamone_employee/pages/dashboard/dashboard_screen.dart';

class EditDetails extends StatefulWidget {
  const EditDetails({super.key});

  @override
  State<EditDetails> createState() => _EditDetailsState();
}

class _EditDetailsState extends State<EditDetails> {
  AuthServices authServices = AuthServices(client);
  DatabaseServices databaseServices = DatabaseServices(client);
  

  @override
  void initState() {
    super.initState();
  }





  @override
  Widget build(BuildContext context) {
   
    final username = authServices.getUserName();
    final email = authServices.getUserEmail();
    final userid = authServices.getUserId();
    final data = databaseServices.fetchData(
      tableName: 'employee',
      columnName: 'userid',
      columnValue: userid,
    );

    final ColorScheme colorScheme = ColorScheme(
      primary: Color(0xFF283747), // Dark blue
      secondary: Colors.white, // White
      surface: Color.fromARGB(255, 200, 198, 198), // Light gray
      background: Colors.grey[300]!, // Light gray
      error: Colors.red, // Red
      onPrimary: Colors.white, // White (text/icon color on primary color)
      onSecondary: Colors.black, // Black (text/icon color on secondary color)
      onSurface: Color.fromARGB(255, 12, 12, 12), // Black (text color on surface)
      onBackground: Colors.black, // Black (text color on background)
      onError: Colors.white, // White (text color on error)
      brightness: Brightness.light, // Set to Brightness.light for light theme
    );

    final Color color = colorScheme.surface;
    final Color shadowcolor = colorScheme.onSurface.withOpacity(1);
    final Color surfacetint = colorScheme.secondary.withOpacity(0.8);
    final BorderRadius borderRadius = BorderRadius.all(Radius.circular(8.0));
 final $userid = authServices.getUserId();
    final $useremail = authServices.getUserEmail();
    final $username = authServices.getUserName().toUpperCase();

    
return Theme(
      data: ThemeData.from(colorScheme: colorScheme),
      child: Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          title: Text('Edit Details'), // Set your app bar title
          // You can also add actions, icons, etc. to the app bar as needed
        ),
        body: Center(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: databaseServices.fetchData(
              tableName: 'employee',
              columnName: 'userid',
              columnValue: userid,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Loading indicator while fetching data
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final employeeData = snapshot.data!.first;
                final upiId = employeeData['upi_id'] ?? 'N/A';
                final phoneNumber = employeeData['phone_number'] ?? 'N/A';
                final isSupervisor = employeeData['is_supervisor'] ?? false;
        
                return Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: borderRadius,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: $username',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Email: $email',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),


                            SizedBox(height: 10),
                            Text(
                              'UPI ID: $upiId',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),


                            SizedBox(height: 10),
                            Text(
                              'Phone Number: $phoneNumber',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),


                            SizedBox(height: 10),
                            Text(
                              'Is Supervisor: ${isSupervisor ? 'Yes' : 'No'}',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AdditionalDetailsScreen(userid),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: color,
                            shape: RoundedRectangleBorder(
                              borderRadius: borderRadius,
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                          ),
                          child: Text(
                            'Edit Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
              return Column(
                children: [
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: borderRadius,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name: $username',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Email: $email',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 10),
                         Text(
                          'Upi id : NIL ',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 10),
                         Text(
                          'Phone number: NIL ',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AdditionalDetailsScreen(userid),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 12, 12, 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: borderRadius,
                          
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                      child: Text(
                        'Add Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      )
      ,
              bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Dashboard(),
                    ),
                  );
                },
                icon: Icon(Icons.home),
              ),
            ],
          ),
        )
      
      ),
);
  }
}