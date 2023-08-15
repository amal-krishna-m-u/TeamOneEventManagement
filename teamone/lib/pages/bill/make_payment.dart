import 'package:TeamOne/services/supabase_client.dart';
import 'package:flutter/material.dart';
import 'package:upi_india/upi_app.dart';
import 'package:upi_india/upi_india.dart';
import 'dart:math';
import 'package:TeamOne/main.dart';

class MakePayment extends StatefulWidget {
  final int eventId;
  final int employeeId;
  final int? billNo;

  MakePayment({
    required this.eventId,
    required this.employeeId,
    required this.billNo,
  });

  @override
  State<MakePayment> createState() => _MakePaymentState();
}

class _MakePaymentState extends State<MakePayment> {
  List<UpiApp>? apps;
  UpiIndia upiIndia = UpiIndia();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _upiIdController = TextEditingController();
  Random _random = Random(); // Random generator

  @override
  void initState() {
    upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      apps = [];
    });

    // Fetch employee details using the provided employeeId
    fetchEmployeeDetails(widget.employeeId);

    // Fetch event details using the provided eventId
    fetchEventDetails(widget.eventId);

    // Fetch payment details using the provided eventId and employeeId
    fetchPaymentDetails();

    super.initState();
  }


  Future<void> fetchEmployeeDetails(int employeeId) async {
    try {
      final db = DatabaseServices(client);
      final employeeDetails = await db.fetchData(
        tableName: 'employee',
        columnName: 'id',
        columnValue: employeeId.toString(),
      );
      _nameController.text = employeeDetails.isNotEmpty ? employeeDetails[0]['name'] : '';
      _upiIdController.text = employeeDetails.isNotEmpty ? employeeDetails[0]['upi_id'] : '';
    } catch (error) {
      print('Error fetching employee details: $error');
    }
  }

  Future<void> fetchEventDetails(int eventId) async {
    try {
      final db = DatabaseServices(client);
      final eventDetails = await db.fetchData(
        tableName: 'events',
        columnName: 'id',
        columnValue: eventId.toString(),
      );
      _noteController.text = eventDetails.isNotEmpty ? eventDetails[0]['event_name'] : '';
    } catch (error) {
      print('Error fetching event details: $error');
    }
  }

  Future<void> fetchPaymentDetails() async {
    try {
      DatabaseServices db = DatabaseServices(client);
      final paymentDetails = await db.fetchData(
        tableName: 'payment',
        columnName: 'Bill_no',
        columnValue: '${widget.billNo}',
      );
      _amountController.text = paymentDetails.isNotEmpty ? paymentDetails[0]['amount'].toString() : '';
    } catch (error) {
      print('Error fetching payment details: $error');
    }
  }

  Future<void> initiateTransaction(UpiApp app) async {
    String name = _nameController.text;
    String upiId = _upiIdController.text;
    String note = _noteController.text;
    String amount = _amountController.text;

    String randomRefId = _generateRandomReferenceId();

    UpiResponse response = await upiIndia.startTransaction(
      app: app,
      receiverUpiId: upiId,
      receiverName: name,
      transactionRefId: randomRefId,
      transactionNote: note,
      amount: double.parse(amount),
    );

    _handleTransactionResponse(response);
  }

  String _generateRandomReferenceId() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int randomNumber = _random.nextInt(999999);
    return 'Ref_${timestamp}_$randomNumber';
  }

  void _handleTransactionResponse(UpiResponse response) {
    // Handle the transaction response here
    String statusMessage;
    if (response.status == UpiPaymentStatus.SUCCESS) {
      statusMessage = "Transaction Successful";
    } else if (response.status == UpiPaymentStatus.SUBMITTED) {
      statusMessage = "Transaction Submitted";
    } else if (response.status == UpiPaymentStatus.FAILURE) {
      statusMessage = "Transaction Failed";
    } else {
      statusMessage = "Unknown Status";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(statusMessage),
          content: Text("Transaction Reference ID: ${response.transactionRefId}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Make Payment"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Amount",
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: "Note",
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _upiIdController,
                  decoration: InputDecoration(
                    labelText: "UPI ID",
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (apps != null && apps!.isNotEmpty) {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return ListView.builder(
                            itemCount: apps!.length,
                            itemBuilder: (context, index) {
                              UpiApp app = apps![index];
                              return ListTile(
                                leading: Image.memory(app.icon),
                                title: Text(app.name),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  initiateTransaction(app);
                                },
                              );
                            },
                          );
                        },
                      );
                    }
                  },
                  child: Text("Select Payment App"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
