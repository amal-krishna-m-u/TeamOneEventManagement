import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:TeamOne/pages/auth/login_screen.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:TeamOne/services/supabase_config.dart'; 
import 'package:TeamOne/services/supabase_client.dart';


class MyRegister extends StatefulWidget {
  const MyRegister({Key? key}) : super(key: key);

  @override
  State<MyRegister> createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  bool _showPassword = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeSupabase(); // Initialize Supabase here
  }

  Future<void> initializeSupabase() async {
    final supabase = Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
    await supabase;
  }


static const platform = MethodChannel('com.example.signuptoast');

Future<void> showSignupSuccessToast() async {
  try {
    await platform.invokeMethod('showSignupSuccessToast'); // Use the correct method name
  } catch (e) {
    print('Error invoking method: $e');
  }
}



  Future<void> showSignupFailureToast() async {
    try {
      await platform.invokeMethod('showSignupFailureToast'); // Use the correct method name
    } catch (e) {
      print('Error invoking method: $e');
    }
  }



Future<void> signUp() async {
  try{ 
    final supabase = Supabase.instance;
    final response = await supabase.client.auth.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      data: { 'name': _fullNameController.text}
    );


    if (response.session?.user.createdAt != null)  {

      // Registration successful
       showSignupSuccessToast(); 
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyLogin(),
        ),
      );
      // Handle success and navigate to next screen
    } else {
      // Registration failed
      // Handle error
      print('Error: ${response.session}');
    }



      }
catch (error) {
  showSignupFailureToast();
      print('Registration failed: $error');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
 Image.asset(
                      'lib/images/logo.png', // Path to your PNG image
                      width: 210, // Set the desired width
                      height: 210, // Set the desired height
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.32,
                  right: 35,
                  left: 35,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextField(
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyLogin(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 18,
                              color: Color(0xff4c505b),
                            ),
                          ),
                        ),
                        SizedBox(width: 40),
                        Text(
                          'Register',
                          style: TextStyle(
                            color: Color(0xff4c505b),
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xff4c505b),
                          child: IconButton(
                            onPressed: () {
                              signUp();
                            },
                            color: Colors.white,
                            icon: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
