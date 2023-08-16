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
  List<Map<String, dynamic>> paymentDetails = [];

  @override
  void initState() {
    super.initState();
    fetchPaymentData();
  }

  Future<void> fetchPaymentData() async {
    try {
      final payments = await db.fetchPaymentDetails();
      setState(() {
        paymentDetails = payments;
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
        body: paymentDetails.isNotEmpty
            ? ListView.builder(
                itemCount: paymentDetails.length,
                itemBuilder: (context, index) {
                  final payment = paymentDetails[index];
                  final employee = payment['employee_details'] as Map<String, dynamic>;
                  final event = payment['event_details'] as Map<String, dynamic>;

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
                        SizedBox(height: 4),
                        Text('Employee Name: ${employee['name']}'),
                        SizedBox(height: 4),
                        Text('Event Name: ${event['event_name']}'),
                        SizedBox(height: 4),
                        Text('Event Date: ${event['event_date']}'),
                        SizedBox(height: 4),
                        Text('Event place: ${event['event_place']}'),
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
