import 'package:TeamOne/pages/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:TeamOne/pages/dashboard/dashboard_screen.dart';
import 'package:TeamOne/pages/app_colors.dart';

class info_outline extends StatefulWidget {
  const info_outline({Key? key}) : super(key: key);


   @override
  State<info_outline> createState() => _info_outlineState();
}

class _info_outlineState extends State<info_outline> {
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: AppColorScheme.appColorScheme.secondary,
          ),
          backgroundColor: AppColorScheme.appColorScheme.primary,
          title: Text(
            'Info',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColorScheme.appColorScheme.secondary,
            ),
          ),
        ),
        body:Center(
          child: Text(
            'Hello World!\nWelcome to the Info page.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        );
        }






  
}