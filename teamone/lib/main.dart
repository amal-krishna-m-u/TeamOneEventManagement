import 'package:flutter/material.dart';
import 'package:TeamOne/pages/login_screen.dart';
import 'package:TeamOne/services/supabase_config.dart';
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
      title: 'Smart Deck',
      theme: ThemeData(
primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.grey[300],
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Times New Roman',
        useMaterial3: true,
      ),

      debugShowCheckedModeBanner: false,
      home:MyLogin(),
    );

  }
}
