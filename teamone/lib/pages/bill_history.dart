import 'package:flutter/material.dart';
import 'package:TeamOne/main.dart';
import 'package:TeamOne/services/supabase_client.dart';

class BillHistory extends StatefulWidget {
  const BillHistory({Key? key}) : super(key: key);

  @override
  State<BillHistory> createState() => _BillHistoryState();
}

class _BillHistoryState extends State<BillHistory> {
  DatabaseServices db = DatabaseServices(client);
  List<Map<String, dynamic>> employeePaymentDetails = [];
  List<Map<String, dynamic>> clientPaymentDetails = [];
  bool showEmployeeBills = true;

  @override
  void initState() {
    super.initState();
    fetchPaymentData();
  }

  Future<void> fetchPaymentData() async {
    try {
      final payments = await db.fetchPaymentDetails();
      setState(() {
        employeePaymentDetails = payments
            .where((payment) => payment['employee_details'] != null)
            .toList();
            print(employeePaymentDetails);
            print( clientPaymentDetails);
        clientPaymentDetails = payments
            .where((payment) => payment['employee_details'] == null)
            .toList();
      });
    } catch (error) {
      print('Error fetching payment details: $error');
    }
  }

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
        appBar: AppBar(
          title: Text('Bill History'),
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showEmployeeBills = true;
                    });
                  },
                  child: Text('Employee Bills'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showEmployeeBills = false;
                    });
                  },
                  child: Text('Client Bills'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: showEmployeeBills
                  ? _buildBillList(employeePaymentDetails)
                  : _buildBillList(clientPaymentDetails),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildBillList(List<Map<String, dynamic>> paymentDetails) {
  return paymentDetails.isNotEmpty
      ? ListView.builder(
          itemCount: paymentDetails.length,
          itemBuilder: (context, index) {
            final payment = paymentDetails[index];
            final event = payment['event_details'] as Map<String, dynamic>?;

            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Amount: ${payment['amount']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Payment Date: ${payment['payment_date']}'),
                  if (payment['is_employee_payment'] == true) ...[
                    SizedBox(height: 4),
                      Text('Employee Name: ${payment['emp_id']}'),
                    if (event != null) ...[
                      SizedBox(height: 4),
                      Text('Event Name: ${event['event_name']}'),
                      SizedBox(height: 4),
                      Text('Event Date: ${event['event_date']}'),
                    ],
                  ] else ...[
                    if (payment['client_name'] != null)
                      SizedBox(height: 4),
                      Text('Client Name: ${payment['client_name']}'),
                    if (event != null) ...[
                      SizedBox(height: 4),
                      Text('Event Name: ${event['event_name']}'),
                      SizedBox(height: 4),
                      Text('Event Date: ${event['event_date']}'),
                    ],
                  ],
                ],
              ),
            );
          },
        )
      : Center(child: Text('No payment history available.'));
}
}