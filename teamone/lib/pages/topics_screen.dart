import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartdeckapp/main.dart';
import 'app_colors.dart';
import 'package:smartdeckapp/pages/dashboard_screen.dart';
import 'package:smartdeckapp/pages/flashcards_screen.dart';
import 'package:smartdeckapp/services/supabase_client.dart';
import 'package:smartdeckapp/pages/event_details.dart';

class MyEvents extends StatefulWidget {
  const MyEvents({Key? key}) : super(key: key);

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {
  TextEditingController searchController = TextEditingController();

  List<String> searchResult = [];
  List<String> events = [];

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEvents = prefs.getStringList('events');

    setState(() {
      events = storedEvents ?? [];
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

          return AlertDialog(
            icon: Icon(
              Icons.event_available_outlined,
              color: Colors.black,
              size:25,
            ),
            actionsOverflowButtonSpacing: 20,
            backgroundColor: Colors.white,
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
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final insertResponse = await client.from('events').insert({
                    'name': eventName,
                    'place': place,
                    'participants': participants,
                    'employees': employees,
                  }).execute();
                  if (insertResponse.status == 200) {
                    setState(() {
                      events.add(eventName);
                    });
                    await saveEvents();
                  }
                  Navigator.of(context).pop();
                },
                child: Text('Add'),
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
    });
    await saveEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Column(
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
    );
  }
}
