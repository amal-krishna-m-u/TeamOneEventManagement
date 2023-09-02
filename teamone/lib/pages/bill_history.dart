import 'package:TeamOne/pages/dashboard/dashboard_screen.dart';
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
  List<Map<String, dynamic>> displayedPaymentDetails = [];
  bool showEmployeeBills = true;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false; // Track whether search is active
  late final  eventName;

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
        clientPaymentDetails = payments
            .where((payment) => payment['employee_details'] == null)
            .toList();
        // Initialize the displayed list based on the current filter mode
        displayedPaymentDetails =
            showEmployeeBills ? employeePaymentDetails : clientPaymentDetails;
      });

      eventName = payments[0]['event_details'];
     // print('event name is ......... \n.........\n.......  $eventName\n\n');
    } catch (error) {
      print('Error fetching payment details: $error');
    }
  }

  // Function to filter payment details based on search query
  void filterPayments(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the query is empty, display bills based on the current filter mode
        displayedPaymentDetails =
            showEmployeeBills ? employeePaymentDetails : clientPaymentDetails;
      } else {
        // Filter payments based on the search query
        displayedPaymentDetails = displayedPaymentDetails.where((payment) {
          final employeeName = payment['employee_details']?['name'] ?? '';
          final clientName = payment['client_name'] ?? '';
          return employeeName.toLowerCase().contains(query.toLowerCase()) ||
              clientName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
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
          title: isSearching
              ? TextField(
                  style: TextStyle(color: Colors.white),
                  controller: searchController,
                  onChanged: (query) {
                    filterPayments(query);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by Name',
                    border: InputBorder.none,
                  ),
                )
              : Text(showEmployeeBills ? 'Employee Bills' : 'Client Bills'),
          actions: [
            IconButton(
              icon: Icon(isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  isSearching = !isSearching;
                  if (!isSearching) {
                    // Clear search query and restore the original list
                    searchController.clear();
                    filterPayments('');
                  }
                });
              },
            ),
          ],
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
                      // Switch to displaying employee bills
                      displayedPaymentDetails = employeePaymentDetails;
                    });
                  },
                  child: Text('Employee Bills'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showEmployeeBills = false;
                      // Switch to displaying client bills
                      displayedPaymentDetails = clientPaymentDetails;
                    });
                  },
                  child: Text('Client Bills'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: _buildBillList(displayedPaymentDetails),
            ),
          ],
        ),
      
      
      
              bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          items: [
            // Placeholder item for Generate Bill
            BottomNavigationBarItem(
              icon: Icon(Icons.new_releases_outlined),
              label: ' Bill History',
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

  Widget _buildBillList(List<Map<String, dynamic>> paymentDetails) {
    return paymentDetails.isNotEmpty
        ? ListView.builder(
            itemCount: paymentDetails.length,
            itemBuilder: (context, index) {
              final payment = paymentDetails[index];
            return InkWell(
              onTap: () {
                if (payment['employee_details'] != null) {
                  _showDetailsDialog(payment); // Show details for employees
                } else {
                  _showClientDetailsDialog(payment,eventName); // Show details for clients
                }
              },

                child: Container(
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
                        'Payment Amount: ${payment['total']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Event Name : ${eventName['event_name']}'),
                      Text('Payment Date: ${payment['payment_date']}'),
                      if (payment['employee_details'] != null) ...[
                        SizedBox(height: 4),
                        Text(
                            'Employee Name: ${payment['employee_details']['name']}'),
                      ],
                      if (payment['client_name'] != null) ...[
                        SizedBox(height: 4),
                        Text('Client Name: ${payment['client_name']}'),
                      ],
                    ],
                  ),
                ),
              );
            },
          )
        : Center(child: Text('No payment history available.'));
  }






// Inside your _BillHistoryState class
Future<void> _showClientDetailsDialog(Map<String, dynamic> data, eventName,) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Client Payment Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Client Name: ${data['client_name']}',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),


            if (eventName['event_name']!= null) ...[
                Text('Event Name: ${eventName['event_name']}'),
              Text('Event Place: ${eventName['event_place']}'),
              Text('Event Date: ${eventName['event_date']}'),
              // Add more event details here if needed
            ],
            Text('Payment Date: ${data['payment_date']}'),
            //Text('Mode of payment : ${data['mode_of_payment']}'),
           // Text('Payment Sender: ${data['sender']}'),
            //Text('Remarks: ${data['remarks']}'),
            Text('Advance : ${data['advance']}'),
            Text('Payment Amount: ${data['total']}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}








  // Function to show a dialog with additional details
  Future<void> _showDetailsDialog(Map<String, dynamic> data) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Payment Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bill No: ${data['Bill_no']}',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Employee Name: ${data['employee_details']['name']}',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              if (data['event_details'] != null) ...[
                Text('Event Name: ${data['event_details']['event_name']}'),
                Text('Event Place: ${data['event_details']['event_place']}'),
                Text('Event Date: ${data['event_details']['event_date']}'),
                // Add more event details here if needed
              ],
              Text('Payment Date: ${data['payment_date']}'),
              Text('Mode of payment : ${data['mode_of_payment']}'),
              Text('Payment Sender: ${data['sender']}'),
              Text('Remarks: ${data['remarks']}'),
              Text('Careoff : ${data['careoff']}'),
              Text('Payment Amount: ${data['amount']}'),
              Text('Payment Fuel: ${data['fuel']}'),
              Text('Payment Extra: ${data['extra']}'),
              Text(
                  'Payment Total: \n [(${data['careoff']} * ${data['amount']})+  ${data['fuel']} + ${data['extra']} ] =  ${data['total']}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
