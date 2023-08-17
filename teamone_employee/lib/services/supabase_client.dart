import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teamone_employee/pages/dashboard/dashboard_screen.dart';
import 'package:teamone_employee/pages/auth/login_screen.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:teamone_employee/services/supabase_config.dart';
import 'package:teamone_employee/main.dart';
import 'package:supabase/supabase.dart';

class DatabaseServices {
  final SupabaseClient client;
  DatabaseServices(this.client);




 Future<Map<String, dynamic>?> fetchEmployeeDetailsWithUserId(String userId) async {
    final response = await client
        .from('employee')
        .select()
        .eq('userid', userId)
        .execute();

    if (response.status == 200 && response.data != null) {
      final data = response.data as List<dynamic>;
      if (data.isNotEmpty) {
        return data[0] as Map<String, dynamic>;
      }
    }
    return null;
  }




Future<List<Map<String, dynamic>>> fetchUserPaymentDetails(int empId) async {
  final response = await client
      .from('payment')
      .select('id, emp_id, event_id, amount, payment_date, mode_of_payment, Bill_no')
      .eq('emp_id', empId)
      .execute();

  if (response.status == 200 && response.data != null) {
    final paymentData = response.data as List<dynamic>;
    final paymentDetails = paymentData.cast<Map<String, dynamic>>();

    final eventIds = paymentDetails.map<int>((payment) => payment['event_id'] as int).toList();

    final eventResponse = await client
        .from('events')
        .select()
        .in_('id', eventIds)
        .execute();

    if (eventResponse.status == 200) {
      final eventData = eventResponse.data as List<dynamic>;
      final eventDetails = eventData.cast<Map<String, dynamic>>();
      
      // Match event details to payment details
      for (final payment in paymentDetails) {
        final eventId = payment['event_id'] as int;
        final matchingEvent = eventDetails.firstWhere((event) => event['id'] == eventId);
        payment['event_details'] = matchingEvent;
      }

      return paymentDetails;
    }
  }
  
  return []; // Return an empty list in case of any error or no data
}






//fetch data 

Future<List<Map<String, dynamic>>> fetchAssignedEvents({required int? employeeId}) async {
  final response = await client
      .from('assign')
      .select('event_id')
      .eq('emp_id', employeeId)
      .execute();

  if (response.status != 200) {
    throw response.status;
  }

  final assignedEvents = (response.data as List<dynamic>).cast<Map<String, dynamic>>();

  final eventIds = assignedEvents.map<int>((event) => event['event_id'] as int).toList();

  final eventResponse = await client
      .from('events')
      .select()
      .in_('id', eventIds)
      .execute();

  if (eventResponse.status!= 200) {
    throw eventResponse.status;
  }

  return (eventResponse.data as List<dynamic>).cast<Map<String, dynamic>>();
}



Future<List<Map<String, dynamic>>> fetchJoinData({
  required String tableName,
  required String conditionColumn1,
  required dynamic conditionValue1,
  required String conditionColumn2,
  required dynamic conditionValue2,
}) async {
  final response = await client
      .from(tableName)
      .select()
      .eq(conditionColumn1, conditionValue1)
      .eq(conditionColumn2, conditionValue2)
      .execute();

  if (response.status == 200 && response.data != null) {
    final data = response.data as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  } else {
    return [];
  }
}

Future<List<Map<String, dynamic>>> fetchAllJoinEventData({
  required int? userId,

}) async {
  final joinData = await fetchJoinData(
    tableName: 'event_employee_request',
    conditionColumn1: 'employee_id',
    conditionValue1: userId,
    conditionColumn2: 'approve',
    conditionValue2: true,
  );

  final List<Future<Map<String, dynamic>>> eventDataFutures = [];

  for (final data in joinData) {
    final eventId = data['event_id'] as int;
    final eventFuture = fetchData(
      tableName: 'events',
      columnName: 'id',
      columnValue: eventId.toString(),
    );
    eventDataFutures.add(eventFuture.then((value) => value[0]));
  }

  return Future.wait(eventDataFutures);
}




  Future<List<Map<String, dynamic>>> fetchData({
      required String tableName,
      required String columnName,
      required String columnValue,
    }) async {
      final response = await client
          .from(tableName)
          .select()
          .eq(columnName, columnValue)
          .execute();
      if (response.status == 200 && response.data != null) {
        final data = response.data as List<dynamic>;
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    }



    // select all the data in the table 

    Future<List<Map<String, dynamic>>> selectAllData({
      required String tableName,
    }) async {
      final response = await client.from(tableName).select().execute();
      if (response.status == 200 && response.data != null) {
        final data = response.data as List<dynamic>;
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    }





//insert data 
  Future<void> insertData({
    required String tableName ,
    required Map<String, dynamic> data,
  }) async {
    final response = await client.from(tableName).insert(data).execute();
    if (response.status == 200) {
      print('Data inserted successfully');
    } else {
      print('Data insertion failed');
    }
  }







}

class AuthServices {
  final SupabaseClient client;

  AuthServices(this.client);

  Future<void> showLoginFailureToast() async {
    try {
      await platform
          .invokeMethod('showLoginFailureToast'); // Use the correct method name
    } catch (e) {
      print('Error invoking method: $e');
    }
  }

static const platform = MethodChannel('com.example.signuptoast');
  Future<void> signInUser({
    required String userEmail,
    required String userPassword,
    required BuildContext context, // Add BuildContext parameter
  }) async {


//try { 
    await client.auth.signInWithPassword(
      email: userEmail,
      password: userPassword,
    );
  //      }                               catch (error) {
    //                            showLoginFailureToast();
      //                          print('Login failed: $error');
        //                      }

    // Start listening to auth state changes after signing in
    listernToAuthStatus(context);
  }

  StreamSubscription<AuthState> listernToAuthStatus(BuildContext context) {
    return client.auth.onAuthStateChange.listen((data) {
      final Session? session = data.session;
      final AuthChangeEvent event = data.event;
   

      final String? userid = session?.user?.id;

      switch (event) {
        case AuthChangeEvent.signedIn:
          if (session != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Dashboard(),
              ),
            );
          } else {
            // Handle error
            print('Error: ${session}');
          }
          break;

        case AuthChangeEvent.passwordRecovery:
          {
            String flag = "5";
          }
          break;

        case AuthChangeEvent.signedOut:
           Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyLogin(),
              ),
            );
          break;

        default:
          {
            String flag = "-1";
          }
      }
    });
  }

  bool isLoggedin() {
if(client.auth.currentSession != null)
{
  return false;
}
else
{
  return false;
}
  }

  Future<void> signOutUser(BuildContext context,) async {
    await client.auth.signOut();
    listernToAuthStatus(context);
  }



String  getUserId()  {
  final Session? session = client.auth.currentSession;
  final String? userid = session?.user?.id;
  return userid!;
}
String  getUserEmail()  {
  final Session? session = client.auth.currentSession;
  final String? userEmail = session?.user?.email;
  return userEmail!;
}
String  getUserName()  {
  final Session? session = client.auth.currentSession;
  final String? userName = session?.user?.userMetadata?['name'];
  return userName!;

}
}