import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartdeckapp/pages/dashboard_screen.dart';
import 'package:smartdeckapp/pages/register_screen.dart';
import 'package:chart_sparkline/chart_sparkline.dart';

class MyStats extends StatefulWidget {
  const MyStats({Key? key}) : super(key: key);

  @override
  State<MyStats> createState() => _MyTopicsState();
}

class _MyTopicsState extends State<MyStats> {
  bool _showPassword = false;
  var data = [0.0, 1.0, 1.5, 2.0, 0.0, 0.0, -0.5, -1.0, -0.5, 0.0, 0.0];

  // Example data source
  final List<Map<String, dynamic>> tableData = [
    {'topic': 'glory palace', 'date': '2023-05-22', 'difficulty': 'On progress'},
    {'topic': 'Bolgaty Palace', 'date': '2023-05-23', 'difficulty': 'Completed'},
    {'topic': 'Grand palace', 'date': '2023-05-23', 'difficulty': 'On progress'},
    {'topic':'demo','date':'2023-05-23','difficulty':'Completed'},
    {'topic':'dmeo2','date':'2023-06-23','difficulty':'Scheduled'}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Color(0xFF283747),
        title: Text(
          'under maintanance',
          style: TextStyle(
            color: Colors.white,  
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 150,
                      child: Sparkline(
                        data: data,
                        useCubicSmoothing: true,
                        cubicSmoothingFactor: 0.2,
                        lineColor: Colors.blue,
                        lineWidth: 2.0,
                        fillMode: FillMode.below,
                        fillGradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue.withOpacity(0.1),
                            Colors.blue.withOpacity(0.02)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Show button functionality
                      },
                      icon: Icon(Icons.visibility),
                      label: Text('Show'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        textStyle: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bar_chart_rounded,
                            size: 20,
                            color: Colors.black,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Event Status',
                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: tableData.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(tableData[index]['topic']),
                              subtitle: Text(tableData[index]['date']),
                              trailing: Text(tableData[index]['difficulty']),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
