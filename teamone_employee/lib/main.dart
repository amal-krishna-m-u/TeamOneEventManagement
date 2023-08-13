import 'package:flutter/material.dart';
import 'package:teamone_employee/pages/auth/login_screen.dart';
import 'package:teamone_employee/pages/auth/register_screen.dart';
import 'package:teamone_employee/services/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(SmartDeck());

}
final client = Supabase.instance.client;
class SmartDeck extends StatelessWidget {
  const SmartDeck({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'TeamOne Events',
      theme: ThemeData(
primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.grey[300],
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Times New Roman',
        useMaterial3: true,
      ),

      debugShowCheckedModeBanner: false,
      home:MyRegister(),
    );

  }
}
