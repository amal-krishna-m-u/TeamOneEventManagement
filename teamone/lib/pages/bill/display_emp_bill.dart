import 'package:flutter/material.dart';
import 'package:TeamOne/services/supabase_client.dart';
import 'package:TeamOne/main.dart';
import 'package:intl/date_time_patterns.dart';
import 'make_payment.dart';
class DisplayEmpBill extends StatefulWidget {
  final int eventId;
  final int employeeId;


  DisplayEmpBill({required this.eventId, required this.employeeId});

  @override
  _DisplayEmpBillState createState() => _DisplayEmpBillState();
}

class _DisplayEmpBillState extends State<DisplayEmpBill> {
  late String eventName;
  late String employeeName;
  late DateTime eventDate;
  int? billNo;
  bool isLoaging = true;

  late TextEditingController salaryController;
  late TextEditingController totalAmountController;

  @override
  void initState() {
    super.initState();
    fetchEventAndEmployeeDetails();
    fetchLastBillNumber();
    salaryController = TextEditingController();
    totalAmountController = TextEditingController();
  }

  Future<void> fetchEventAndEmployeeDetails() async {
    try {
      final db = DatabaseServices(client);

      final eventDetails = await db.fetchData(
        tableName: 'events',
        columnName: 'id',
        columnValue: widget.eventId.toString(),
      );
      eventName = eventDetails.isNotEmpty ? eventDetails[0]['event_name'] : '';
      eventDate = eventDetails.isNotEmpty ? DateTime.parse(eventDetails[0]['event_date']) : DateTime.now();

      final employeeDetails = await db.fetchData(
        tableName: 'employee',
        columnName: 'id',
        columnValue: widget.employeeId.toString(),
      );
      employeeName = employeeDetails.isNotEmpty ? employeeDetails[0]['name'] : '';

      setState(() {});
    } catch (error) {
      print('Error fetching event and employee details: $error');
    }



    isLoaging = false;
  }

  Future<void> fetchLastBillNumber() async {
    try {
      // Simulate fetching the last payment entry
      final lastPaymentEntry = await fetchLastPaymentEntry();
      if (lastPaymentEntry != null) {
        setState(() {
          billNo = lastPaymentEntry['id'] + 1;
        });
      }
    } catch (error) {
      print('Error fetching last bill number: $error');
    }
  }

  Future<Map<String, dynamic>?> fetchLastPaymentEntry() async {
    // Simulate fetching the last payment entry
    return {'id': 10}; // Replace with your actual logic
  }

  @override
  void dispose() {
    salaryController.dispose();
    totalAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoaging) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Bill Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.black,
                unselectedWidgetColor: Colors.black,
              ),
              child: Table(
                border: TableBorder.all(),
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: Text('Bill No:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TableCell(
                        child: Text(billNo.toString()),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(
                        child: Text('Employee Name:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TableCell(
                        child: Text(employeeName),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(
                        child: Text('Event Name:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TableCell(
                        child: Text(eventName),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(
                        child: Text('Date of Event:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TableCell(
                        child: Text(eventDate
                            .toString()
                            .split(' ')[0]), // Display only date
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(
                        child: Text('Bill Date:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TableCell(
                        child: Text(DateTime.now()
                            .toLocal()
                            .toString()
                            .split(' ')[0]), // Display current date
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(
                        child: Text('Salary:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TableCell(
                        child: TextFormField(
                          controller: salaryController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Computer Generated Bill',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
billed();



                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MakePayment(
                      eventId: widget.eventId,
                      employeeId: widget.employeeId,
                      billNo: billNo,
                    ),
                  ),
                );
              },
              child: Text('Confirm Bill'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future billed() async {
DatabaseServices db = DatabaseServices(client);
final Response = await db.insertData(tableName: 'payment', data: {
  'Bill_no': billNo,
  'event_id': widget.eventId,
  'emp_id': widget.employeeId,
  'amount': salaryController.text.toString(),
  'payment_date': DateTime.now().toLocal().toString().split(' ')[0],


});




  }
}




