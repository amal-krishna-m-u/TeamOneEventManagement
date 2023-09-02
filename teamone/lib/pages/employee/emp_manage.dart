import 'package:TeamOne/pages/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:TeamOne/pages/employee/edit_emp.dart';
import 'package:TeamOne/pages/employee/approve_emp.dart';

class EmpManage extends StatefulWidget {
  const EmpManage({super.key});

  @override
  State<EmpManage> createState() => _EmpManageState();
}

class _EmpManageState extends State<EmpManage> {
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
          title: const Text('Employee Management'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Employee Management'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ApproveEmp()),
                      );
                      // Implement the logic to add or assign resources to the event
                    },
                    icon: Icon(Icons.inventory),
                    label: Text('Approve Employee'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>EditEmployee()),
                      );
                      // Implement the logic to add or assign resources to the event
                    },
                    icon: Icon(Icons.inventory),
                    label: Text('Edit Employee'),
                  ),
                ],
              ),
            ],
          ),
        ),
      
      
      
          
          
              bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          items: [
            // Placeholder item for Generate Bill
            BottomNavigationBarItem(
              icon: Icon(Icons.new_releases_outlined),
              label: ' Employee Management',
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
