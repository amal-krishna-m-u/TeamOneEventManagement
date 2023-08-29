import 'package:TeamOne/main.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:TeamOne/services/supabase_client.dart';

class BillClient extends StatefulWidget {
  const BillClient({Key? key, required this.eventId}) : super(key: key);

  final int eventId;

  @override
  State<BillClient> createState() => _BillClientState();
}

class _BillClientState extends State<BillClient> {
  DatabaseServices db = DatabaseServices(client);
  Map<String, dynamic> eventDetails = {};

  TextEditingController eventNameController = TextEditingController();
  TextEditingController eventDateController = TextEditingController();
  TextEditingController eventPlaceController = TextEditingController();
  TextEditingController advanceAmountController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();
  TextEditingController eventManagementTeamController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    try {
      final event = await db.fetchEventDetailsWithId(widget.eventId);
      setState(() {
        eventDetails = event;
        eventNameController.text = event['event_name'];
        eventDateController.text = event['event_date'];
        eventPlaceController.text = event['event_place'];
        advanceAmountController.text = event['advance_amount'].toString();
        totalAmountController.text = event['total_amount'].toString();
        eventManagementTeamController.text =
            event['event_management_team'].toString();
      });
    } catch (error) {
      print('Error fetching event details: $error');
    }
  }

  Future<void> updateEventDetails() async {
    final paymentClientData = {
      'client_name': eventManagementTeamController.text,
      'event_id': widget.eventId,
      'amount': double.parse(totalAmountController.text),
      'advance': double.parse(advanceAmountController.text),
      'payment_date': DateTime.now().toIso8601String(),
    };

    try {
      await db.insertData(
        tableName: 'payment_client',
        data: paymentClientData,
      );

      await db.UpdateEventRecieved(eventId: widget.eventId);
    } catch (error) {
      print('Error inserting into payment_client: $error');
    }
  }

  @override
  void dispose() {
    eventNameController.dispose();
    eventDateController.dispose();
    eventPlaceController.dispose();
    advanceAmountController.dispose();
    totalAmountController.dispose();
    eventManagementTeamController.dispose();
    super.dispose();
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
          title: Text('Generate Bill for Client'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: eventNameController,
                decoration: InputDecoration(labelText: 'Event Name'),
                readOnly: true, // Set the field as uneditable
              ),
              TextField(
                controller: eventDateController,
                decoration: InputDecoration(labelText: 'Event Date'),
                readOnly: true,
              ),
              TextField(
                controller: eventPlaceController,
                decoration: InputDecoration(labelText: 'Event Location'),
                readOnly: true,
              ),
              TextField(
                controller: advanceAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Advance Amount'),
                readOnly: true,
              ),
              TextField(
                controller: totalAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Total Amount'),
                readOnly: true,
              ),
              TextField(
                controller: eventManagementTeamController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: 'Event Team'),
                readOnly: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  updateEventDetails();
                  Navigator.pop(context); // Navigate back to previous screen
                },
                child: Text('add rental'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  updateEventDetails();
                  Navigator.pop(context); // Navigate back to previous screen
                },
                child: Text('add employee'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  updateEventDetails();
                  Navigator.pop(context); // Navigate back to previous screen
                },
                child: Text('add petrol'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  updateEventDetails();
                  Navigator.pop(context); // Navigate back to previous screen
                },
                child: Text('Generate Bill and Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
