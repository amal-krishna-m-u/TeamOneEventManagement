import 'package:flutter/material.dart';
import 'package:TeamOne/services/supabase_client.dart';
import 'package:TeamOne/main.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  int? careoff ;

   TextEditingController salaryController=TextEditingController();
   TextEditingController totalAmountController=TextEditingController();
  TextEditingController fuelController=TextEditingController();
  TextEditingController extraController=TextEditingController();
  TextEditingController careoffController =TextEditingController();
  TextEditingController senderController=TextEditingController();
  TextEditingController modeController=TextEditingController();
  TextEditingController remarkController=TextEditingController();



  @override
  void initState() {
    super.initState();
    fetchEventAndEmployeeDetails();
    fetchLastBillNumber();
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


final res = await client
        .from('assign')
        .select('careoff')
        .eq('emp_id', widget.employeeId)
        .eq('event_id', widget.eventId)
        .execute();
careoff = res.data[0]['careoff'];
careoffController.text = careoff.toString();

      setState(() {});
    } catch (error) {
      print('Error fetching event and employee details: $error');
    }





    





    isLoaging = false;
  }

 Future<void> fetchLastBillNumber() async {
  try {
    // Simulate fetching the last payment entry
    final lastPaymentEntry = await fetchLastPaymentEntry(widget.employeeId, widget.eventId);
    if (lastPaymentEntry != null) {
      setState(() {
        billNo = lastPaymentEntry + 1;
      });
    } else {
      setState(() {
        billNo = 0; // If no entry found, set bill number to 0
      });
    }
  } catch (error) {
    print('Error fetching last bill number: $error');
  }
}


  Future<int> fetchLastPaymentEntry(int userId, int eventId) async {
   // Initialize your Supabase client
  final response = await client
      .from('payment')
      .select('Bill_no')
      .eq('emp_id', userId)
      .order('id', ascending: false)
      .limit(1)
      .execute();
  
  if (response.status != 200) {
    throw response;
  }
  
  final data = response.data as List<dynamic>;
  
  if (data.isNotEmpty) {
    return data[0]['Bill_no'] as int;
  } else {
    return 0; // If no entry found, set bill number to 0
  }
}

  @override
  void dispose() {
    salaryController.dispose();
    totalAmountController.dispose();
    fuelController.dispose();
    extraController.dispose();
    careoffController.dispose();
    senderController.dispose();
    modeController.dispose();
    remarkController.dispose();

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
            
            Expanded(
              child: Theme(
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
                        child: Text('\t Bill No:',
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
                        child: Text('\t Employee Name:',
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
                        child: Text('\t Event Name:',
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
                        child: Text('\t Date of Event:',
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
                        child: Text('\t Bill Date:',
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
                        child: Text('\t careoff:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TableCell(
                        child: TextFormField(
                          controller: careoffController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),






TableRow(
                    children: [
                      TableCell(
                        child: Text('\t Amount:',
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




TableRow(
                    children: [
                      TableCell(
                        child: Text('\t Fuel:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TableCell(
                        child: TextFormField(
                          controller: fuelController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),


                  TableRow(
                    children: [
                      TableCell(
                        child: Text('\t Extra:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TableCell(
                        child: TextFormField(
                          controller: extraController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                /*  TableRow(
                    children: [
                      TableCell(
                        child: Text('\t Total:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
TableCell( 
                        child: Text('${careoff}*${salaryController.text}+${fuelController.text}+${extraController.text}'),
                      ),
                    ],
                  ),*/


TableRow(
                    children: [
                      TableCell(
                        child: Text('\t Sender:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TableCell(
                        child: TextFormField(
                          controller: senderController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  TableRow(
                    children: [
                      TableCell(
                        child: Text('\t Mode of payment:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TableCell(
                        child: TextFormField(
                          controller: modeController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),


                  TableRow(
                    children: [
                      TableCell(
                        child: Text('\t Remarks:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TableCell(
                        child: TextFormField(
                          controller: remarkController,
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ],
                  ),







                ],
              ),
            ),
            ),
         /*   SizedBox(height: 16),
            Center(
              child: Text(
                'Computer Generated Bill',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Navigate to MakePayment page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MakePayment(
                      eventId: widget.eventId,
                      employeeId: widget.employeeId,
                      billNo: billNo,
                      amount:salaryController.text
                    ),
                  ),
                );
              },
              child: Text('Make Payment'),
            ),
*/
            ElevatedButton(
              onPressed: () async {
                // Call the billed function
                await billed();

                // Navigate back to the previous page
                Navigator.pop(context);
              },
              child: Text('Create Bill and Go Back'),
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
'careoff': int.parse(careoffController.text),
'fuel': int.parse(fuelController.text),
'extra': int.parse(extraController.text),
'sender': senderController.text.toString(),
'mode_of_payment':modeController.text.toString(),
'remarks':remarkController.text.toString()


});









  }
}




