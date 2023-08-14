import 'package:flutter/material.dart';
import 'package:TeamOne/pages/bill/display_pending_bill_client.dart';
import 'package:TeamOne/pages/bill/display_pending.dart';

class Bills extends StatefulWidget {
  const Bills({super.key});

  @override
  State<Bills> createState() => _BillsState();
}

class _BillsState extends State<Bills> {
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
        appBar: AppBar(title: Text('Bill Generator')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select to view bills',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayPendingBillsEmp(),
                        ),
                      );
                    },
                    icon: Icon(Icons.work),
                    label: Text('Employee'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayPendingBillsClient(),
                        ),
                      );
                    },
                    icon: Icon(Icons.person),
                    label: Text('Client'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
