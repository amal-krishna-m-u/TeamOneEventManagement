import 'package:flutter/material.dart';
import 'package:smartdeckapp/pages/bill_history.dart';
import 'package:smartdeckapp/pages/manage_emp.dart';
import 'package:smartdeckapp/pages/topics_screen.dart';
import 'package:smartdeckapp/pages/stats_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smartdeckapp/services/supabase_config.dart';
import 'package:smartdeckapp/services/supabase_client.dart';
import 'package:smartdeckapp/main.dart';

import 'login_screen.dart';

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
      case 'MyEvents':
        return MyEvents();
      case 'MyStats':
        return MyStats();
      case 'EmployeeManagement':
        return ManageEmp();
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
      primaryVariant: Color(0xFF283747), // Dark blue variant
      secondary: Colors.white, // White
      secondaryVariant: Colors.white, // White variant
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
          icon = Icons.event;
          break;
        case 'invoice.png':
          icon = Icons.monetization_on_outlined;
          break;
        case 'employee.png':
          icon = Icons.people;
          break;
        case 'increase-graph.png':
          icon = Icons.history;
          break;
        default:
          break;
      }
      if (routeName == 'EmployeeManagement') {
        icon = Icons.person_3_outlined;
      }

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
                            'title': 'Events & Activities',
                            'subtitle': 'Manage your events and activities',
                            'icon': 'event.png',
                            'route': 'MyEvents',
                          },
                          {
                            'title': 'Generate Bills',
                            'subtitle': 'View your statistics and progress',
                            'icon': 'invoice.png',
                            'route': 'MyStats',
                          },
                          {
                            'title': 'Employee',
                            'subtitle': 'Manage your employees',
                            'icon': 'employee.png',
                            'route': 'EmployeeManagement',
                          },
                          {
                            'title': 'Bill History',
                            'subtitle': 'View your bill history',
                            'icon': 'history.png',
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
