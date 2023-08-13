import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:teamone_employee/services/supabase_config.dart';
import 'package:teamone_employee/services/supabase_client.dart';
import 'package:teamone_employee/main.dart';


import'package:teamone_employee/pages/event/aprroved_event.dart';
import'package:teamone_employee/pages/event/event_request.dart';
import 'package:teamone_employee/pages/employee/edit_details.dart';
import 'package:teamone_employee/pages/event/bill_history.dart';

import '../auth/login_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isLoading = false;
  AuthServices authServices = AuthServices(client);

  Widget getScreenByRouteName(String routeName) {
    switch (routeName) {
      case 'ApprovedEvent':
        return ApprovedEvent();
      case 'EventRequest':
        return EventRequest();
      case 'EmployeeManagement':
        return EditDetails();
      case 'BillHistory':
        return BillHistory();
      default:
        return Container();
    }
  }

  @override
  void initState() {
    super.initState();

    // Simulating data loading delay
  }

  @override
  Widget build(BuildContext context) {
    // Define your custom color scheme
    final ColorScheme colorScheme = ColorScheme(
      primary: Color(0xFF283747), // Dark blue
      secondary: Colors.white, // White
      surface: Color.fromARGB(255, 200, 198, 198), // Light gray
      background: Colors.grey[300]!, // Light gray
      error: Colors.red, // Red
      onPrimary: Colors.white, // White (text/icon color on primary color)
      onSecondary: Colors.black, // Black (text/icon color on secondary color)
      onSurface:
          Color.fromARGB(255, 12, 12, 12), // Black (text color on surface)
      onBackground: Colors.black, // Black (text color on background)
      onError: Colors.white, // White (text color on error)
      brightness: Brightness.light, // Set to Brightness.light for light theme
    );

    final Color color = colorScheme.surface;
    final Color shadowcolor = colorScheme.onSurface.withOpacity(1);
    final Color surfacetint = colorScheme.secondary.withOpacity(0.8);
    final BorderRadius borderRadius = BorderRadius.all(Radius.circular(8.0));
    final userid = authServices.getUserId();
    final usereamil = authServices.getUserEmail();
    final username = authServices.getUserName().toUpperCase();

    Widget _buildContainer(
        String title, String subtitle, String iconName, String routeName) {
      IconData icon =
          Icons.error; // Default icon in case icon name is not found

      switch (iconName) {
        case 'event.png':
          icon = Icons.approval_rounded;
          break;
        case 'invoice.png':
          icon = Icons.ads_click_sharp;
          break;
        case 'employee.png':
          icon = Icons.edit_note_rounded;
          break;
        case 'increase-graph.png':
          icon = Icons.history_toggle_off_rounded;
          break;
        default:
          break;
      }

    //  if (routeName == 'EmployeeManagement') {
      //  icon = Icons.person_3_outlined;
     // }

      return Padding(
        padding: EdgeInsets.only(bottom: 30, left: 15, right: 15),
        child: Material(
          type: MaterialType.card,
          borderRadius: borderRadius,
          shadowColor: shadowcolor,
          surfaceTintColor: surfacetint,
          color: color,
          elevation: 10,
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: Container(
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => getScreenByRouteName(routeName),
                    ),
                  );
                },
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 5, bottom: 30, top: 10, right: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        icon,
                        size: 50,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Theme(
      data: ThemeData.from(colorScheme: colorScheme),
      child: Scaffold(
        backgroundColor: colorScheme.background,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  title: Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                  ),
                  iconTheme: IconThemeData(
                    color: colorScheme.onPrimary,
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 30),
                          ClipRRect(
                            // Wrap with ClipRRect to make the Material widget circular
                            borderRadius: BorderRadius.circular(
                                57), // Set a high enough value for a circular effect
                            child: Material(
                              type: MaterialType.card,
                              borderRadius: borderRadius,
                              shadowColor: shadowcolor,
                              surfaceTintColor: surfacetint,
                              color: Color.fromARGB(255, 120, 111, 111),
                              elevation: 10,
                              child: CircleAvatar(
                                // Use CircleAvatar to display the user image
                                radius:
                                    60, // Set the radius to customize the size
                                backgroundImage: AssetImage(
                                    'lib/images/userimage.jpeg'), // Set the user image
                              ),
                            ),
                          ),
                          SizedBox(width: 25),
                          Material(
                            type: MaterialType.card,
                            borderRadius: borderRadius,
                            shadowColor: shadowcolor,
                            surfaceTintColor: surfacetint,
                            color: color,
                            elevation: 10,
                            child: SizedBox(
                              height: 100,
                              width: 200,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '$username',
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        List<Map<String, dynamic>> screens = [
                          {
                            'title': 'Approved Work',
                            'subtitle': 'View your approved work & their status',
                            'icon': 'event.png',
                            'route': 'ApprovedEvent',
                          },
                          {
                            'title': 'Request Work',
                            'subtitle': 'Request for new work',
                            'icon': 'invoice.png',
                            'route': 'EventRequest',
                          },
                          {
                            'title': 'Edit Profile',
                            'subtitle': 'Edit your profile',
                            'icon': 'employee.png',
                            'route': 'EmployeeManagement',
                          },
                          {
                            'title': 'Bill History',
                            'subtitle': 'View your bill history',
                            'icon': 'increase-graph.png',
                            'route': 'BillHistory',
                          },
                        ];

                        return _buildContainer(
                          screens[index]['title'],
                          screens[index]['subtitle'],
                          screens[index]['icon'],
                          screens[index]['route'],
                        );
                      },
                      childCount: 4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: Text('Logout',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Times New Roman',
                      backgroundColor: Colors.grey[300],
                    )),
                onTap: () {
                  Icon(Icons.logout_outlined);
                  authServices.signOutUser(context).then(
                        (_) => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => MyLogin(),
                          ),
                        ),
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
