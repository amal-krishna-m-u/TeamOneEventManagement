import 'package:flutter/material.dart';
import 'package:TeamOne/pages/employee/select_emp.dart';
import 'package:TeamOne/services/supabase_client.dart';
import 'package:TeamOne/main.dart';

class ApproveEmp extends StatefulWidget {
  const ApproveEmp({Key? key}) : super(key: key);

  @override
  State<ApproveEmp> createState() => _ApproveEmpState();
}

class _ApproveEmpState extends State<ApproveEmp> {
  DatabaseServices db = DatabaseServices(client);
  int? selectedEventId;

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
          title: Text(
            'Event Approval',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: db.selectAllData(tableName: 'events'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No events found.'));
                  } else {
                    final eventData = snapshot.data!;
                    return ListView.builder(
                      itemCount: eventData.length,
                      itemBuilder: (context, index) {
                        final event = eventData[index];
                        return Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFF283747),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            title: Text(
                              'Event: ${event['event_name']}',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SelectEmp(eventId: event['id']),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
