import 'package:flutter/material.dart';
import 'package:teamone_employee/main.dart';
import 'package:teamone_employee/services/supabase_client.dart';

class BillHistory extends StatefulWidget {
  const BillHistory({Key? key}) : super(key: key);

  @override
  State<BillHistory> createState() => _BillHistoryState();
}

class _BillHistoryState extends State<BillHistory> {
  DatabaseServices db = DatabaseServices(client);
  List<Map<String, dynamic>> userPaymentDetails = [];

  @override
  void initState() {
    super.initState();
    fetchUserPaymentData();
  }

  Future<void> fetchUserPaymentData() async {
    try {
      AuthServices auth = AuthServices(client);
      final currentUser =
          auth.getUserId(); // Assuming you have access to the current user
      if (currentUser != null) {
        final employeeDetails =
            await db.fetchEmployeeDetailsWithUserId(currentUser);
        if (employeeDetails != null) {
          final empId = employeeDetails['id'] as int;
          final payments = await db.fetchUserPaymentDetails(empId);

          payments.sort((a, b) {
            final aDate = DateTime.parse(a['payment_date']);
            final bDate = DateTime.parse(b['payment_date']);
            return bDate.compareTo(aDate);
          });

          setState(() {
            userPaymentDetails = payments;
          });
        }
      }
    } catch (error) {
      print('Error fetching user payment details: $error');
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
          title: Text('Your Bill History'),
        ),
        body: userPaymentDetails.isNotEmpty
            ? ListView.builder(
                itemCount: userPaymentDetails.length,
                itemBuilder: (context, index) {
                  final payment = userPaymentDetails[index];
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
                        if (event != null) ...[
                          SizedBox(height: 4),
                          Text(
                            'Event Name: ${event['event_name']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Bill NO : ${payment['Bill_no']}'),
                          SizedBox(height: 4),
                          Text('Event Date: ${event['event_date']}'),
                        ],
                        SizedBox(height: 8),
                        Text('Payment Date: ${payment['payment_date']}'),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Payment Amount: ${payment['amount']}',
                        ),
                        SizedBox(height: 8),
                        Text('careoff: ${payment['careoff']}'),
                        SizedBox(height: 8),
                        Text('Extra amount: ${payment['extra']}'),
                        SizedBox(height: 8),
                        Text('Fuel amount: ${payment['fuel']}'),
                        SizedBox(height: 8),
                        Text('Total: (${payment['amount']} * ${payment['careoff']}) + ${payment['fuel']} + ${payment['extra']}    =     ${payment['total']}'),
                        SizedBox(height: 8),
                        Text('Mode of payment : ${payment['mode_of_payment']}'),
                        SizedBox(height: 8),
                        Text('Sender: ${payment['sender']}'),
                      ],
                    ),
                  );
                },
              )
            : Center(child: Text('No payment history available.')),
      ),
    );
  }
}
