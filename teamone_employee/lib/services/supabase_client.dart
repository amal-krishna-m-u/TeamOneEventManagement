import 'dart:async';

import 'package:flutter/material.dart';
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



//fetch data 


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

  Future<void> signInUser({
    required String userEmail,
    required String userPassword,
    required BuildContext context, // Add BuildContext parameter
  }) async {
    await client.auth.signInWithPassword(
      email: userEmail,
      password: userPassword,
    );

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