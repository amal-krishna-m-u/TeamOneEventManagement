import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TeamOne/main.dart';
import '../app_colors.dart';
import 'package:TeamOne/pages/dashboard/dashboard_screen.dart';
import 'package:TeamOne/pages/flashcards_screen.dart';
import 'package:TeamOne/services/supabase_client.dart';
import 'package:TeamOne/pages/event/event_details.dart';

class MyEvents extends StatefulWidget {
  const MyEvents({Key? key}) : super(key: key);

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {
  TextEditingController searchController = TextEditingController();

  List<String> searchResult = [];
  List<String> events = [];
  DatabaseServices db = DatabaseServices(client);
  bool isLoading = true;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  DateTime removeTimeFromDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(currentDate.year - 5),
      lastDate: DateTime(currentDate.year + 5),
    );

    if (selectedDate != null && selectedDate != currentDate) {
      setState(() {
        // Update the selected date if it's not null and not the same as the current date
        this.selectedDate = selectedDate;
      });
    }
  }

  Future<void> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEvents = prefs.getStringList('events');

    // Fetch data from Supabase
    final eventData = await db.selectAllData(tableName: 'events');

    final now = DateTime.now();
    final eventNames =
        eventData.map((e) => e['event_name'] as String).where((eventName) {
      final eventDate = DateTime.parse(
        eventData.firstWhere(
          (e) => e['event_name'] == eventName,
          orElse: () => {},
        )['event_date'] as String,
      );
      return eventDate
          .isAfter(removeTimeFromDate(now.subtract(Duration(days: 1))));
    }).toList();

    setState(() {
      events = eventNames; // Replace the events list with filtered event names
      isLoading =
          false; // Set isLoading to false when data fetching is complete
    });
  }

  Future<void> addEventIfNotExists(String eventName) async {
    //this is check the shared preferences if the event is already added or not
    if (events.contains(eventName)) {
      // Handle error
      return;
    } else {
      // Show a dialogue box to input event details
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          String place = '';
          int participants = 0;
          int employees = 0;
          String eventManagementTeam = '';
          double advanceAmount = 0;
          double totalAmount = 0;
          String eventType = '';
          // slectedDate = DateTime.now();

          return AlertDialog(
            backgroundColor: Colors.white,
            icon: Icon(
              Icons.event_available_outlined,
              color: Colors.black,
              size: 25,
            ),
            actionsOverflowButtonSpacing: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            scrollable: true,
            shadowColor: Colors.black,
            elevation: 10,
            title: Text('Create Event',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                )),
            content: Column(
              children: [
                TextField(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  onChanged: (value) {
                    place = value;
                  },
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.place,
                      color: Colors.black,
                    ),
                    labelText: 'Place',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextField(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  onChanged: (value) {
                    participants = int.tryParse(value) ?? 0;
                  },
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.emoji_people_outlined,
                      color: Colors.black,
                    ),
                    labelText: 'Number of Participants',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  onTap: () =>
                      _selectDate(context), // Open date picker when clicked
                  controller: TextEditingController(
                    text: DateFormat('yyyy-MM-dd').format(
                        selectedDate), // Display formatted date in the field
                  ),
                  readOnly: true, // To prevent manual editing
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.date_range,
                      color: Colors.black,
                    ),
                    labelText: 'Select Date',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextField(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  onChanged: (value) {
                    eventManagementTeam = value;
                  },
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.people_alt_outlined,
                      color: Colors.black,
                    ),
                    labelText: 'Event Management Team',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextField(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  onChanged: (value) {
                    eventType = value;
                  },
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.set_meal_outlined,
                      color: Colors.black,
                    ),
                    labelText: 'Event Type',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextField(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  onChanged: (value) {
                    advanceAmount = double.tryParse(value) ?? 0;
                  },
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.price_check_outlined,
                      color: Colors.black,
                    ),
                    labelText: 'Advance Amount',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  onChanged: (value) {
                    totalAmount = double.tryParse(value) ?? 0;
                  },
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.attach_money_outlined,
                      color: Colors.black,
                    ),
                    labelText: 'Total Amount',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  onChanged: (value) {
                    employees = int.tryParse(value) ?? 0;
                  },
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.people_alt_outlined,
                      color: Colors.black,
                    ),
                    labelText: 'Number of Employees',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(239, 225, 29, 15),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    'Cancel'),
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(244, 2, 240, 42),
                  ),
                ),
                onPressed: () async {
                  final insertResponse = await client.from('events').insert({
                    'event_name': eventName,
                    'event_place': place,
                    'participants': participants,
                    'no_of_employees': employees,
                    'event_management_team': eventManagementTeam,
                    'advance_amount': advanceAmount,
                    'total_amount': totalAmount,
                    'event_type': eventType,
                    'event_date': selectedDate.toIso8601String(),
                  }).execute();

                  if (insertResponse.status == 200) {
                    setState(() {
                      events.add(eventName);
                    });
                    await saveEvents();
                  }
                  Navigator.of(context).pop();
                },
                child: Text(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    'Add'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('events', events);
  }

  void searchEvents(String key) {
    if (key.isEmpty) {
      setState(() {
        searchResult = [];
      });
    } else {
      setState(() {
        searchResult = events
            .where((eventName) =>
                eventName.toLowerCase().contains(key.toLowerCase()))
            .toList();

        if (!searchResult.contains(key)) {
          searchResult.add(key);
        }
      });
    }
  }

  void navigateToEvent(String eventName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyEventsDetails(eventName: eventName),
      ),
    );
  }

  bool isEventAdded(String eventName) {
    return events.contains(eventName);
  }

  Future<void> handleAddEvent(String eventName) async {
    if (!events.contains(eventName)) {
      setState(() {
        addEventIfNotExists(eventName);
        events.add(eventName);
      });
      await saveEvents();
    }
  }

  Future<void> handleDeleteEvent(String eventName) async {
    setState(() {
      events.remove(eventName);
      db.deleteData(
          tableName: 'events',
          columnName: 'event_name',
          columnValue: eventName);
    });
    await saveEvents();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.light(
      primary: Color(0xFF283747),
      secondary: Colors.white,
    );

    return Theme(
      data: ThemeData.from(colorScheme: colorScheme),
      child: Scaffold(
        backgroundColor: Color(0xFFE5E5E5),
        appBar: AppBar(
          backgroundColor: Color(0xFF283747),
          title: Text(
            'Events & Reminders',
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
        body: isLoading
            ? Center(
                child:
                    CircularProgressIndicator(), // Show loader while fetching data
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onChanged: (value) {
                                searchEvents(value);
                              },
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: 'Find Events',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              searchEvents(searchController.text);
                            },
                            child: Icon(
                              Icons.send_rounded,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                  if (searchController.text.isEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final eventName = events[index];
                          final isAdded = isEventAdded(eventName);

                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: 8.0, left: 20.0, right: 20.0, top: 8.0),
                            child: Dismissible(
                              key: Key(eventName),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 16.0),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (direction) {
                                handleDeleteEvent(eventName);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Text(
                                    eventName,
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          if (isAdded) {
                                            navigateToEvent(eventName);
                                          } else {
                                            handleAddEvent(eventName);
                                          }
                                        },
                                        child: Text(
                                          isAdded ? 'View' : 'Add',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                            isAdded
                                                ? Colors.blue
                                                : Colors.green,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      if (isAdded)
                                        GestureDetector(
                                          onTap: () {
                                            handleDeleteEvent(eventName);
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.black,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: searchResult.length,
                        itemBuilder: (context, index) {
                          final eventName = searchResult[index];
                          final isAdded = isEventAdded(eventName);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 20.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Text(
                                  eventName,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        if (isAdded) {
                                          navigateToEvent(eventName);
                                        } else {
                                          handleAddEvent(eventName);
                                        }
                                      },
                                      child: Text(
                                        isAdded ? 'View' : 'Add',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          isAdded ? Colors.blue : Colors.green,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    if (isAdded)
                                      GestureDetector(
                                        onTap: () {
                                          handleDeleteEvent(eventName);
                                        },
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.black,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
